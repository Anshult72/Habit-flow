import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { UsersService } from '../users/users.service';
import { CreateSquadDto } from './dto/squad.dto';

@Injectable()
export class SquadsService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
    private usersService: UsersService,
  ) {}

  async createSquad(supabaseId: string, dto: CreateSquadDto) {
    const creator = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!creator) throw new NotFoundException('Creator not found');

    if (creator.xp < dto.entryXP) throw new BadRequestException('Insufficient XP');

    const squad = await this.prisma.squad.create({
      data: {
        name: dto.name,
        createdBy: creator.id,
        entryXP: dto.entryXP,
        durationDays: dto.durationDays,
        status: 'pending',
        members: {
          create: [{ userId: creator.id, role: 'admin' }]
        }
      },
      include: { members: true }
    });

    await this.usersService.deductXP(creator.id, dto.entryXP, `Squad created: ${squad.id}`);

    return squad;
  }

  async inviteUser(supabaseId: string, squadId: string, targetUserId: string) {
    const sender = await this.prisma.user.findUnique({ where: { supabaseId } });
    const receiver = await this.prisma.user.findUnique({ where: { userId: targetUserId } });
    
    if (!sender || !receiver) throw new NotFoundException('User not found');
    
    const squad = await this.prisma.squad.findUnique({ where: { id: squadId } });
    if (!squad) throw new NotFoundException('Squad not found');

    const request = await this.prisma.squadRequest.create({
      data: {
        squadId,
        senderId: sender.id,
        receiverId: receiver.id,
      },
    });

    await this.notificationsService.createNotification(
      receiver.id,
      'squad_request',
      'Squad Invitation!',
      `${sender.name || 'A user'} invited you to join the squad "${squad.name}".`,
      { squadId, requestId: request.id }
    );

    return request;
  }

  async respondToRequest(userSub: string, requestId: string, accept: boolean) {
    const receiver = await this.prisma.user.findUnique({ where: { supabaseId: userSub } });
    if (!receiver) throw new NotFoundException('User not found');

    const request = await this.prisma.squadRequest.findUnique({
      where: { id: requestId },
      include: { squad: true, sender: true }
    });

    if (!request || request.receiverId !== receiver.id) throw new NotFoundException('Request not found');

    if (accept) {
      if (receiver.xp < request.squad.entryXP) throw new BadRequestException('Insufficient XP to join');

      await this.prisma.$transaction([
        this.prisma.squadRequest.update({
          where: { id: requestId },
          data: { status: 'accepted' },
        }),
        this.prisma.squadMember.create({
          data: { userId: receiver.id, squadId: request.squadId },
        }),
      ]);

      await this.usersService.deductXP(receiver.id, request.squad.entryXP, `Joined squad: ${request.squadId}`);

      await this.notificationsService.createNotification(
        request.senderId,
        'squad_accepted',
        'Invitation Accepted!',
        `${receiver.name || 'A user'} joined your squad "${request.squad.name}".`,
        { squadId: request.squadId }
      );
    } else {
      await this.prisma.squadRequest.update({
        where: { id: requestId },
        data: { status: 'declined' },
      });
    }

    return { success: true };
  }

  async getMySquads(supabaseId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) return [];

    return this.prisma.squad.findMany({
      where: {
        OR: [
          { members: { some: { userId: user.id } } },
          { requests: { some: { receiverId: user.id, status: 'pending' } } }
        ]
      },
      include: {
        members: {
          include: { user: { select: { id: true, name: true, avatarUrl: true } } }
        },
        requests: {
          where: { receiverId: user.id, status: 'pending' },
        },
        creator: { select: { name: true } }
      },
      orderBy: { createdAt: 'desc' }
    });
  }

  async joinSquad(supabaseId: string, inviteCode: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');
    
    const squad = await this.prisma.squad.findUnique({ where: { inviteCode } });
    if (!squad) throw new NotFoundException('Squad not found');
    
    const existing = await this.prisma.squadMember.findUnique({
      where: { userId_squadId: { userId: user.id, squadId: squad.id } }
    });
    if (existing) return squad;

    await this.prisma.squadMember.create({
      data: { userId: user.id, squadId: squad.id }
    });

    return squad;
  }

  async deleteSquad(userSub: string, squadId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId: userSub } });
    if (!user) throw new NotFoundException('User not found');

    const squad = await this.prisma.squad.findUnique({
      where: { id: squadId },
      include: { members: true }
    });

    if (!squad) throw new NotFoundException('Squad not found');
    if (squad.createdBy !== user.id) throw new BadRequestException('Only the creator can disband the squad');

    // Refund XP to all current members and notify them
    for (const member of squad.members) {
      await this.usersService.addXP(member.userId, squad.entryXP, `Squad disbanded refund: ${squad.name}`);
      
      await this.notificationsService.createNotification(
        member.userId,
        'squad_disbanded',
        'Squad Disbanded',
        `The squad "${squad.name}" has been disbanded by the creator. Your ${squad.entryXP} XP has been refunded.`,
        { squadId }
      );
    }

    // Delete squad requests and members, then the squad
    await this.prisma.$transaction([
      this.prisma.squadRequest.deleteMany({ where: { squadId } }),
      this.prisma.squadMember.deleteMany({ where: { squadId } }),
      this.prisma.squad.delete({ where: { id: squadId } }),
    ]);

    return { success: true };
  }
}
