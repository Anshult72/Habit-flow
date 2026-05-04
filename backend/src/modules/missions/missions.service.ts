import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class MissionsService {
  constructor(private prisma: PrismaService) {}
}
