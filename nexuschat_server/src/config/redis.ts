import Redis from 'ioredis';
import { env } from './env';

// Create Redis client using URL
export const redis = new Redis(env.REDIS_URL);

// Connection event handlers
redis.on('connect', () => {
    console.log('✅ Connected to Redis');
});

redis.on('error', (error) => {
    console.error('❌ Redis connection error:', error.message);
});

redis.on('close', () => {
    console.warn('⚠️ Redis connection closed');
});

redis.on('reconnecting', () => {
    console.log('🔄 Reconnecting to Redis...');
});

// Graceful shutdown
export const disconnectRedis = async (): Promise<void> => {
    try {
        await redis.quit();
        console.log('✅ Redis connection closed');
    } catch (error) {
        console.error('❌ Error closing Redis connection:', error);
    }
};

// Connect function (Redis auto-connects, but this allows explicit control)
export const connectRedis = async (): Promise<void> => {
    // Redis auto-connects when created with URL
    // This function exists for API consistency
    return Promise.resolve();
};

export default redis;
