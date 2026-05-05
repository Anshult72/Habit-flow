import { Module } from '@nestjs/common';
import { SquadsController } from './squads.controller';
import { SquadsService } from './squads.service';
import { DatabaseModule } from '../../database/database.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [DatabaseModule, NotificationsModule, UsersModule],
  controllers: [SquadsController],
  providers: [SquadsService],
  exports: [SquadsService],
})
export class SquadsModule {}
