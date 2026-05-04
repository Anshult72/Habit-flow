import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Resend } from 'resend';

export interface SendMailDto {
  to: string;
  subject: string;
  html: string;
}

@Injectable()
export class EmailService {
  private resend: Resend;
  private from: string;
  private readonly logger = new Logger(EmailService.name);

  constructor(private readonly config: ConfigService) {
    const apiKey = this.config.get<string>('RESEND_API_KEY')!;
    this.from = this.config.get<string>('RESEND_FROM_EMAIL') || 'onboarding@resend.dev';
    this.resend = new Resend(apiKey);
  }

  /** Send a transactional email via Resend */
  async sendMail(dto: SendMailDto): Promise<void> {
    try {
      await this.resend.emails.send({
        from: this.from,
        to: dto.to,
        subject: dto.subject,
        html: dto.html,
      });
      this.logger.log(`Email sent to ${dto.to}`);
    } catch (err) {
      this.logger.error('Resend email failed', err);
      throw err;
    }
  }

  /** Welcome email for new users */
  async sendWelcome(to: string, name: string): Promise<void> {
    const html = `
      <div style="font-family: 'Inter', sans-serif; max-width: 480px; margin: 0 auto; padding: 32px; background: #0a0a0a; color: #e5e5e5; border-radius: 12px;">
        <h1 style="color: #FF6B2C; font-size: 24px;">Welcome to HabitFlow, ${name || 'there'}! 🚀</h1>
        <p style="line-height: 1.6;">We're excited to have you on board. Start building great habits, stay focused, and track your progress — all in one place.</p>
        <p style="color: #888; font-size: 13px; margin-top: 24px;">— The HabitFlow Team</p>
      </div>
    `;
    await this.sendMail({ to, subject: 'Welcome to HabitFlow 🎉', html });
  }
}
