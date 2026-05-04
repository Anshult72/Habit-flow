import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class LearningService {
  constructor(private prisma: PrismaService) {}
}
