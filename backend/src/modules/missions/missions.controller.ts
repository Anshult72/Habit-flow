import { Controller, Get, Post, Body, UseGuards, Request, Patch, Delete, Param } from '@nestjs/common';
import { MissionsService } from './missions.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('missions')
export class MissionsController {
  constructor(private readonly missionsService: MissionsService) {}

  @UseGuards(SupabaseAuthGuard)
  @Get()
  async findAll(@Request() req: any) {
    return this.missionsService.findAll(req.user.sub);
  }

  @UseGuards(SupabaseAuthGuard)
  @Post()
  async create(@Request() req: any, @Body() body: any) {
    return this.missionsService.create(req.user.sub, body);
  }

  @UseGuards(SupabaseAuthGuard)
  @Patch(':id')
  async update(@Request() req: any, @Param('id') id: string, @Body() body: any) {
    return this.missionsService.update(req.user.sub, id, body);
  }

  @UseGuards(SupabaseAuthGuard)
  @Delete(':id')
  async delete(@Request() req: any, @Param('id') id: string) {
    return this.missionsService.delete(req.user.sub, id);
  }
}
