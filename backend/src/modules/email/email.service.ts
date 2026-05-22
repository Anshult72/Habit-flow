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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { margin: 0; padding: 0; background-color: #050505; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; }
        .cta-button:hover { background-color: #ff8533 !important; box-shadow: 0 0 20px rgba(255, 107, 0, 0.6) !important; }
        @media screen and (max-width: 600px) {
            .container { width: 100% !important; padding: 0 16px !important; }
            .content-padding { padding: 40px 24px !important; }
            .feature-cell { display: block !important; width: 100% !important; padding-bottom: 20px !important; }
        }
    </style>
</head>
<body style="margin: 0; padding: 0; background-color: #050505; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #050505;">
        <tr>
            <td align="center" style="padding: 40px 0;">
                <table border="0" cellpadding="0" cellspacing="0" width="600" class="container" style="max-width: 600px; width: 100%;">
                    <tr>
                        <td align="center">
                            <table border="0" cellpadding="0" cellspacing="0" width="100%" class="content-padding" style="background-color: #0f0f11; border: 1px solid #222222; border-radius: 24px; padding: 64px 48px; box-shadow: 0 20px 40px rgba(0,0,0,0.4);">
                                <tr>
                                    <td align="center" style="padding-bottom: 40px;">
                                        <img src="https://habit-flow-henna.vercel.app/assets/eagle-logo-transparent.png" alt="HabitFlow" width="64" height="64" style="display: block; width: 64px; height: 64px; filter: drop-shadow(0 0 15px rgba(255, 107, 0, 0.4));">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="padding-bottom: 16px;">
                                        <h1 style="color: #ffffff; font-size: 32px; font-weight: 700; margin: 0; letter-spacing: -0.5px; line-height: 1.2;">Welcome to the Elite, ${name || 'there'}.</h1>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="padding-bottom: 32px;">
                                        <div style="height: 2px; width: 48px; background-color: #ff6b00; border-radius: 2px; box-shadow: 0 0 12px rgba(255, 107, 0, 0.8);"></div>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="padding-bottom: 40px;">
                                        <p style="color: #a1a1aa; font-size: 17px; line-height: 1.6; margin: 0; max-width: 440px;">
                                            You've just taken the first step toward mastering your routines and achieving peak performance. HabitFlow is designed for those who value discipline over distraction.
                                        </p>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="padding-bottom: 48px;">
                                        <table border="0" cellspacing="0" cellpadding="0">
                                            <tr>
                                                <td align="center" style="border-radius: 12px; background-color: #ff6b00; box-shadow: 0 8px 24px rgba(255, 107, 0, 0.4);">
                                                    <a href="https://habit-flow-henna.vercel.app/app" target="_blank" class="cta-button" style="font-size: 16px; font-weight: 700; color: #ffffff; text-decoration: none; border-radius: 12px; padding: 18px 42px; border: 1px solid #ff6b00; display: inline-block;">Start Your Journey</a>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" style="padding-bottom: 24px; border-top: 1px solid #222222; padding-top: 48px;">
                                        <span style="color: #666666; font-size: 11px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase;">The Ecosystem</span>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                            <tr>
                                                <td width="50%" style="padding: 0 10px 24px 0;">
                                                    <div style="background-color: #1a1a1c; padding: 20px; border-radius: 12px; border: 1px solid #2a2a2c;">
                                                        <div style="color: #ff6b00; font-size: 20px; padding-bottom: 8px;">◈</div>
                                                        <div style="color: #ffffff; font-size: 15px; font-weight: 600; padding-bottom: 4px;">Build Habits</div>
                                                        <div style="color: #666666; font-size: 13px;">Scientific routine building.</div>
                                                    </div>
                                                </td>
                                                <td width="50%" style="padding: 0 0 24px 10px;">
                                                    <div style="background-color: #1a1a1c; padding: 20px; border-radius: 12px; border: 1px solid #2a2a2c;">
                                                        <div style="color: #ff6b00; font-size: 20px; padding-bottom: 8px;">◈</div>
                                                        <div style="color: #ffffff; font-size: 15px; font-weight: 600; padding-bottom: 4px;">Focus Sessions</div>
                                                        <div style="color: #666666; font-size: 13px;">Deep work made effortless.</div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
    `;
    await this.sendMail({ to, subject: 'Welcome to HabitFlow 🦅', html });
  }
}
