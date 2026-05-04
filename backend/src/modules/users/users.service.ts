import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { User } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

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

  async findBySupabaseId(supabaseId: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { supabaseId },
    });
  }

  async linkSupabaseId(userId: string, supabaseId: string): Promise<User> {
    return this.prisma.user.update({
      where: { id: userId },
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
    return this.prisma.user.create({
      data,
    });
  }
}
