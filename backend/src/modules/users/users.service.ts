import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { User } from '@prisma/client';
import * as crypto from 'crypto';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class UsersService implements OnModuleInit {
  private readonly logger = new Logger(UsersService.name);

  constructor(private prisma: PrismaService) {}

  async onModuleInit() {
    await this.cleanResetTestingData();
    await this.migrateExistingUsers();
    await this.migrateHabitComplexityLabels();
  }

  private generateSecureUserId(): string {
    const bytes = crypto.randomBytes(4);
    const num = bytes.readUInt32BE(0);
    // Ensure 8 digits: 10,000,000 to 99,999,999
    return ((num % 90000000) + 10000000).toString();
  }

  private isWeakUserId(id: string): boolean {
    const sequences = [
      '01234567', '12345678', '23456789', '34567890',
      '98765432', '87654321', '76543210', '09876543'
    ];
    
    return (
      /^(\d)\1+$/.test(id) || // All same digits (11111111)
      sequences.some(seq => id.includes(seq)) || // Common sequences
      /(\d)\1{2,}/.test(id) || // 3+ repeating digits (111...)
      /(\d{2})\1{2,}/.test(id) // Repeating pairs (121212...)
    );
  }

  async createPremiumUserId(): Promise<string> {
    let userId = '';
    let exists = true;
    let attempts = 0;

    while (exists && attempts < 100) {
      attempts++;
      userId = this.generateSecureUserId();
      if (this.isWeakUserId(userId)) continue;

      const user = await this.prisma.user.findUnique({
        where: { userId },
      });
      if (!user) exists = false;
    }

    if (attempts >= 100) {
      throw new Error('Failed to generate a unique, non-weak User ID after 100 attempts.');
    }

    return userId;
  }

  async migrateExistingUsers() {
    this.logger.log('Checking for users requiring ID migration...');
    // We fetch all users and filter in memory to check length/patterns
    const allUsers = await this.prisma.user.findMany();
    
    const usersToMigrate = allUsers.filter(u => 
      !u.userId || u.userId.length !== 8 || this.isWeakUserId(u.userId)
    );

    if (usersToMigrate.length === 0) {
      this.logger.log('All users have valid 8-digit IDs.');
      return;
    }

    this.logger.log(`Migrating ${usersToMigrate.length} users...`);
    for (const user of usersToMigrate) {
      const newId = await this.createPremiumUserId();
      await this.prisma.user.update({
        where: { id: user.id },
        data: { userId: newId }
      });
      this.logger.log(`User ${user.email} migrated to ID: ${newId}`);
    }
    this.logger.log('Migration complete.');
  }

  /**
   * Self-healing startup migration for Habit complexity labels.
   * Safely maps deprecated values (easy/medium/hard) to canonical
   * new values (Basic/Standard/Advanced) without touching Elite habits.
   * Runs idempotently — already-migrated records are left unchanged.
   */
  private async migrateHabitComplexityLabels() {
    this.logger.log('Checking Habit complexity labels for migration...');

    const labelMap: Record<string, string> = {
      easy: 'Basic',
      Easy: 'Basic',
      medium: 'Standard',
      Medium: 'Standard',
      hard: 'Advanced',
      Hard: 'Advanced',
    };

    let migratedCount = 0;
    for (const [oldLabel, newLabel] of Object.entries(labelMap)) {
      const result = await this.prisma.habit.updateMany({
        where: { difficulty: oldLabel },
        data: { difficulty: newLabel },
      });
      migratedCount += result.count;
    }

    if (migratedCount > 0) {
      this.logger.log(`Migrated ${migratedCount} habit(s) to new complexity labels.`);
    } else {
      this.logger.log('All Habit complexity labels are up-to-date.');
    }
  }

  async findOne(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async findByUserId(userId: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { userId },
    });
  }

  async findBySupabaseId(supabaseId: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { supabaseId },
    });
  }

  async linkSupabaseId(id: string, supabaseId: string): Promise<User> {
    return this.prisma.user.update({
      where: { id },
      data: { supabaseId },
    });
  }

  async updateAvatarUrl(supabaseId: string, avatarUrl: string): Promise<User> {
    return this.prisma.user.update({
      where: { supabaseId },
      data: { avatarUrl },
    });
  }

  async create(data: any): Promise<User> {
    const userId = await this.createPremiumUserId();
    return this.prisma.user.create({
      data: {
        ...data,
        userId,
      },
    });
  }

  async updateProfile(supabaseId: string, data: {
    name?: string;
    dob?: Date;
    city?: string;
    state?: string;
    avatarUrl?: string;
  }): Promise<User> {
    return this.prisma.user.update({
      where: { supabaseId },
      data,
    });
  }

  getXpThresholdForLevel(level: number): number {
    if (level <= 1) return 0;
    return 12.5 * level * (level + 1) - 25;
  }

  getLevelForXp(xp: number): number {
    if (xp <= 0) return 1;
    let level = 1;
    while (xp >= this.getXpThresholdForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  async cleanResetTestingData() {
    const sentinelPath = path.join(__dirname, '..', '..', '..', '.clean-reset-done');
    if (fs.existsSync(sentinelPath)) {
      this.logger.log('Clean reset sentinel file exists, skipping database wipe.');
      return;
    }

    this.logger.log('Sentinel file not found. Performing full clean database reset for internal testing accounts...');

    try {
      await this.prisma.$transaction([
        this.prisma.duelParticipant.deleteMany(),
        this.prisma.duelRequest.deleteMany(),
        this.prisma.duel.deleteMany(),
        this.prisma.squadMember.deleteMany(),
        this.prisma.squadRequest.deleteMany(),
        this.prisma.squad.deleteMany(),
        this.prisma.xPLog.deleteMany(),
        this.prisma.habitCompletion.deleteMany(),
        this.prisma.focusSession.deleteMany(),
        this.prisma.notification.deleteMany(),
        this.prisma.user.updateMany({
          data: {
            xp: 0,
            level: 1,
            streakShields: 2,
          },
        }),
      ]);

      fs.writeFileSync(sentinelPath, `Reset performed at: ${new Date().toISOString()}`);
      this.logger.log('Clean database reset successfully executed. Sentinel file written.');
    } catch (error) {
      this.logger.error('Failed to perform clean database reset:', error);
    }
  }

  async deductXP(userId: string, amount: number, reason: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { xp: true },
    });
    if (!user) throw new Error('User not found');

    const actualDeduction = Math.min(amount, user.xp);
    if (actualDeduction <= 0) return;

    const newXp = user.xp - actualDeduction;
    const newLevel = this.getLevelForXp(newXp);

    return this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: {
          xp: newXp,
          level: newLevel,
        },
      }),
      this.prisma.xPLog.create({
        data: {
          userId,
          amount: -actualDeduction,
          date: new Date().toISOString().split('T')[0],
        },
      }),
    ]);
  }

  async addXP(userId: string, amount: number, reason: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { xp: true, level: true },
    });
    if (!user) throw new Error('User not found');

    const newXp = Math.max(0, user.xp + amount);
    const newLevel = this.getLevelForXp(newXp);

    const oldLevel = user.level;
    const isLevelUp = newLevel > oldLevel;

    const result = await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: {
          xp: newXp,
          level: newLevel,
        },
      }),
      this.prisma.xPLog.create({
        data: {
          userId,
          amount,
          date: new Date().toISOString().split('T')[0],
        },
      }),
    ]);

    if (isLevelUp) {
      try {
        await this.prisma.notification.create({
          data: {
            userId,
            title: 'Level Up!',
            message: `Congratulations! You have reached Level ${newLevel}! Keep up the great work!`,
            type: 'level_up',
            isRead: false,
          },
        });
      } catch (err) {
        this.logger.error('Failed to create level-up notification', err);
      }
    }

    return result;
  }
}
