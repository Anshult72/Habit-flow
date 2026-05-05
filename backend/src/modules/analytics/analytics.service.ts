import { Injectable } from '@nestjs/common';
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
}
