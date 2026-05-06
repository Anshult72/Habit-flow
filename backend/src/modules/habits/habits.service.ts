import { Injectable, ForbiddenException, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CacheService } from '../cache/cache.service';

@Injectable()
export class HabitsService {
  constructor(
    private prisma: PrismaService,
    private cache: CacheService,
  ) {}

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

    await this.cache.set(cacheKey, habits, 300);
    return habits;
  }

  async create(supabaseId: string, data: any) {
    const userId = await this.resolveUserId(supabaseId);
    
    const habit = await this.prisma.habit.create({
      data: {
        title: data.title,
        description: data.description || null,
        category: data.category || null,
        color: data.color || '#FF6B2C',
        icon: data.icon || 'Zap',
        frequency: data.frequency || 'Daily',
        difficulty: data.difficulty || 'Medium',
        goal: data.goal ?? 30,
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

    // Whitelist only allowed fields
    const updateData: any = {};
    if (data.title !== undefined) updateData.title = data.title;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.category !== undefined) updateData.category = data.category;
    if (data.color !== undefined) updateData.color = data.color;
    if (data.icon !== undefined) updateData.icon = data.icon;
    if (data.frequency !== undefined) updateData.frequency = data.frequency;
    if (data.difficulty !== undefined) updateData.difficulty = data.difficulty;
    if (data.goal !== undefined) updateData.goal = data.goal;

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
}
