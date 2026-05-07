import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { WishlistService } from './wishlist.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('targets')
@UseGuards(SupabaseAuthGuard)
export class WishlistController {
  constructor(private readonly wishlistService: WishlistService) {}

  @Post('auto-sync')
  async autoSync(@Body('url') url: string) {
    return this.wishlistService.autoSync(url);
  }
}
