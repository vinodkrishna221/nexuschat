import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import User from '../models/User';
import {
    generateTokenPair,
    verifyRefreshToken,
    getRefreshTokenExpiry,
} from '../services/jwt.service';
import { sendWelcomeEmail, sendPasswordResetEmail } from '../services/email.service';
import crypto from 'crypto';
import bcrypt from 'bcrypt';

// Validation schemas
const registerSchema = z.object({
    email: z.string().email('Invalid email format'),
    password: z.string().min(8, 'Password must be at least 8 characters'),
    username: z.string().min(3, 'Username must be at least 3 characters').max(20),
    displayName: z.string().min(1, 'Display name is required').max(50),
});

const loginSchema = z.object({
    email: z.string().email('Invalid email format'),
    password: z.string().min(1, 'Password is required'),
});

const refreshSchema = z.object({
    refreshToken: z.string().min(1, 'Refresh token is required'),
});

/**
 * Register a new user
 * POST /auth/register
 */
export const register = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        // Validate input
        const validation = registerSchema.safeParse(req.body);
        if (!validation.success) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid input',
                    details: validation.error.issues,
                },
            });
            return;
        }

        const { email, password, username, displayName } = validation.data;

        // Check if user already exists
        const existingUser = await User.findOne({
            $or: [{ email }, { username }],
        });

        if (existingUser) {
            const field = existingUser.email === email ? 'email' : 'username';
            res.status(409).json({
                success: false,
                error: {
                    code: 'CONFLICT',
                    message: `A user with this ${field} already exists`,
                },
            });
            return;
        }

        // Create user
        const user = new User({
            email,
            passwordHash: password, // Will be hashed by pre-save hook
            username,
            displayName,
        });

        await user.save();

        // Generate tokens
        const tokens = generateTokenPair(user._id.toString(), user.email);

        // Save refresh token
        user.refreshTokens.push({
            token: crypto.createHash('sha256').update(tokens.refreshToken).digest('hex'),
            device: req.headers['user-agent'] || 'Unknown',
            createdAt: new Date(),
            expiresAt: getRefreshTokenExpiry(),
        });
        await user.save();

        // Send welcome email (async, don't wait)
        sendWelcomeEmail(user.email, user.displayName).catch((err) =>
            console.error('Failed to send welcome email:', err)
        );

        res.status(201).json({
            success: true,
            data: {
                user: user.toJSON(),
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
            },
            message: 'Registration successful. Welcome email sent.',
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Login user
 * POST /auth/login
 */
export const login = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        // Validate input
        const validation = loginSchema.safeParse(req.body);
        if (!validation.success) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid input',
                    details: validation.error.issues,
                },
            });
            return;
        }

        const { email, password } = validation.data;

        // Find user with password
        const user = await User.findOne({ email }).select('+passwordHash');

        if (!user) {
            res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Invalid credentials',
                },
            });
            return;
        }

        // Check if account is active
        if (!user.isActive) {
            res.status(403).json({
                success: false,
                error: {
                    code: 'FORBIDDEN',
                    message: 'Account suspended',
                },
            });
            return;
        }

        // Verify password
        const isValidPassword = await user.comparePassword(password);

        if (!isValidPassword) {
            res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Invalid credentials',
                },
            });
            return;
        }

        // Generate tokens
        const tokens = generateTokenPair(user._id.toString(), user.email);

        // Save refresh token
        user.refreshTokens.push({
            token: crypto.createHash('sha256').update(tokens.refreshToken).digest('hex'),
            device: req.headers['user-agent'] || 'Unknown',
            createdAt: new Date(),
            expiresAt: getRefreshTokenExpiry(),
        });

        // Update online status
        user.isOnline = true;
        await user.save();

        res.status(200).json({
            success: true,
            data: {
                user: user.toJSON(),
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Refresh access token
 * POST /auth/refresh
 */
export const refresh = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        // Validate input
        const validation = refreshSchema.safeParse(req.body);
        if (!validation.success) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid input',
                    details: validation.error.issues,
                },
            });
            return;
        }

        const { refreshToken } = validation.data;

        // Verify refresh token
        const decoded = verifyRefreshToken(refreshToken);

        if (!decoded) {
            res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Invalid or expired refresh token',
                },
            });
            return;
        }

        // Find user and verify stored token
        const hashedToken = crypto.createHash('sha256').update(refreshToken).digest('hex');
        const user = await User.findOne({
            _id: decoded.userId,
            'refreshTokens.token': hashedToken,
        });

        if (!user) {
            res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Invalid refresh token',
                },
            });
            return;
        }

        // Remove old token and add new one
        user.refreshTokens = user.refreshTokens.filter(
            (t) => t.token !== hashedToken
        );

        // Generate new tokens
        const tokens = generateTokenPair(user._id.toString(), user.email);

        user.refreshTokens.push({
            token: crypto.createHash('sha256').update(tokens.refreshToken).digest('hex'),
            device: req.headers['user-agent'] || 'Unknown',
            createdAt: new Date(),
            expiresAt: getRefreshTokenExpiry(),
        });

        await user.save();

        res.status(200).json({
            success: true,
            data: {
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Logout user
 * POST /auth/logout
 */
export const logout = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { refreshToken } = req.body;

        if (refreshToken) {
            // Remove the specific refresh token
            const hashedToken = crypto.createHash('sha256').update(refreshToken).digest('hex');
            await User.updateOne(
                { 'refreshTokens.token': hashedToken },
                { $pull: { refreshTokens: { token: hashedToken } } }
            );
        }

        // If we have the user from auth middleware, update online status
        if ((req as any).user) {
            await User.updateOne(
                { _id: (req as any).user.userId },
                { isOnline: false, lastSeen: new Date() }
            );
        }

        res.status(200).json({
            success: true,
            message: 'Logged out successfully',
        });
    } catch (error) {
        next(error);
    }
};

export default {
    register,
    login,
    refresh,
    logout,
};

// Validation schemas for password reset
const forgotPasswordSchema = z.object({
    email: z.string().email('Invalid email format'),
});

const resetPasswordSchema = z.object({
    token: z.string().min(1, 'Reset token is required'),
    password: z.string().min(8, 'Password must be at least 8 characters'),
});

/**
 * Forgot password - send reset email
 * POST /auth/forgot-password
 */
export const forgotPassword = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        // Validate input
        const validation = forgotPasswordSchema.safeParse(req.body);
        if (!validation.success) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid input',
                    details: validation.error.issues,
                },
            });
            return;
        }

        const { email } = validation.data;

        // Find user (don't reveal if user exists)
        const user = await User.findOne({ email });

        if (user) {
            // Generate reset token
            const resetToken = crypto.randomBytes(32).toString('hex');
            const hashedToken = crypto.createHash('sha256').update(resetToken).digest('hex');

            // Save token with 1 hour expiry
            user.resetToken = hashedToken;
            user.resetTokenExpiry = new Date(Date.now() + 60 * 60 * 1000);
            await user.save();

            // Send reset email
            await sendPasswordResetEmail(user.email, user.displayName, resetToken);
        }

        // Always return success (security - don't reveal if email exists)
        res.status(200).json({
            success: true,
            message: 'If an account exists with this email, a password reset link has been sent.',
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Reset password with token
 * POST /auth/reset-password
 */
export const resetPassword = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        // Validate input
        const validation = resetPasswordSchema.safeParse(req.body);
        if (!validation.success) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid input',
                    details: validation.error.issues,
                },
            });
            return;
        }

        const { token, password } = validation.data;

        // Hash the token to compare
        const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

        // Find user with valid token
        const user = await User.findOne({
            resetToken: hashedToken,
            resetTokenExpiry: { $gt: new Date() },
        });

        if (!user) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'INVALID_TOKEN',
                    message: 'Invalid or expired reset token',
                },
            });
            return;
        }

        // Update password
        const salt = await bcrypt.genSalt(12);
        user.passwordHash = await bcrypt.hash(password, salt);
        user.resetToken = null;
        user.resetTokenExpiry = null;
        user.refreshTokens = []; // Invalidate all sessions
        await user.save();

        res.status(200).json({
            success: true,
            message: 'Password reset successful. Please login with your new password.',
        });
    } catch (error) {
        next(error);
    }
};
