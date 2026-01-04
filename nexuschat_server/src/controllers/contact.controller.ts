import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import mongoose from 'mongoose';
import Contact from '../models/Contact';
import User from '../models/User';

// Validation schemas
const addContactSchema = z.object({
    userId: z.string().min(1, 'User ID is required'),
});

const blockUserSchema = z.object({
    userId: z.string().min(1, 'User ID is required'),
});

/**
 * Get user's contact list
 * GET /contacts
 */
export const getContacts = async (
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

        // Get all non-blocked contacts
        const contacts = await Contact.find({
            userId,
            status: 'accepted',
        })
            .populate('contactId', 'username displayName avatar isOnline status lastSeen')
            .sort({ addedAt: -1 });

        // Transform response
        const transformedContacts = contacts.map(contact => ({
            id: contact._id,
            user: {
                id: contact.contactId._id,
                username: (contact.contactId as any).username,
                displayName: (contact.contactId as any).displayName,
                avatar: (contact.contactId as any).avatar,
                isOnline: (contact.contactId as any).isOnline,
                status: (contact.contactId as any).status,
                lastSeen: (contact.contactId as any).lastSeen,
            },
            addedAt: contact.addedAt,
        }));

        res.status(200).json({
            success: true,
            data: transformedContacts,
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Add a new contact
 * POST /contacts/add
 */
export const addContact = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const currentUserId = req.user?.userId;

        if (!currentUserId) {
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
        const validation = addContactSchema.safeParse(req.body);
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

        const { userId: contactUserId } = validation.data;

        // Validate ObjectId format
        if (!mongoose.Types.ObjectId.isValid(contactUserId)) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid user ID format',
                },
            });
            return;
        }

        // Cannot add yourself
        if (contactUserId === currentUserId) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Cannot add yourself as a contact',
                },
            });
            return;
        }

        // Check if user exists
        const contactUser = await User.findById(contactUserId);
        if (!contactUser || !contactUser.isActive) {
            res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'User not found',
                },
            });
            return;
        }

        // Check if contact already exists
        const existingContact = await Contact.findOne({
            userId: currentUserId,
            contactId: contactUserId,
        });

        if (existingContact) {
            // If blocked, cannot add
            if (existingContact.status === 'blocked') {
                res.status(400).json({
                    success: false,
                    error: {
                        code: 'BLOCKED',
                        message: 'Cannot add a blocked user',
                    },
                });
                return;
            }

            // Already a contact
            res.status(409).json({
                success: false,
                error: {
                    code: 'CONFLICT',
                    message: 'User is already in your contacts',
                },
            });
            return;
        }

        // Check if the other user has blocked current user
        const reverseBlock = await Contact.findOne({
            userId: contactUserId,
            contactId: currentUserId,
            status: 'blocked',
        });

        if (reverseBlock) {
            res.status(403).json({
                success: false,
                error: {
                    code: 'FORBIDDEN',
                    message: 'Cannot add this user',
                },
            });
            return;
        }

        // Create contact
        const contact = await Contact.create({
            userId: currentUserId,
            contactId: contactUserId,
            status: 'accepted',
        });

        // Populate and return
        await contact.populate('contactId', 'username displayName avatar isOnline status');

        res.status(201).json({
            success: true,
            data: {
                id: contact._id,
                user: {
                    id: contact.contactId._id,
                    username: (contact.contactId as any).username,
                    displayName: (contact.contactId as any).displayName,
                    avatar: (contact.contactId as any).avatar,
                    isOnline: (contact.contactId as any).isOnline,
                    status: (contact.contactId as any).status,
                },
                addedAt: contact.addedAt,
            },
            message: 'Contact added successfully',
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Remove a contact
 * DELETE /contacts/:id
 */
export const removeContact = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const currentUserId = req.user?.userId;
        const { id: contactId } = req.params;

        if (!currentUserId) {
            res.status(401).json({
                success: false,
                error: {
                    code: 'UNAUTHORIZED',
                    message: 'Authentication required',
                },
            });
            return;
        }

        // Validate ObjectId format
        if (!mongoose.Types.ObjectId.isValid(contactId)) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid contact ID format',
                },
            });
            return;
        }

        // Find and delete the contact
        const contact = await Contact.findOneAndDelete({
            _id: contactId,
            userId: currentUserId,
        });

        if (!contact) {
            res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'Contact not found',
                },
            });
            return;
        }

        res.status(200).json({
            success: true,
            message: 'Contact removed',
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Block a user
 * POST /contacts/block
 */
export const blockUser = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const currentUserId = req.user?.userId;

        if (!currentUserId) {
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
        const validation = blockUserSchema.safeParse(req.body);
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

        const { userId: userToBlockId } = validation.data;

        // Validate ObjectId format
        if (!mongoose.Types.ObjectId.isValid(userToBlockId)) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid user ID format',
                },
            });
            return;
        }

        // Cannot block yourself
        if (userToBlockId === currentUserId) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Cannot block yourself',
                },
            });
            return;
        }

        // Check if user exists
        const userToBlock = await User.findById(userToBlockId);
        if (!userToBlock) {
            res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'User not found',
                },
            });
            return;
        }

        // Find or create contact record and update to blocked
        const contact = await Contact.findOneAndUpdate(
            {
                userId: currentUserId,
                contactId: userToBlockId,
            },
            {
                status: 'blocked',
                blockedBy: currentUserId,
            },
            {
                upsert: true,
                new: true,
            }
        );

        res.status(200).json({
            success: true,
            message: 'User blocked',
            data: {
                blockedUserId: userToBlockId,
                blockedAt: contact.updatedAt,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Unblock a user
 * POST /contacts/unblock
 */
export const unblockUser = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const currentUserId = req.user?.userId;

        if (!currentUserId) {
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
        const validation = blockUserSchema.safeParse(req.body);
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

        const { userId: userToUnblockId } = validation.data;

        // Validate ObjectId format
        if (!mongoose.Types.ObjectId.isValid(userToUnblockId)) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'VALIDATION_ERROR',
                    message: 'Invalid user ID format',
                },
            });
            return;
        }

        // Find blocked contact
        const contact = await Contact.findOne({
            userId: currentUserId,
            contactId: userToUnblockId,
            status: 'blocked',
        });

        if (!contact) {
            res.status(404).json({
                success: false,
                error: {
                    code: 'NOT_FOUND',
                    message: 'Blocked user not found',
                },
            });
            return;
        }

        // Remove the contact record (unblock means removing the block record)
        await Contact.deleteOne({ _id: contact._id });

        res.status(200).json({
            success: true,
            message: 'User unblocked',
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get list of blocked users
 * GET /contacts/blocked
 */
export const getBlockedUsers = async (
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

        const blockedContacts = await Contact.find({
            userId,
            status: 'blocked',
        })
            .populate('contactId', 'username displayName avatar')
            .sort({ updatedAt: -1 });

        const transformedBlocked = blockedContacts.map(contact => ({
            id: contact._id,
            user: {
                id: contact.contactId._id,
                username: (contact.contactId as any).username,
                displayName: (contact.contactId as any).displayName,
                avatar: (contact.contactId as any).avatar,
            },
            blockedAt: contact.updatedAt,
        }));

        res.status(200).json({
            success: true,
            data: transformedBlocked,
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Helper function to get blocked user IDs for a user
 * This is exported for use in chat/message queries
 */
export const getBlockedUserIds = async (userId: string): Promise<string[]> => {
    // Get users blocked by the current user
    const blockedByMe = await Contact.find({
        userId,
        status: 'blocked',
    }).select('contactId');

    // Get users who have blocked the current user
    const blockedMe = await Contact.find({
        contactId: userId,
        status: 'blocked',
    }).select('userId');

    const blockedIds = [
        ...blockedByMe.map(c => c.contactId.toString()),
        ...blockedMe.map(c => c.userId.toString()),
    ];

    return [...new Set(blockedIds)]; // Remove duplicates
};

export default {
    getContacts,
    addContact,
    removeContact,
    blockUser,
    unblockUser,
    getBlockedUsers,
    getBlockedUserIds,
};
