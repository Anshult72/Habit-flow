import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @UseGuards(SupabaseAuthGuard)
  @Get('productivity')
  async getProductivity(@Request() req: any) {
    return this.analyticsService.getProductivityScore(req.user.sub);
  }
}
