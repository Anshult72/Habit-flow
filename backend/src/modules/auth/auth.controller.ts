import { Controller, Get, UseGuards, Req } from '@nestjs/common';
import { AuthService } from './auth.service';
import { SupabaseAuthGuard } from './guards/supabase-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * GET /api/auth/me
   *
   * Called by the frontend after login.
   * - Verifies the Supabase token
   * - Syncs user into the local DB (find-or-create)
   * - Returns the local user profile
   */
  @UseGuards(SupabaseAuthGuard)
  @Get('me')
  async me(@Req() req: any) {
    const { sub, email, user_metadata } = req.user;
    const user = await this.authService.syncUser(sub, email, user_metadata);
    return { success: true, user };
  }
}
