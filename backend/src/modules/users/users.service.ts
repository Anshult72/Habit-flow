import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { User } from '@prisma/client';
import * as crypto from 'crypto';

@Injectable()
export class UsersService implements OnModuleInit {
  private readonly logger = new Logger(UsersService.name);

  constructor(private prisma: PrismaService) {}

  async onModuleInit() {
    await this.migrateExistingUsers();
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

  async deductXP(userId: string, amount: number, reason: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user || user.xp < amount) throw new Error('Insufficient XP');

    return this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: { xp: { decrement: amount } },
      }),
      this.prisma.xPLog.create({
        data: {
          userId,
          amount: -amount,
          date: new Date().toISOString().split('T')[0],
        },
      }),
    ]);
  }

  async addXP(userId: string, amount: number, reason: string) {
    return this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: { xp: { increment: amount } },
      }),
      this.prisma.xPLog.create({
        data: {
          userId,
          amount,
          date: new Date().toISOString().split('T')[0],
        },
      }),
    ]);
  }
}
