import { Controller, Get, Patch, Body, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@UseGuards(SupabaseAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('profile')
  async getProfile(@Req() req: any) {
    const supabaseId = req.user.sub;
    const user = await this.usersService.findBySupabaseId(supabaseId);
    return user;
  }

  @Patch('profile')
  async updateProfile(@Req() req: any, @Body() dto: UpdateProfileDto) {
    const supabaseId = req.user.sub;
    return this.usersService.updateProfile(supabaseId, {
      ...dto,
      dob: dto.dob ? new Date(dto.dob) : undefined,
    });
  }
}

