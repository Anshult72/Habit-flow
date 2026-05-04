import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

/**
 * SupabaseAuthGuard — verifies the Supabase JWT from the Authorization header.
 *
 * On success it attaches the full Supabase user object to `request.user`.
 * Usage: @UseGuards(SupabaseAuthGuard)
 */
@Injectable()
export class SupabaseAuthGuard implements CanActivate {
  private supabase: SupabaseClient;
  private readonly logger = new Logger(SupabaseAuthGuard.name);

  constructor(private readonly config: ConfigService) {
    this.supabase = createClient(
      this.config.get<string>('SUPABASE_URL')!,
      this.config.get<string>('SUPABASE_SERVICE_ROLE_KEY')!,
    );
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);

    if (!token) {
      throw new UnauthorizedException('Missing authorization token');
    }

    try {
      const {
        data: { user },
        error,
      } = await this.supabase.auth.getUser(token);

      if (error || !user) {
        this.logger.warn(`Token verification failed: ${error?.message}`);
        throw new UnauthorizedException('Invalid or expired token');
      }

      // Attach user to request — downstream controllers can use req.user
      request.user = {
        sub: user.id,
        email: user.email,
        user_metadata: user.user_metadata,
        app_metadata: user.app_metadata,
      };

      return true;
    } catch (err) {
      if (err instanceof UnauthorizedException) throw err;
      this.logger.error('Unexpected auth error', err);
      throw new UnauthorizedException('Authentication failed');
    }
  }

  private extractToken(request: any): string | null {
    const authHeader = request.headers.authorization;
    if (!authHeader) return null;
    const [type, token] = authHeader.split(' ');
    return type === 'Bearer' ? token : null;
  }
}
