import { createServer } from 'http';
import app from './app';
import { env } from './config/env';
import { connectDatabase, disconnectDatabase } from './config/database';
import { connectRedis, disconnectRedis } from './config/redis';
import { initializeSocket, closeSocket } from './socket';

// Start server
const startServer = async (): Promise<void> => {
    try {
        // Connect to databases
        console.log('🚀 Starting NexusChat Server...');
        console.log(`📍 Environment: ${env.NODE_ENV}`);

        await connectDatabase();
        await connectRedis();

        // Create HTTP server from Express app
        const httpServer = createServer(app);

        // Initialize Socket.IO with HTTP server
        await initializeSocket(httpServer);

        // Start HTTP server - bind to 0.0.0.0 for emulator/device access
        httpServer.listen(env.PORT, '0.0.0.0', () => {
            console.log(`✅ Server running on http://0.0.0.0:${env.PORT}`);
            console.log(`📡 Health check: http://localhost:${env.PORT}/api/health`);
            console.log(`🔗 API: http://localhost:${env.PORT}/api/v1`);
            console.log(`🔌 Socket.IO: ws://localhost:${env.PORT}`);
        });

        // Graceful shutdown
        const gracefulShutdown = async (signal: string): Promise<void> => {
            console.log(`\n${signal} received. Shutting down gracefully...`);

            // Close Socket.IO first
            await closeSocket();

            httpServer.close(async () => {
                console.log('✅ HTTP server closed');

                await disconnectDatabase();
                await disconnectRedis();

                console.log('👋 Goodbye!');
                process.exit(0);
            });

            // Force shutdown after 10 seconds
            setTimeout(() => {
                console.error('⚠️ Could not close connections in time, forcefully shutting down');
                process.exit(1);
            }, 10000);
        };

        // Handle shutdown signals
        process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
        process.on('SIGINT', () => gracefulShutdown('SIGINT'));

    } catch (error) {
        console.error('❌ Failed to start server:', error);
        process.exit(1);
    }
};

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason: unknown) => {
    console.error('❌ Unhandled Rejection:', reason);
    process.exit(1);
});

// Handle uncaught exceptions
process.on('uncaughtException', (error: Error) => {
    console.error('❌ Uncaught Exception:', error);
    process.exit(1);
});

// Start the server
startServer();
