import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class MissionsService {
  constructor(private prisma: PrismaService) {}

  async findAll(supabaseId: string) {
    return this.prisma.mission.findMany({
      where: { user: { supabaseId } },
      orderBy: { targetDate: 'asc' },
    });
  }

  async create(supabaseId: string, data: any) {
    const user = await this.prisma.user.findUnique({
      where: { supabaseId },
    });

    if (!user) throw new Error('User not found');

    return this.prisma.mission.create({
      data: {
        ...data,
        targetDate: data.targetDate ? new Date(data.targetDate) : null,
        userId: user.id,
      },
    });
  }

  async update(supabaseId: string, id: string, data: any) {
    const user = await this.prisma.user.findUnique({
      where: { supabaseId },
    });

    if (!user) throw new Error('User not found');

    return this.prisma.mission.update({
      where: { id, userId: user.id },
      data: {
        ...data,
        targetDate: data.targetDate ? new Date(data.targetDate) : undefined,
      },
    });
  }

  async delete(supabaseId: string, id: string) {
    const user = await this.prisma.user.findUnique({
      where: { supabaseId },
    });

    if (!user) throw new Error('User not found');

    return this.prisma.mission.delete({
      where: { id, userId: user.id },
    });
  }
}
