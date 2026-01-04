import { Server } from 'socket.io';
import mongoose from 'mongoose';
import {
    AuthenticatedSocket,
    ServerToClientEvents,
    ClientToServerEvents,
    SendMessagePayload,
    MessagePayload,
    MessageResponse,
} from '../types';
import Chat from '../../models/Chat';
import Message from '../../models/Message';

/**
 * Register message event handlers for a socket
 */
export const registerMessageHandlers = (
    io: Server<ClientToServerEvents, ServerToClientEvents>,
    socket: AuthenticatedSocket
): void => {
    const { userId } = socket.user;

    /**
     * Handle sending a new message
     */
    socket.on('message:send', async (data: SendMessagePayload, callback: (response: MessageResponse) => void) => {
        try {
            const { chatId, content, type = 'text' } = data;

            // Validate chat ID
            if (!chatId || !mongoose.Types.ObjectId.isValid(chatId)) {
                callback({ success: false, error: 'Invalid chat ID' });
                return;
            }

            // Validate content
            if (!content || content.trim().length === 0) {
                callback({ success: false, error: 'Message content is required' });
                return;
            }

            if (content.length > 5000) {
                callback({ success: false, error: 'Message too long (max 5000 characters)' });
                return;
            }

            // Check if user is participant in this chat
            const chat = await Chat.findOne({
                _id: chatId,
                participants: userId,
            });

            if (!chat) {
                callback({ success: false, error: 'Chat not found or access denied' });
                return;
            }

            // Create the message
            const message = await Message.create({
                chat: chatId,
                sender: userId,
                content: content.trim(),
                type,
                status: 'sent',
            });

            // Update chat's lastMessage and lastActivity
            await Chat.findByIdAndUpdate(chatId, {
                lastMessage: message._id,
                lastActivity: new Date(),
            });

            // Prepare message payload for broadcast
            const messagePayload: MessagePayload = {
                id: message._id.toString(),
                chatId: chatId,
                senderId: userId,
                content: message.content,
                type: message.type,
                createdAt: message.createdAt.toISOString(),
                status: 'sent',
            };

            // Send acknowledgment to sender
            callback({ success: true, message: messagePayload });

            // Broadcast to all users in the chat room (except sender)
            socket.to(`chat:${chatId}`).emit('message:new', messagePayload);

            // Also send to recipient's personal room (in case they're not in chat room)
            const recipientId = chat.participants.find(
                (p: mongoose.Types.ObjectId) => p.toString() !== userId
            );
            if (recipientId) {
                socket.to(`user:${recipientId.toString()}`).emit('message:new', messagePayload);
            }

            console.log(`📨 Message sent in chat ${chatId} by ${userId}`);
        } catch (error) {
            console.error('❌ Error sending message:', error);
            callback({ success: false, error: 'Failed to send message' });
        }
    });

    /**
     * Handle message delivered confirmation
     */
    socket.on('message:delivered', async (messageId: string) => {
        try {
            if (!messageId || !mongoose.Types.ObjectId.isValid(messageId)) {
                return;
            }

            // Find the message and ensure receiver is marking it
            const message = await Message.findOne({
                _id: messageId,
                sender: { $ne: userId }, // Not the sender
                status: 'sent', // Only update if still 'sent'
            });

            if (!message) {
                return;
            }

            // Update message status
            const deliveredAt = new Date();
            await Message.findByIdAndUpdate(messageId, {
                status: 'delivered',
                deliveredAt,
            });

            // Notify the sender
            io.to(`user:${message.sender.toString()}`).emit('message:delivered', {
                messageId,
                deliveredAt: deliveredAt.toISOString(),
            });

            console.log(`✅ Message ${messageId} marked as delivered`);
        } catch (error) {
            console.error('❌ Error marking message as delivered:', error);
        }
    });

    /**
     * Handle message read confirmation
     */
    socket.on('message:read', async (messageId: string) => {
        try {
            if (!messageId || !mongoose.Types.ObjectId.isValid(messageId)) {
                return;
            }

            // Find the message and ensure receiver is marking it
            const message = await Message.findOne({
                _id: messageId,
                sender: { $ne: userId }, // Not the sender
                status: { $ne: 'read' }, // Not already read
            });

            if (!message) {
                return;
            }

            // Update message status
            const readAt = new Date();
            await Message.findByIdAndUpdate(messageId, {
                status: 'read',
                readAt,
                // Also set deliveredAt if not already set
                ...(message.status === 'sent' && { deliveredAt: readAt }),
            });

            // Notify the sender
            io.to(`user:${message.sender.toString()}`).emit('message:read', {
                messageId,
                readAt: readAt.toISOString(),
            });

            console.log(`👁️ Message ${messageId} marked as read`);
        } catch (error) {
            console.error('❌ Error marking message as read:', error);
        }
    });
};

/**
 * Mark all unread messages in a chat as delivered for a user
 */
export const markChatMessagesAsDelivered = async (
    io: Server<ClientToServerEvents, ServerToClientEvents>,
    chatId: string,
    userId: string
): Promise<void> => {
    try {
        const now = new Date();

        // Find all undelivered messages not sent by this user
        const messages = await Message.find({
            chat: chatId,
            sender: { $ne: userId },
            status: 'sent',
        });

        if (messages.length === 0) {
            return;
        }

        // Update all messages
        await Message.updateMany(
            {
                chat: chatId,
                sender: { $ne: userId },
                status: 'sent',
            },
            {
                status: 'delivered',
                deliveredAt: now,
            }
        );

        // Notify senders
        for (const message of messages) {
            io.to(`user:${message.sender.toString()}`).emit('message:delivered', {
                messageId: message._id.toString(),
                deliveredAt: now.toISOString(),
            });
        }

        console.log(`✅ Marked ${messages.length} messages as delivered in chat ${chatId}`);
    } catch (error) {
        console.error('❌ Error marking chat messages as delivered:', error);
    }
};

export default { registerMessageHandlers, markChatMessagesAsDelivered };
