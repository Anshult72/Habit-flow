import { Controller, Post, Get, Delete, Param, UseGuards, Request, Body } from '@nestjs/common';
import { SquadsService } from './squads.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';
import { CreateSquadDto } from './dto/squad.dto';

@Controller('squads')
@UseGuards(SupabaseAuthGuard)
export class SquadsController {
  constructor(private readonly squadsService: SquadsService) {}

  @Get()
  async getMySquads(@Request() req: any) {
    return this.squadsService.getMySquads(req.user.sub);
  }

  @Post()
  async createSquad(@Request() req: any, @Body() dto: CreateSquadDto) {
    return this.squadsService.createSquad(req.user.sub, dto);
  }

  @Post(':id/invite')
  async inviteUser(
    @Request() req: any,
    @Param('id') id: string,
    @Body('targetUserId') targetUserId: string,
  ) {
    return this.squadsService.inviteUser(req.user.sub, id, targetUserId);
  }

  @Post('requests/:id/respond')
  async respondToRequest(
    @Request() req: any,
    @Param('id') id: string,
    @Body('accept') accept: boolean,
  ) {
    return this.squadsService.respondToRequest(req.user.sub, id, accept);
  }

  @Post('join/:inviteCode')
  async joinSquad(@Request() req: any, @Param('inviteCode') inviteCode: string) {
    return this.squadsService.joinSquad(req.user.sub, inviteCode);
  }

  @Delete(':id')
  async deleteSquad(@Request() req: any, @Param('id') id: string) {
    return this.squadsService.deleteSquad(req.user.sub, id);
  }
}
