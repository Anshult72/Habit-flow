import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('analytics')
@UseGuards(SupabaseAuthGuard)
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('productivity')
  async getProductivity(@Request() req: any) {
    return this.analyticsService.getProductivityScore(req.user.sub);
  }

  @Get('leaderboard')
  async getLeaderboard() {
    return this.analyticsService.getLeaderboard();
  }

  @Post('focus/session')
  async logFocusSession(@Request() req: any, @Body() body: any) {
    return this.analyticsService.logFocusSession(req.user.sub, body);
  }

  @Get('focus/stats')
  async getFocusStats(@Request() req: any) {
    return this.analyticsService.getFocusStats(req.user.sub);
  }
}
