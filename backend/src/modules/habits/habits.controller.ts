import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { HabitsService } from './habits.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('habits')
export class HabitsController {
  constructor(private readonly habitsService: HabitsService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  async findAll(@Request() req: any) {
    return this.habitsService.findAll(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Post()
  async create(@Request() req: any, @Body() body: any) {
    return this.habitsService.create(req.user.id, body);
  }
}
