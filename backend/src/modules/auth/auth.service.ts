import { Injectable, Logger } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { EmailService } from '../email/email.service';

/**
 * AuthService — handles user synchronisation between Supabase Auth and our database.
 *
 * On every authenticated request the controller can call `syncUser()` to ensure
 * the Supabase user has a matching row in our PostgreSQL `User` table.
 */
@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly usersService: UsersService,
    private readonly emailService: EmailService,
  ) {}

  /**
   * Find-or-create a local DB user that matches the Supabase auth user.
   *
   * @param supabaseId   The Supabase user UUID (`sub`)
   * @param email        Email from the JWT
   * @param metadata     user_metadata from Supabase (contains name, avatar, etc.)
   */
  async syncUser(supabaseId: string, email?: string, metadata?: Record<string, any>) {
    // 1. Try to find existing user by supabaseId
    let user = await this.usersService.findBySupabaseId(supabaseId);

    if (user) return user;

    // 2. Try to find by email (user may exist from earlier signup)
    if (email) {
      user = await this.usersService.findOne(email);
      if (user) {
        // Link the existing user to Supabase
        return this.usersService.linkSupabaseId(user.id, supabaseId);
      }
    }

    // 3. Create a brand-new user
    this.logger.log(`Creating new user for Supabase ID ${supabaseId}`);
    const newUser = await this.usersService.create({
      supabaseId,
      email,
      name: metadata?.full_name ?? metadata?.name ?? null,
      avatarUrl: metadata?.avatar_url ?? null,
    });

    // 4. Send Welcome Email
    if (email) {
      try {
        await this.emailService.sendWelcome(email, newUser.name || '');
      } catch (err) {
        this.logger.error(`Failed to send welcome email to ${email}`, err);
      }
    }

    return newUser;
  }
}
