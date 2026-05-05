import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { HabitsService } from './habits.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('habits')
export class HabitsController {
  constructor(private readonly habitsService: HabitsService) {}

  @UseGuards(SupabaseAuthGuard)
  @Get()
  async findAll(@Request() req: any) {
    return this.habitsService.findAll(req.user.sub);
  }

  @UseGuards(SupabaseAuthGuard)
  @Post()
  async create(@Request() req: any, @Body() body: any) {
    return this.habitsService.create(req.user.sub, body);
  }
}

