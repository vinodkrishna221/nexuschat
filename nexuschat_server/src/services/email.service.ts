import nodemailer from 'nodemailer';
import { env } from '../config/env';

// Create transporter
const createTransporter = () => {
  // For development without email config, use Ethereal (fake SMTP)
  if (env.NODE_ENV === 'development' && !env.EMAIL_SERVER_USER) {
    console.log('📧 Using Ethereal (fake) email for development');
    return nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      auth: {
        user: 'ethereal.user@ethereal.email',
        pass: 'ethereal_password',
      },
    });
  }

  // Use configured SMTP server (Gmail, etc.)
  console.log(`📧 Using SMTP: ${env.EMAIL_SERVER_HOST}:${env.EMAIL_SERVER_PORT}`);
  return nodemailer.createTransport({
    host: env.EMAIL_SERVER_HOST,
    port: env.EMAIL_SERVER_PORT,
    secure: env.EMAIL_SERVER_PORT === 465, // true for 465, false for other ports
    auth: {
      user: env.EMAIL_SERVER_USER || '',
      pass: env.EMAIL_SERVER_PASSWORD || '',
    },
  });
};

const transporter = createTransporter();

// Email templates
const templates = {
  welcome: (displayName: string) => ({
    subject: 'Welcome to NexusChat! 🎉',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0f0f23; color: #ffffff; padding: 20px; }
          .container { max-width: 600px; margin: 0 auto; background: #1a1a2e; border-radius: 16px; padding: 40px; }
          .logo { text-align: center; margin-bottom: 30px; }
          .logo h1 { color: #00d4ff; margin: 0; font-size: 28px; }
          .content { text-align: center; }
          h2 { color: #ffffff; margin-bottom: 20px; }
          p { color: #b0b0b0; line-height: 1.6; }
          .button { display: inline-block; background: linear-gradient(135deg, #00d4ff, #7c3aed); color: white; padding: 14px 32px; border-radius: 8px; text-decoration: none; font-weight: 600; margin-top: 20px; }
          .footer { text-align: center; margin-top: 40px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="logo">
            <h1>💬 NexusChat</h1>
          </div>
          <div class="content">
            <h2>Welcome, ${displayName}!</h2>
            <p>Your account has been created successfully. You're now part of the NexusChat community.</p>
            <p>Start connecting with friends and enjoy seamless real-time messaging!</p>
            <a href="#" class="button">Open NexusChat</a>
          </div>
          <div class="footer">
            <p>© 2026 NexusChat. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `,
  }),

  passwordReset: (displayName: string, resetUrl: string) => ({
    subject: 'Reset Your Password - NexusChat',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0f0f23; color: #ffffff; padding: 20px; }
          .container { max-width: 600px; margin: 0 auto; background: #1a1a2e; border-radius: 16px; padding: 40px; }
          .logo { text-align: center; margin-bottom: 30px; }
          .logo h1 { color: #00d4ff; margin: 0; font-size: 28px; }
          .content { text-align: center; }
          h2 { color: #ffffff; margin-bottom: 20px; }
          p { color: #b0b0b0; line-height: 1.6; }
          .button { display: inline-block; background: linear-gradient(135deg, #ff6b6b, #ee5a24); color: white; padding: 14px 32px; border-radius: 8px; text-decoration: none; font-weight: 600; margin-top: 20px; }
          .code { background: #2a2a4a; padding: 20px; border-radius: 8px; font-size: 24px; letter-spacing: 4px; color: #00d4ff; margin: 20px 0; }
          .warning { color: #ff6b6b; font-size: 12px; margin-top: 20px; }
          .footer { text-align: center; margin-top: 40px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="logo">
            <h1>💬 NexusChat</h1>
          </div>
          <div class="content">
            <h2>Password Reset Request</h2>
            <p>Hi ${displayName},</p>
            <p>We received a request to reset your password. Click the button below to create a new password:</p>
            <a href="${resetUrl}" class="button">Reset Password</a>
            <p class="warning">This link expires in 1 hour. If you didn't request this, please ignore this email.</p>
          </div>
          <div class="footer">
            <p>© 2026 NexusChat. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `,
  }),
};

// Send email function
export const sendEmail = async (
  to: string,
  subject: string,
  html: string
): Promise<boolean> => {
  try {
    const info = await transporter.sendMail({
      from: `"NexusChat" <${env.EMAIL_FROM}>`,
      to,
      subject,
      html,
    });

    console.log(`📧 Email sent: ${info.messageId}`);
    return true;
  } catch (error) {
    console.error('❌ Failed to send email:', error);
    return false;
  }
};

// Send welcome email
export const sendWelcomeEmail = async (
  email: string,
  displayName: string
): Promise<boolean> => {
  const template = templates.welcome(displayName);
  return sendEmail(email, template.subject, template.html);
};

// Send password reset email
export const sendPasswordResetEmail = async (
  email: string,
  displayName: string,
  resetToken: string
): Promise<boolean> => {
  const resetUrl = `${env.CORS_ORIGIN}/reset-password?token=${resetToken}`;
  const template = templates.passwordReset(displayName, resetUrl);
  return sendEmail(email, template.subject, template.html);
};

export default {
  sendEmail,
  sendWelcomeEmail,
  sendPasswordResetEmail,
};
