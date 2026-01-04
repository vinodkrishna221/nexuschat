import { Socket } from 'socket.io';
import { DecodedToken } from '../services/jwt.service';

// Authenticated socket with user data attached
export interface AuthenticatedSocket extends Socket {
    user: {
        userId: string;
        email: string;
    };
}

// Server-to-client events
export interface ServerToClientEvents {
    // Connection events
    'user:online': (userId: string) => void;
    'user:offline': (data: { userId: string; lastSeen: string }) => void;

    // Error events
    'error:auth': (message: string) => void;

    // Message events (for Phase 2 - Day 13-15)
    'message:new': (message: MessagePayload) => void;
    'message:delivered': (data: { messageId: string; deliveredAt: string }) => void;
    'message:read': (data: { messageId: string; readAt: string }) => void;

    // Typing events
    'typing:start': (data: { userId: string; chatId: string }) => void;
    'typing:stop': (data: { userId: string; chatId: string }) => void;
}

// Client-to-server events
export interface ClientToServerEvents {
    // Message events (for Phase 2 - Day 13-15)
    'message:send': (data: SendMessagePayload, callback: (response: MessageResponse) => void) => void;
    'message:delivered': (messageId: string) => void;
    'message:read': (messageId: string) => void;

    // Typing events
    'typing:start': (chatId: string) => void;
    'typing:stop': (chatId: string) => void;

    // Chat events
    'chat:join': (chatId: string) => void;
    'chat:leave': (chatId: string) => void;

    // Presence events
    'presence:heartbeat': () => void;
    'presence:query': (userIds: string[], callback: (data: Record<string, { isOnline: boolean; lastSeen: string }>) => void) => void;
}

// Inter-server events (for Redis adapter)
export interface InterServerEvents {
    ping: () => void;
}

// Socket data stored per connection
export interface SocketData {
    user: DecodedToken;
    connectedAt: Date;
}

// Message payload types (placeholder for Phase 2)
export interface MessagePayload {
    id: string;
    chatId: string;
    senderId: string;
    content: string;
    type: 'text' | 'image' | 'file';
    createdAt: string;
    status: 'sent' | 'delivered' | 'read';
}

export interface SendMessagePayload {
    chatId: string;
    content: string;
    type?: 'text' | 'image' | 'file';
}

export interface MessageResponse {
    success: boolean;
    message?: MessagePayload;
    error?: string;
}
