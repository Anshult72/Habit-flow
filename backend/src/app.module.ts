import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DatabaseModule } from './database/database.module';
import { RedisCacheModule } from './modules/cache/cache.module';
import { StorageModule } from './modules/storage/storage.module';
import { EmailModule } from './modules/email/email.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { HabitsModule } from './modules/habits/habits.module';
import { PlannerModule } from './modules/planner/planner.module';
import { LearningModule } from './modules/learning/learning.module';
import { MemoModule } from './modules/memo/memo.module';
import { WishlistModule } from './modules/wishlist/wishlist.module';
import { MissionsModule } from './modules/missions/missions.module';
import { ResourcesModule } from './modules/resources/resources.module';
import { AnalyticsModule } from './modules/analytics/analytics.module';
import { DuelsModule } from './modules/duels/duels.module';
import { SquadsModule } from './modules/squads/squads.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { MatrixModule } from './modules/matrix/matrix.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    DatabaseModule,
    RedisCacheModule,
    StorageModule,
    EmailModule,
    AuthModule,
    UsersModule,
    HabitsModule,
    PlannerModule,
    LearningModule,
    MemoModule,
    WishlistModule,
    MissionsModule,
    ResourcesModule,
    AnalyticsModule,
    DuelsModule,
    SquadsModule,
    NotificationsModule,
    MatrixModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
