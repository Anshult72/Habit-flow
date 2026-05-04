import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CacheService } from '../cache/cache.service';

@Injectable()
export class HabitsService {
  constructor(
    private prisma: PrismaService,
    private cache: CacheService,
  ) {}

  async findAll(userId: string) {
    const cacheKey = `user:${userId}:habits`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const habits = await this.prisma.habit.findMany({
      where: { userId },
      include: { completions: true },
    });

    await this.cache.set(cacheKey, habits, 300); // 5 min cache
    return habits;
  }

  async create(userId: string, data: any) {
    const habit = await this.prisma.habit.create({
      data: {
        ...data,
        userId,
      },
    });
    await this.cache.del(`user:${userId}:habits`);
    return habit;
  }
}
