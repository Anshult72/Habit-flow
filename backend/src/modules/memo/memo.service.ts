import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class MemoService {
  constructor(private prisma: PrismaService) {}

  async findAll(supabaseId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    return this.prisma.memo.findMany({
      where: { userId: user.id },
      orderBy: [
        { isPinned: 'desc' },
        { createdAt: 'desc' },
      ],
    });
  }

  async create(supabaseId: string, data: any) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    return this.prisma.memo.create({
      data: {
        ...data,
        userId: user.id,
      },
    });
  }

  async update(supabaseId: string, id: string, data: any) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    const memo = await this.prisma.memo.findUnique({ where: { id } });
    if (!memo || memo.userId !== user.id) throw new NotFoundException('Memo not found');

    return this.prisma.memo.update({
      where: { id },
      data,
    });
  }

  async remove(supabaseId: string, id: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    const memo = await this.prisma.memo.findUnique({ where: { id } });
    if (!memo || memo.userId !== user.id) throw new NotFoundException('Memo not found');

    return this.prisma.memo.delete({ where: { id } });
  }
}
