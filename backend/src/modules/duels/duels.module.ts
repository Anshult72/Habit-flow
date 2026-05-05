import { Module } from '@nestjs/common';
import { DuelsController } from './duels.controller';
import { DuelsService } from './duels.service';
import { DatabaseModule } from '../../database/database.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [DatabaseModule, NotificationsModule, UsersModule],
  controllers: [DuelsController],
  providers: [DuelsService],
  exports: [DuelsService],
})
export class DuelsModule {}
