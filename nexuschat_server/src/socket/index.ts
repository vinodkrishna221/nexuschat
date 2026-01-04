import { Server as HttpServer } from 'http';
import { Server, Socket } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import Redis from 'ioredis';
import { env } from '../config/env';
import { socketAuthMiddleware } from './middleware/auth.middleware';
import { handleConnection } from './handlers/connection.handler';
import {
    AuthenticatedSocket,
    ServerToClientEvents,
    ClientToServerEvents,
    InterServerEvents,
    SocketData,
} from './types';

// Socket.IO server instance
let io: Server<ClientToServerEvents, ServerToClientEvents, InterServerEvents, SocketData>;

/**
 * Initialize Socket.IO server with Redis adapter
 */
export const initializeSocket = async (httpServer: HttpServer): Promise<Server> => {
    console.log('🔌 Initializing Socket.IO server...');

    // Create Socket.IO server
    io = new Server<ClientToServerEvents, ServerToClientEvents, InterServerEvents, SocketData>(
        httpServer,
        {
            cors: {
                origin: env.CORS_ORIGIN,
                methods: ['GET', 'POST'],
                credentials: true,
            },
            pingTimeout: 60000,
            pingInterval: 25000,
            transports: ['websocket', 'polling'],
        }
    );

    // Set up Redis adapter for horizontal scaling
    try {
        const pubClient = new Redis(env.REDIS_URL);
        const subClient = pubClient.duplicate();

        await Promise.all([
            new Promise<void>((resolve) => pubClient.once('ready', resolve)),
            new Promise<void>((resolve) => subClient.once('ready', resolve)),
        ]);

        io.adapter(createAdapter(pubClient, subClient));
        console.log('✅ Socket.IO Redis adapter configured');
    } catch (error) {
        console.warn('⚠️ Redis adapter failed, running without clustering support:', error);
    }

    // Apply authentication middleware
    io.use((socket: Socket, next) => socketAuthMiddleware(socket, next));

    // Handle new connections
    io.on('connection', (socket: Socket) => {
        handleConnection(io, socket as AuthenticatedSocket);
    });

    console.log('✅ Socket.IO server initialized');

    return io;
};

/**
 * Get the Socket.IO server instance
 */
export const getIO = (): Server => {
    if (!io) {
        throw new Error('Socket.IO not initialized. Call initializeSocket first.');
    }
    return io;
};

/**
 * Gracefully close Socket.IO server
 */
export const closeSocket = async (): Promise<void> => {
    if (io) {
        await new Promise<void>((resolve) => {
            io.close(() => {
                console.log('✅ Socket.IO server closed');
                resolve();
            });
        });
    }
};

export default { initializeSocket, getIO, closeSocket };
