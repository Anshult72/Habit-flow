import { Controller, Post, Get, Delete, Param, UseGuards, Request, Body } from '@nestjs/common';
import { DuelsService } from './duels.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';
import { CreateChallengeDto } from './dto/challenge.dto';

@Controller('duels')
@UseGuards(SupabaseAuthGuard)
export class DuelsController {
  constructor(private readonly duelsService: DuelsService) {}

  @Get()
  async getMyDuels(@Request() req: any) {
    return this.duelsService.getMyDuels(req.user.sub);
  }

  @Post('challenge')
  async createChallenge(@Request() req: any, @Body() dto: CreateChallengeDto) {
    return this.duelsService.createChallenge(req.user.sub, dto);
  }

  @Post('requests/:id/respond')
  async respondToRequest(
    @Request() req: any,
    @Param('id') id: string,
    @Body('accept') accept: boolean,
  ) {
    return this.duelsService.respondToRequest(req.user.sub, id, accept);
  }

  @Post('join/:inviteCode')
  async joinDuel(@Request() req: any, @Param('inviteCode') inviteCode: string) {
    return this.duelsService.joinDuel(req.user.sub, inviteCode);
  }

  @Delete(':id')
  async deleteDuel(@Request() req: any, @Param('id') id: string) {
    return this.duelsService.cancelDuel(req.user.sub, id);
  }
}
