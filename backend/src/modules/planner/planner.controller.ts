import { Controller, Get, Post, Body, Param, UseGuards, Request, Patch, Delete } from '@nestjs/common';
import { PlannerService } from './planner.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('planner')
@UseGuards(SupabaseAuthGuard)
export class PlannerController {
  constructor(private readonly plannerService: PlannerService) {}

  @Get(':date')
  async getDay(@Request() req: any, @Param('date') date: string) {
    return this.plannerService.getDay(req.user.sub, date);
  }

  @Post('task')
  async addTask(@Request() req: any, @Body() body: { slotId: string; title: string }) {
    return this.plannerService.addTask(req.user.sub, body.slotId, body.title);
  }

  @Patch('task/:id')
  async updateTask(@Request() req: any, @Param('id') id: string, @Body() body: any) {
    return this.plannerService.updateTask(req.user.sub, id, body);
  }

  @Delete('task/:id')
  async deleteTask(@Request() req: any, @Param('id') id: string) {
    return this.plannerService.deleteTask(req.user.sub, id);
  }
}
