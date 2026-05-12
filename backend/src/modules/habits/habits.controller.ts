import { Controller, Get, Post, Body, UseGuards, Request, Patch, Delete, Param } from '@nestjs/common';
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

  @UseGuards(SupabaseAuthGuard)
  @Patch(':id')
  async update(@Request() req: any, @Param('id') id: string, @Body() body: any) {
    return this.habitsService.update(req.user.sub, id, body);
  }

  @UseGuards(SupabaseAuthGuard)
  @Delete(':id')
  async delete(@Request() req: any, @Param('id') id: string) {
    return this.habitsService.delete(req.user.sub, id);
  }

  @UseGuards(SupabaseAuthGuard)
  @Post(':id/toggle')
  async toggle(@Request() req: any, @Param('id') id: string, @Body() body: { date: string }) {
    return this.habitsService.toggle(req.user.sub, id, body.date);
  }
}

