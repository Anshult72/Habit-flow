import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { UsersService } from '../users/users.service';
import { CreateChallengeDto } from './dto/challenge.dto';

@Injectable()
export class DuelsService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
    private usersService: UsersService,
  ) {}

  async createChallenge(senderSub: string, dto: CreateChallengeDto) {
    const sender = await this.prisma.user.findUnique({ where: { supabaseId: senderSub } });
    if (!sender) throw new NotFoundException('Sender not found');
    
    const opponent = await this.prisma.user.findUnique({ where: { userId: dto.targetUserId } });
    if (!opponent) throw new NotFoundException('Opponent not found');
    if (opponent.id === sender.id) throw new BadRequestException('Cannot challenge yourself');
    
    if (sender.xp < dto.entryXP) throw new BadRequestException('Insufficient XP');

    // Create duel in pending status
    const duel = await this.prisma.duel.create({
      data: {
        createdBy: sender.id,
        opponentId: opponent.id,
        entryXP: dto.entryXP,
        durationDays: dto.durationDays,
        status: 'pending',
      },
    });

    // Create duel request
    const request = await this.prisma.duelRequest.create({
      data: {
        duelId: duel.id,
        senderId: sender.id,
        receiverId: opponent.id,
        status: 'pending',
      },
    });

    // Notify opponent
    await this.notificationsService.createNotification(
      opponent.id,
      'duel_request',
      'New Duel Challenge!',
      `${sender.name || 'A user'} has challenged you to a ${dto.durationDays}-day duel for ${dto.entryXP} XP.`,
      { duelId: duel.id, requestId: request.id }
    );

    return { duel, request };
  }

  async respondToRequest(userSub: string, requestId: string, accept: boolean) {
    const receiver = await this.prisma.user.findUnique({ where: { supabaseId: userSub } });
    if (!receiver) throw new NotFoundException('User not found');

    const request = await this.prisma.duelRequest.findUnique({
      where: { id: requestId },
      include: { duel: true, sender: true }
    });

    if (!request || request.receiverId !== receiver.id) throw new NotFoundException('Request not found');
    if (request.status !== 'pending') throw new BadRequestException('Request already handled');

    if (accept) {
      if (receiver.xp < request.duel.entryXP) throw new BadRequestException('Insufficient XP to accept');

      // 1. Update request and duel
      await this.prisma.$transaction([
        this.prisma.duelRequest.update({
          where: { id: requestId },
          data: { status: 'accepted' },
        }),
        this.prisma.duel.update({
          where: { id: request.duelId },
          data: {
            status: 'active',
            startDate: new Date(),
            endDate: new Date(Date.now() + request.duel.durationDays * 24 * 60 * 60 * 1000),
          },
        }),
        this.prisma.duelParticipant.createMany({
          data: [
            { userId: request.senderId, duelId: request.duelId },
            { userId: receiver.id, duelId: request.duelId },
          ],
        }),
      ]);

      // 2. Deduct XP from both
      await this.usersService.deductXP(request.senderId, request.duel.entryXP, `Duel started: ${request.duelId}`);
      await this.usersService.deductXP(receiver.id, request.duel.entryXP, `Duel accepted: ${request.duelId}`);

      // 3. Notify sender
      await this.notificationsService.createNotification(
        request.senderId,
        'duel_accepted',
        'Challenge Accepted!',
        `${receiver.name || 'The opponent'} has accepted your duel challenge. Let the competition begin!`,
        { duelId: request.duelId }
      );
    } else {
      await this.prisma.$transaction([
        this.prisma.duelRequest.update({
          where: { id: requestId },
          data: { status: 'declined' },
        }),
        this.prisma.duel.update({
          where: { id: request.duelId },
          data: { status: 'declined' },
        }),
      ]);

      await this.notificationsService.createNotification(
        request.senderId,
        'duel_declined',
        'Challenge Declined',
        `${receiver.name || 'The opponent'} declined your duel challenge.`,
        { duelId: request.duelId }
      );
    }

    return { success: true };
  }

  async getMyDuels(supabaseId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) return [];

    return this.prisma.duel.findMany({
      where: {
        OR: [
          { participants: { some: { userId: user.id } } },
          { createdBy: user.id },
          { opponentId: user.id },
        ],
      },
      include: {
        participants: {
          include: { user: { select: { id: true, name: true, avatarUrl: true } } },
        },
        creator: { select: { name: true, userId: true } },
        opponent: { select: { name: true, userId: true } },
        requests: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  // Legacy/Helper for invite code joining
  async joinDuel(supabaseId: string, inviteCode: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');
    
    const duel = await this.prisma.duel.findUnique({ where: { inviteCode } });
    if (!duel) throw new NotFoundException('Duel not found');
    
    const existing = await this.prisma.duelParticipant.findUnique({
      where: { userId_duelId: { userId: user.id, duelId: duel.id } }
    });
    if (existing) return duel;

    await this.prisma.duelParticipant.create({
      data: { userId: user.id, duelId: duel.id }
    });

    return duel;
  }

  async cancelDuel(userSub: string, duelId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId: userSub } });
    if (!user) throw new NotFoundException('User not found');

    const duel = await this.prisma.duel.findUnique({
      where: { id: duelId },
      include: { requests: true, participants: true }
    });

    if (!duel) throw new NotFoundException('Duel not found');
    if (duel.createdBy !== user.id) throw new BadRequestException('Only the creator can cancel the duel');

    if (duel.status === 'pending') {
      // Delete duel and requests
      await this.prisma.$transaction([
        this.prisma.duelRequest.deleteMany({ where: { duelId } }),
        this.prisma.duel.delete({ where: { id: duelId } }),
      ]);

      // Notify opponent if assigned
      if (duel.opponentId) {
        await this.notificationsService.createNotification(
          duel.opponentId,
          'duel_cancelled',
          'Challenge Cancelled',
          `${user.name || 'The sender'} has cancelled the duel challenge.`,
          { duelId }
        );
      }
    } else if (duel.status === 'active') {
      // Mark as cancelled and refund XP
      await this.prisma.$transaction([
        this.prisma.duel.update({
          where: { id: duelId },
          data: { status: 'cancelled' },
        }),
      ]);

      // Refund XP to all participants
      for (const p of duel.participants) {
        await this.usersService.addXP(p.userId, duel.entryXP, `Duel cancelled refund: ${duelId}`);
        
        await this.notificationsService.createNotification(
          p.userId,
          'duel_cancelled',
          'Duel Cancelled',
          `The duel has been cancelled by the creator. Your ${duel.entryXP} XP has been refunded.`,
          { duelId }
        );
      }
    } else if (duel.status === 'completed') {
      throw new BadRequestException('Cannot delete a completed duel');
    } else {
      // Just delete for other statuses like declined
      await this.prisma.$transaction([
        this.prisma.duelRequest.deleteMany({ where: { duelId } }),
        this.prisma.duel.delete({ where: { id: duelId } }),
      ]);
    }

    return { success: true };
  }
}
