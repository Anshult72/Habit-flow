import { Injectable, ForbiddenException, NotFoundException, UnauthorizedException, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CacheService } from '../cache/cache.service';
import { UsersService } from '../users/users.service';

// ─── XP Complexity System ────────────────────────────────────────────────────
// Maps complexity label → XP awarded per completion
const XP_PER_COMPLEXITY: Record<string, number> = {
  Basic: 2,
  Standard: 4,
  Advanced: 6,
  Elite: 8,
};

// Maps complexity label → maximum XP-eligible active habits for that tier
const TIER_LIMITS: Record<string, number> = {
  Basic: 9,
  Standard: 7,
  Advanced: 5,
  Elite: 3,
};

// Global cap: at most 10 active habits can earn XP simultaneously across all tiers
const GLOBAL_XP_CAP = 10;

// Old label → new label migration map (for self-healing migration)
const LABEL_MIGRATION: Record<string, string> = {
  easy: 'Basic',
  Easy: 'Basic',
  medium: 'Standard',
  Medium: 'Standard',
  hard: 'Advanced',
  Hard: 'Advanced',
  Elite: 'Elite',
  elite: 'Elite',
};

/**
 * Normalises a stored difficulty value to the canonical new label.
 * Falls back to 'Standard' for any unknown value.
 */
function normaliseComplexity(raw: string): string {
  return LABEL_MIGRATION[raw] ?? 'Standard';
}

/**
 * Given a list of a user's habits (sorted oldest-first), annotate each with:
 *   - isXpEligible  (boolean)
 *   - xpValue       (number — 0 when not eligible)
 *
 * Priority rules (oldest habit = highest priority):
 *   1. Global cap: at most GLOBAL_XP_CAP habits across all tiers earn XP.
 *   2. Per-tier cap: each complexity tier has its own sub-limit.
 *
 * A habit is eligible only if BOTH the global cap and the tier cap allow it.
 */
function calculateEligibility<T extends { difficulty: string; isActive?: boolean; isArchived?: boolean; createdAt?: Date | string }>(
  habits: T[],
): (T & { isXpEligible: boolean; xpValue: number })[] {
  // Sort oldest-first so earlier habits always get priority
  const sorted = [...habits].sort((a, b) => {
    const dateA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
    const dateB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
    return dateA - dateB;
  });

  const tierCount: Record<string, number> = { Basic: 0, Standard: 0, Advanced: 0, Elite: 0 };
  let globalCount = 0;

  // Annotate each habit in sorted order (oldest-first = highest priority)
  const annotated = sorted.map((habit) => {
    const complexity = normaliseComplexity(habit.difficulty);
    const tierLimit = TIER_LIMITS[complexity] ?? 0;
    const xpValue = XP_PER_COMPLEXITY[complexity] ?? 0;

    // A habit is eligible for XP only if it is active AND not archived
    const isActiveHabit = habit.isActive !== false && habit.isArchived !== true;

    const globalOk = globalCount < GLOBAL_XP_CAP;
    const tierOk = (tierCount[complexity] ?? 0) < tierLimit;
    const isXpEligible = isActiveHabit && globalOk && tierOk;

    if (isXpEligible) {
      globalCount++;
      tierCount[complexity] = (tierCount[complexity] ?? 0) + 1;
    }

    return {
      ...habit,
      // Normalise the stored label so the client always receives the new label
      difficulty: complexity,
      isXpEligible,
      xpValue: isXpEligible ? xpValue : 0,
    };
  });

  // Restore original order (newest-first, matching the DB orderBy desc) for the response
  annotated.sort((a, b) => {
    const dateA = (a as any).createdAt ? new Date((a as any).createdAt).getTime() : 0;
    const dateB = (b as any).createdAt ? new Date((b as any).createdAt).getTime() : 0;
    return dateB - dateA; // newest-first
  });

  return annotated;
}

@Injectable()
export class HabitsService implements OnModuleInit {
  constructor(
    private prisma: PrismaService,
    private cache: CacheService,
    private usersService: UsersService,
  ) {}

  async onModuleInit() {
    try {
      const allHabits = await this.prisma.habit.findMany({
        select: { id: true, difficulty: true },
      });
      let updatedCount = 0;
      for (const habit of allHabits) {
        const normalised = normaliseComplexity(habit.difficulty);
        if (habit.difficulty !== normalised) {
          await this.prisma.habit.update({
            where: { id: habit.id },
            data: { difficulty: normalised },
          });
          updatedCount++;
        }
      }
      if (updatedCount > 0) {
        console.log(`[HabitsService] Self-healing migration updated ${updatedCount} habits to new complexity labels.`);
      }
    } catch (e) {
      console.error('Failed to run habit difficulty database migration:', e);
    }
  }

  /**
   * Resolve Supabase UUID → internal user ID.
   * This is critical because req.user.sub is the Supabase UUID,
   * but habit.userId references our internal User.id (cuid).
   */
  private async resolveUserId(supabaseId: string): Promise<string> {
    const user = await this.prisma.user.findUnique({
      where: { supabaseId },
      select: { id: true },
    });
    if (!user) throw new UnauthorizedException('User not found');
    return user.id;
  }

  async findAll(supabaseId: string) {
    const userId = await this.resolveUserId(supabaseId);

    const cacheKey = `user:${userId}:habits`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const habits = await this.prisma.habit.findMany({
      where: { userId },
      include: { completions: true },
      orderBy: { createdAt: 'desc' },
    });

    // Annotate each habit with XP eligibility and value
    const enriched = calculateEligibility(habits);

    await this.cache.set(cacheKey, enriched, 300);
    return enriched;
  }

  async create(supabaseId: string, data: any) {
    const userId = await this.resolveUserId(supabaseId);
 
    // Normalise the incoming difficulty label before storing
    const rawDifficulty = data.difficulty || 'Standard';
    const normalisedDifficulty = normaliseComplexity(rawDifficulty);
 
    const habit = await this.prisma.habit.create({
      data: {
        title: data.title,
        description: data.description || null,
        category: data.category || null,
        color: data.color || '#FF6B2C',
        icon: data.icon || 'Zap',
        frequency: data.frequency || 'Daily',
        difficulty: normalisedDifficulty,
        goal: data.goal ?? 30,
        isActive: data.isActive !== false,
        isArchived: data.isArchived === true,
        userId,
      },
    });
    await this.cache.del(`user:${userId}:habits`);
    return habit;
  }
 
  async update(supabaseId: string, id: string, data: any) {
    const userId = await this.resolveUserId(supabaseId);
 
    const habit = await this.prisma.habit.findUnique({ where: { id } });
    if (!habit) throw new NotFoundException('Habit not found');
    if (habit.userId !== userId) throw new ForbiddenException('Not authorized');
 
    // Whitelist only allowed fields; normalise difficulty label on update
    const updateData: any = {};
    if (data.title !== undefined) updateData.title = data.title;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.category !== undefined) updateData.category = data.category;
    if (data.color !== undefined) updateData.color = data.color;
    if (data.icon !== undefined) updateData.icon = data.icon;
    if (data.frequency !== undefined) updateData.frequency = data.frequency;
    if (data.difficulty !== undefined) updateData.difficulty = normaliseComplexity(data.difficulty);
    if (data.goal !== undefined) updateData.goal = data.goal;
    if (data.isActive !== undefined) updateData.isActive = data.isActive;
    if (data.isArchived !== undefined) updateData.isArchived = data.isArchived;
 
    const updated = await this.prisma.habit.update({
      where: { id },
      data: updateData,
    });
    await this.cache.del(`user:${userId}:habits`);
    return updated;
  }

  async delete(supabaseId: string, id: string) {
    const userId = await this.resolveUserId(supabaseId);

    const habit = await this.prisma.habit.findUnique({ where: { id } });
    if (!habit) throw new NotFoundException('Habit not found');
    if (habit.userId !== userId) throw new ForbiddenException('Not authorized');

    await this.prisma.habit.delete({ where: { id } });
    await this.cache.del(`user:${userId}:habits`);
    return { success: true };
  }

  async toggle(supabaseId: string, id: string, date: string) {
    const userId = await this.resolveUserId(supabaseId);

    const habit = await this.prisma.habit.findUnique({
      where: { id },
      include: { completions: { where: { date } } },
    });

    if (!habit) throw new NotFoundException('Habit not found');
    if (habit.userId !== userId) throw new ForbiddenException('Not authorized');

    // Determine this habit's eligibility by re-evaluating the full user habit list
    const allHabits = await this.prisma.habit.findMany({
      where: { userId },
      orderBy: { createdAt: 'asc' },
    });
    const enriched = calculateEligibility(allHabits);
    const thisHabit = enriched.find((h) => h.id === id);
    const isXpEligible = thisHabit?.isXpEligible ?? false;
    const xpAmount = thisHabit?.xpValue ?? 0;

    const existingCompletion = habit.completions[0];

    if (existingCompletion) {
      // Un-complete: Remove completion, revoke XP only if habit was XP-eligible
      if (existingCompletion.completed) {
        await this.prisma.habitCompletion.delete({
          where: { id: existingCompletion.id },
        });
        if (isXpEligible && xpAmount > 0) {
          await this.usersService.deductXP(userId, xpAmount, `Removed completion for habit: ${habit.title}`);
        }
      }
    } else {
      // Complete: Add completion, grant XP only if habit is XP-eligible
      await this.prisma.habitCompletion.create({
        data: {
          habitId: id,
          date,
          completed: true,
        },
      });
      if (isXpEligible && xpAmount > 0) {
        await this.usersService.addXP(userId, xpAmount, `Completed habit: ${habit.title}`);
      }
    }

    await this.cache.del(`user:${userId}:habits`);

    // Return updated habit with eligibility info
    const updatedHabit = await this.prisma.habit.findUnique({
      where: { id },
      include: { completions: true },
    });

    return {
      ...updatedHabit,
      difficulty: normaliseComplexity(updatedHabit!.difficulty),
      isXpEligible,
      xpValue: isXpEligible ? xpAmount : 0,
    };
  }
}
