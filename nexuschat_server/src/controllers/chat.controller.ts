import { Request, Response } from 'express';
import mongoose from 'mongoose';
import Chat from '../models/Chat';
import Message from '../models/Message';
import User from '../models/User';
import { getBlockedUserIds } from './contact.controller';

/**
 * Get all chats for the authenticated user
 * @route GET /chats
 */
export const getChats = async (req: Request, res: Response): Promise<void> => {
    try {
        const userId = req.user!.userId;

        // Get blocked user IDs
        const blockedUserIds = await getBlockedUserIds(userId);

        // Find all chats where user is a participant
        const chats = await Chat.find({
            participants: userId,
        })
            .populate('participants', 'username displayName avatar isOnline lastSeen')
            .populate('lastMessage', 'content type status createdAt sender')
            .sort({ lastActivity: -1 })
            .lean();

        // Transform chats to include unread count and other user info
        // Filter out chats with blocked users
        const transformedChats = await Promise.all(
            chats
                .filter((chat) => {
                    // Check if the other participant is blocked
                    const otherParticipant = chat.participants.find(
                        (p: { _id: mongoose.Types.ObjectId }) => p._id.toString() !== userId
                    );
                    return otherParticipant && !blockedUserIds.includes(otherParticipant._id.toString());
                })
                .map(async (chat) => {
                    // Get unread count for this user
                    const unreadCount = await Message.countDocuments({
                        chat: chat._id,
                        sender: { $ne: userId },
                        status: { $ne: 'read' },
                    });

                    // Get the other participant
                    const otherParticipant = chat.participants.find(
                        (p: { _id: mongoose.Types.ObjectId }) => p._id.toString() !== userId
                    );

                    return {
                        id: chat._id,
                        participant: otherParticipant,
                        lastMessage: chat.lastMessage,
                        lastActivity: chat.lastActivity,
                        unreadCount,
                    };
                })
        );

        res.status(200).json({
            success: true,
            data: transformedChats,
        });
    } catch (error) {
        console.error('Get chats error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'SERVER_ERROR',
                message: 'Failed to fetch chats',
            },
        });
    }
};

/**
 * Create or get existing chat with another user
 * @route POST /chats
 */
export const createOrGetChat = async (req: Request, res: Response): Promise<void> => {
    try {
        const userId = req.user!.userId;
        const { recipientId } = req.body;

        // Validate recipient ID
        if (!recipientId) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'INVALID_REQUEST',
                    message: 'Recipient ID is required',
                },
            });
            return;
        }

        // Check if recipient exists
        const recipient = await User.findById(recipientId);
        if (!recipient) {
            res.status(404).json({
                success: false,
                error: {
                    code: 'USER_NOT_FOUND',
                    message: 'Recipient user not found',
                },
            });
            return;
        }

        // Cannot create chat with yourself
        if (recipientId === userId) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'INVALID_REQUEST',
                    message: 'Cannot create chat with yourself',
                },
            });
            return;
        }

        // Check if either user has blocked the other
        const blockedUserIds = await getBlockedUserIds(userId);
        if (blockedUserIds.includes(recipientId)) {
            res.status(403).json({
                success: false,
                error: {
                    code: 'FORBIDDEN',
                    message: 'Cannot create chat with this user',
                },
            });
            return;
        }

        // Sort participant IDs for consistent lookup
        const participants = [userId, recipientId].sort();

        // Find existing chat or create new one
        let chat = await Chat.findOne({
            participants: { $all: participants, $size: 2 },
        });

        let isNew = false;
        if (!chat) {
            chat = await Chat.create({ participants });
            isNew = true;
        }

        // Populate chat data
        await chat.populate('participants', 'username displayName avatar isOnline lastSeen');

        // Get the other participant
        const otherParticipant = chat.participants.find(
            (p: { _id: mongoose.Types.ObjectId }) => p._id.toString() !== userId
        );

        res.status(isNew ? 201 : 200).json({
            success: true,
            data: {
                id: chat._id,
                participant: otherParticipant,
                lastMessage: null,
                lastActivity: chat.lastActivity,
                isNew,
            },
        });
    } catch (error) {
        console.error('Create/get chat error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'SERVER_ERROR',
                message: 'Failed to create or get chat',
            },
        });
    }
};

/**
 * Get messages for a chat with cursor-based pagination
 * @route GET /chats/:id/messages
 */
export const getChatMessages = async (req: Request, res: Response): Promise<void> => {
    try {
        const userId = req.user!.userId;
        const chatId = req.params.id;
        const { cursor, limit = '50' } = req.query;

        // Validate chat ID
        if (!mongoose.Types.ObjectId.isValid(chatId)) {
            res.status(400).json({
                success: false,
                error: {
                    code: 'INVALID_REQUEST',
                    message: 'Invalid chat ID',
                },
            });
            return;
        }

        // Check if user is participant in this chat
        const chat = await Chat.findOne({
            _id: chatId,
            participants: userId,
        });

        if (!chat) {
            res.status(404).json({
                success: false,
                error: {
                    code: 'CHAT_NOT_FOUND',
                    message: 'Chat not found or access denied',
                },
            });
            return;
        }

        // Parse limit
        const messageLimit = Math.min(Math.max(parseInt(limit as string, 10) || 50, 1), 100);

        // Build query
        interface MessageQuery {
            chat: mongoose.Types.ObjectId;
            _id?: { $lt: mongoose.Types.ObjectId };
        }

        const query: MessageQuery = { chat: chat._id };

        // Use cursor for pagination (messages before this ID)
        if (cursor && mongoose.Types.ObjectId.isValid(cursor as string)) {
            query._id = { $lt: new mongoose.Types.ObjectId(cursor as string) };
        }

        // Fetch messages
        const messages = await Message.find(query)
            .populate('sender', 'username displayName avatar')
            .sort({ _id: -1 })
            .limit(messageLimit + 1) // Fetch one extra to check if there are more
            .lean();

        // Check if there are more messages
        const hasMore = messages.length > messageLimit;
        if (hasMore) {
            messages.pop(); // Remove the extra message
        }

        // Get next cursor (ID of oldest message in this batch)
        const nextCursor = messages.length > 0 ? messages[messages.length - 1]._id : null;

        res.status(200).json({
            success: true,
            data: {
                messages: messages.reverse(), // Return in chronological order
                pagination: {
                    hasMore,
                    nextCursor,
                },
            },
        });
    } catch (error) {
        console.error('Get chat messages error:', error);
        res.status(500).json({
            success: false,
            error: {
                code: 'SERVER_ERROR',
                message: 'Failed to fetch messages',
            },
        });
    }
};

export default {
    getChats,
    createOrGetChat,
    getChatMessages,
};
