import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { MemoService } from './memo.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('memos')
@UseGuards(SupabaseAuthGuard)
export class MemoController {
  constructor(private readonly memoService: MemoService) {}

  @Get()
  findAll(@Request() req: any) {
    return this.memoService.findAll(req.user.sub);
  }

  @Post()
  create(@Request() req: any, @Body() body: any) {
    return this.memoService.create(req.user.sub, body);
  }

  @Patch(':id')
  update(@Request() req: any, @Param('id') id: string, @Body() body: any) {
    return this.memoService.update(req.user.sub, id, body);
  }

  @Delete(':id')
  remove(@Request() req: any, @Param('id') id: string) {
    return this.memoService.remove(req.user.sub, id);
  }
}
