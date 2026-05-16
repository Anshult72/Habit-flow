import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class PlannerService {
  constructor(private prisma: PrismaService) {}

  private readonly defaultSlots = [
    '6 AM – 9 AM',
    '9 AM – 12 PM',
    '12 PM – 3 PM',
    '3 PM – 6 PM',
    '6 PM – 9 PM',
    '9 PM – 12 AM',
  ];

  async getDay(supabaseId: string, date: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    let plannerDay = await this.prisma.plannerDay.findUnique({
      where: { userId_date: { userId: user.id, date } },
      include: {
        slots: {
          include: {
            tasks: {
              orderBy: { order: 'asc' },
            },
          },
        },
      },
    });

    if (!plannerDay) {
      plannerDay = await this.prisma.plannerDay.create({
        data: {
          date,
          userId: user.id,
          slots: {
            create: this.defaultSlots.map((s) => ({ timeRange: s })),
          },
        },
        include: {
          slots: {
            include: {
              tasks: true,
            },
          },
        },
      });
    }

    return plannerDay;
  }

  async addTask(supabaseId: string, slotId: string, title: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    const slot = await this.prisma.plannerSlot.findUnique({
      where: { id: slotId },
      include: { day: true },
    });

    if (!slot) throw new NotFoundException('Slot not found');
    if (slot.day.userId !== user.id) throw new Error('Unauthorized');

    return this.prisma.plannerTask.create({
      data: {
        title,
        slotId,
      },
    });
  }

  async updateTask(supabaseId: string, taskId: string, data: any) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    const task = await this.prisma.plannerTask.findUnique({
      where: { id: taskId },
      include: { slot: { include: { day: true } } },
    });

    if (!task) throw new NotFoundException('Task not found');
    if (task.slot.day.userId !== user.id) throw new Error('Unauthorized');

    return this.prisma.plannerTask.update({
      where: { id: taskId },
      data,
    });
  }

  async deleteTask(supabaseId: string, taskId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    const task = await this.prisma.plannerTask.findUnique({
      where: { id: taskId },
      include: { slot: { include: { day: true } } },
    });

    if (!task) throw new NotFoundException('Task not found');
    if (task.slot.day.userId !== user.id) throw new Error('Unauthorized');

    return this.prisma.plannerTask.delete({
      where: { id: taskId },
    });
  }
}
