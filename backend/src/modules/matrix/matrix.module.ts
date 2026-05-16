import { Module } from '@nestjs/common';
import { MatrixService } from './matrix.service';
import { MatrixController } from './matrix.controller';
import { PrismaModule } from '../../database/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [MatrixController],
  providers: [MatrixService],
  exports: [MatrixService],
})
export class MatrixModule {}
