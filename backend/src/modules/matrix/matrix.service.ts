import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class MatrixService {
  constructor(private prisma: PrismaService) {}

  async findAll(supabaseId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    return this.prisma.matrixTask.findMany({
      where: { userId: user.id },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(supabaseId: string, data: any) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    return this.prisma.matrixTask.create({
      data: {
        ...data,
        dueDate: data.dueDate ? new Date(data.dueDate) : null,
        userId: user.id,
      },
    });
  }

  async update(supabaseId: string, id: string, data: any) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    const task = await this.prisma.matrixTask.findUnique({ where: { id } });
    if (!task || task.userId !== user.id) throw new NotFoundException('Task not found');

    return this.prisma.matrixTask.update({
      where: { id },
      data: {
        ...data,
        dueDate: data.dueDate ? new Date(data.dueDate) : undefined,
      },
    });
  }

  async remove(supabaseId: string, id: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    const task = await this.prisma.matrixTask.findUnique({ where: { id } });
    if (!task || task.userId !== user.id) throw new NotFoundException('Task not found');

    return this.prisma.matrixTask.delete({ where: { id } });
  }
}
