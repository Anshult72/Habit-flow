import { Controller, Get, Post, Body, UseGuards, Request, Patch, Delete, Param } from '@nestjs/common';
import { WishlistService } from './wishlist.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('targets')
@UseGuards(SupabaseAuthGuard)
export class WishlistController {
  constructor(private readonly wishlistService: WishlistService) {}

  @Get()
  async findAll(@Request() req: any) {
    return this.wishlistService.findAll(req.user.sub);
  }

  @Post()
  async create(@Request() req: any, @Body() body: any) {
    return this.wishlistService.create(req.user.sub, body);
  }

  @Patch(':id')
  async update(@Request() req: any, @Param('id') id: string, @Body() body: any) {
    return this.wishlistService.update(req.user.sub, id, body);
  }

  @Delete(':id')
  async delete(@Request() req: any, @Param('id') id: string) {
    return this.wishlistService.delete(req.user.sub, id);
  }

  @Post('auto-sync')
  async autoSync(@Body('url') url: string) {
    return this.wishlistService.autoSync(url);
  }
}
