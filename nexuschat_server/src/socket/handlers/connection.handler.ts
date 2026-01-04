import { Server } from 'socket.io';
import { AuthenticatedSocket, ServerToClientEvents, ClientToServerEvents } from '../types';
import { registerMessageHandlers, markChatMessagesAsDelivered } from './message.handler';
import {
    handleUserOnline,
    handleUserOffline,
    registerPresenceHandlers,
} from './presence.handler';

/**
 * Handle new socket connections
 */
export const handleConnection = (
    io: Server<ClientToServerEvents, ServerToClientEvents>,
    socket: AuthenticatedSocket
): void => {
    const { userId, email } = socket.user;

    console.log(`🟢 User connected: ${email} [${socket.id}]`);

    // Join user's personal room for direct messages
    socket.join(`user:${userId}`);

    // Handle user coming online (with Redis presence)
    handleUserOnline(io, socket);

    // Register message handlers
    registerMessageHandlers(io, socket);

    // Register presence handlers
    registerPresenceHandlers(io, socket);

    // Register chat event handlers
    registerChatHandlers(io, socket);

    // Handle disconnect
    socket.on('disconnect', async (reason) => {
        console.log(`🔴 User disconnected: ${email} [${socket.id}] - Reason: ${reason}`);

        // Handle user going offline (with Redis presence)
        await handleUserOffline(io, socket);
    });

    // Handle errors
    socket.on('error', (error) => {
        console.error(`❌ Socket error for ${email}:`, error);
    });
};

/**
 * Register chat-related event handlers
 */
const registerChatHandlers = (
    io: Server<ClientToServerEvents, ServerToClientEvents>,
    socket: AuthenticatedSocket
): void => {
    const { userId } = socket.user;

    // Join a chat room and mark messages as delivered
    socket.on('chat:join', async (chatId: string) => {
        socket.join(`chat:${chatId}`);
        console.log(`💬 User ${userId} joined chat ${chatId}`);

        // Auto-mark undelivered messages as delivered when joining chat
        await markChatMessagesAsDelivered(io, chatId, userId);
    });

    // Leave a chat room
    socket.on('chat:leave', (chatId: string) => {
        socket.leave(`chat:${chatId}`);
        console.log(`💬 User ${userId} left chat ${chatId}`);
    });

    // Typing indicators
    socket.on('typing:start', (chatId: string) => {
        socket.to(`chat:${chatId}`).emit('typing:start', { userId, chatId });
    });

    socket.on('typing:stop', (chatId: string) => {
        socket.to(`chat:${chatId}`).emit('typing:stop', { userId, chatId });
    });
};

export default handleConnection;
