import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { MatrixService } from './matrix.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('matrix')
@UseGuards(SupabaseAuthGuard)
export class MatrixController {
  constructor(private readonly matrixService: MatrixService) {}

  @Get()
  findAll(@Request() req: any) {
    return this.matrixService.findAll(req.user.sub);
  }

  @Post()
  create(@Request() req: any, @Body() body: any) {
    return this.matrixService.create(req.user.sub, body);
  }

  @Patch(':id')
  update(@Request() req: any, @Param('id') id: string, @Body() body: any) {
    return this.matrixService.update(req.user.sub, id, body);
  }

  @Delete(':id')
  remove(@Request() req: any, @Param('id') id: string) {
    return this.matrixService.remove(req.user.sub, id);
  }
}
