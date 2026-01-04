import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import User from '../models/User';
import fs from 'fs';
import path from 'path';

// Validation schemas
const updateProfileSchema = z.object({
    displayName: z.string().min(1).max(50).optional(),
    bio: z.string().max(150).optional(),
    status: z.string().max(50).optional(),
    settings: z.object({
        notifications: z.boolean().optional(),
        soundEnabled: z.boolean().optional(),
        theme: z.enum(['dark', 'light']).optional(),
    }).optional(),
});

const searchQuerySchema = z.object({
    q: z.string().min(1, 'Search query is required'),
    limit: z.string().transform(val => parseInt(val, 10)).pipe(z.number().min(1).max(50)).optional(),
});

/**
 * Get current user profile
 * GET /users/me
 */
export const getMe = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const userId = req.user?.userId;

        if (!userId) {
            res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Authentication required',
                },
            });
            return;
        }

        const user = await User.findById(userId);

        if (!user) {
            res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'User not found',
                },
            });
            return;
        }

        res.status(200).json({
            success: true,
            data: user.toJSON(),
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update current user profile
 * PATCH /users/me
 */
export const updateMe = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const userId = req.user?.userId;

        if (!userId) {
            res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Authentication required',
                },
            });
            return;
        }

        // Validate input
        const validation = updateProfileSchema.safeParse(req.body);
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

        const updateData = validation.data;

        // Build update object
        const updateObj: Record<string, unknown> = {};
        if (updateData.displayName !== undefined) updateObj.displayName = updateData.displayName;
        if (updateData.bio !== undefined) updateObj.bio = updateData.bio;
        if (updateData.status !== undefined) updateObj.status = updateData.status;
        if (updateData.settings) {
            // Merge with existing settings
            const user = await User.findById(userId);
            if (user) {
                updateObj.settings = {
                    ...user.settings,
                    ...updateData.settings,
                };
            }
        }

        const user = await User.findByIdAndUpdate(
            userId,
            { $set: updateObj },
            { new: true, runValidators: true }
        );

        if (!user) {
            res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'User not found',
                },
            });
            return;
        }

        res.status(200).json({
            success: true,
            data: user.toJSON(),
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Upload user avatar
 * POST /users/me/avatar
 */
export const uploadAvatar = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const userId = req.user?.userId;

        if (!userId) {
            res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Authentication required',
                },
            });
            return;
        }

        if (!req.file) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Avatar file is required',
                },
            });
            return;
        }

        // Get current user to find old avatar
        const currentUser = await User.findById(userId);
        const oldAvatarPath = currentUser?.avatar;

        // Create avatar URL (relative path for now, can be CDN URL in production)
        const avatarUrl = `/uploads/avatars/${req.file.filename}`;

        // Update user avatar
        const user = await User.findByIdAndUpdate(
            userId,
            { avatar: avatarUrl },
            { new: true }
        );

        if (!user) {
            // Clean up uploaded file if user not found
            fs.unlinkSync(req.file.path);
            res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'User not found',
                },
            });
            return;
        }

        // Delete old avatar file if it exists and is a local file
        if (oldAvatarPath && oldAvatarPath.startsWith('/uploads/avatars/')) {
            const oldFilePath = path.join(process.cwd(), oldAvatarPath);
            if (fs.existsSync(oldFilePath)) {
                fs.unlinkSync(oldFilePath);
            }
        }

        res.status(200).json({
            success: true,
            data: {
                avatar: avatarUrl,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get user by ID (public profile)
 * GET /users/:id
 */
export const getUserById = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { id } = req.params;

        // Validate ObjectId format
        if (!id.match(/^[0-9a-fA-F]{24}$/)) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid user ID format',
                },
            });
            return;
        }

        const user = await User.findById(id).select(
            'username displayName avatar bio status isOnline lastSeen'
        );

        if (!user) {
            res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'User not found',
                },
            });
            return;
        }

        res.status(200).json({
            success: true,
            data: {
                id: user._id,
                username: user.username,
                displayName: user.displayName,
                avatar: user.avatar,
                bio: user.bio,
                status: user.status,
                isOnline: user.isOnline,
                lastSeen: user.lastSeen,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Search users
 * GET /users/search
 */
export const searchUsers = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const userId = req.user?.userId;

        // Validate query params
        const validation = searchQuerySchema.safeParse(req.query);
        if (!validation.success) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid query parameters',
                    details: validation.error.issues,
                },
            });
            return;
        }

        const { q: query, limit = 20 } = validation.data;

        // Search using regex for partial matching (case-insensitive)
        const searchRegex = new RegExp(query, 'i');

        const users = await User.find({
            $and: [
                { _id: { $ne: userId } }, // Exclude current user
                { isActive: true }, // Only active users
                {
                    $or: [
                        { username: searchRegex },
                        { displayName: searchRegex },
                        { email: searchRegex },
                    ],
                },
            ],
        })
            .select('username displayName avatar isOnline')
            .limit(limit);

        res.status(200).json({
            success: true,
            data: users.map(user => ({
                id: user._id,
                username: user.username,
                displayName: user.displayName,
                avatar: user.avatar,
                isOnline: user.isOnline,
            })),
        });
    } catch (error) {
        next(error);
    }
};

export default {
    getMe,
    updateMe,
    uploadAvatar,
    getUserById,
    searchUsers,
};
