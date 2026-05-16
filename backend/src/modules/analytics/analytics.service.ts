import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService) {}

  async getProductivityScore(userId: string) {
    const today = new Date().toISOString().split('T')[0];
    
    // Get Habits
    const habitsCount = await this.prisma.habit.count({ where: { userId } });
    const completionsCount = await this.prisma.habitCompletion.count({
      where: { habit: { userId }, date: today, completed: true }
    });

    // Get Matrix Tasks
    const allTasksCount = await this.prisma.matrixTask.count({ where: { userId } });
    const completedTasksCount = await this.prisma.matrixTask.count({ where: { userId, completed: true } });

    // Focus Sessions today
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const focusSessionsCount = await this.prisma.focusSession.count({
      where: { userId, date: { gte: startOfDay } }
    });

    const totalActions = habitsCount + allTasksCount + 1; // +1 for baseline
    const completedActions = completionsCount + completedTasksCount + focusSessionsCount;

    if (totalActions === 0 || totalActions === 1) return { score: 0 };

    const score = Math.round((completedActions / totalActions) * 100);
    return { score: Math.min(score, 100) };
  }

  async getLeaderboard() {
    const topUsers = await this.prisma.user.findMany({
      take: 50,
      orderBy: [
        { xp: 'desc' },
        { level: 'desc' },
      ],
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        xp: true,
        level: true,
      },
    });

    return topUsers.map((user, index) => ({
      ...user,
      rank: index + 1,
    }));
  async logFocusSession(supabaseId: string, data: { type: string; duration: number; xpEarned: number; rating?: number }) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    const session = await this.prisma.focusSession.create({
      data: {
        ...data,
        userId: user.id,
      },
    });

    // Update user XP
    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        xp: { increment: data.xpEarned },
      },
    });

    return session;
  }

  async getFocusStats(supabaseId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const sessionsToday = await this.prisma.focusSession.findMany({
      where: {
        userId: user.id,
        date: { gte: startOfDay },
      },
    });

    const totalMinutes = Math.round(sessionsToday.reduce((acc, s) => acc + s.duration, 0) / 60);
    const sessionCount = sessionsToday.length;

    return {
      totalMinutes,
      sessionCount,
      streak: user.onboardingDay, // Placeholder for actual focus streak if we implement it
    };
  }
}
