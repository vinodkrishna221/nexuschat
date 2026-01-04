import redis from '../config/redis';
import User from '../models/User';
import Contact from '../models/Contact';

// Redis key prefixes
const PRESENCE_KEY_PREFIX = 'presence:';
const PRESENCE_TTL = 300; // 5 minutes - presence data expires if not refreshed

// Presence data structure
export interface PresenceData {
    isOnline: boolean;
    lastSeen: string;
    socketIds: string[];
}

/**
 * Presence Service - Manages user online status with Redis caching
 */
export class PresenceService {
    /**
     * Set user as online
     */
    static async setOnline(userId: string, socketId: string): Promise<void> {
        const key = `${PRESENCE_KEY_PREFIX}${userId}`;
        const now = new Date().toISOString();

        try {
            // Get existing presence data
            const existingData = await this.getPresence(userId);
            const socketIds = existingData?.socketIds || [];

            // Add new socket ID if not already present
            if (!socketIds.includes(socketId)) {
                socketIds.push(socketId);
            }

            const presenceData: PresenceData = {
                isOnline: true,
                lastSeen: now,
                socketIds,
            };

            // Store in Redis with TTL
            await redis.setex(key, PRESENCE_TTL, JSON.stringify(presenceData));

            // Update database (async, don't block)
            User.findByIdAndUpdate(userId, {
                isOnline: true,
                lastSeen: new Date(),
            }).exec().catch(err => console.error('Failed to update user online status:', err));

            console.log(`✅ Presence: ${userId} is now online (socket: ${socketId})`);
        } catch (error) {
            console.error('❌ Presence setOnline error:', error);
        }
    }

    /**
     * Remove a socket connection for a user
     * Returns true if user is now completely offline
     */
    static async removeSocket(userId: string, socketId: string): Promise<boolean> {
        const key = `${PRESENCE_KEY_PREFIX}${userId}`;

        try {
            const existingData = await this.getPresence(userId);
            if (!existingData) return true;

            // Remove this socket from the list
            const socketIds = existingData.socketIds.filter(id => id !== socketId);

            if (socketIds.length === 0) {
                // User is completely offline
                const now = new Date();
                const presenceData: PresenceData = {
                    isOnline: false,
                    lastSeen: now.toISOString(),
                    socketIds: [],
                };

                await redis.setex(key, PRESENCE_TTL, JSON.stringify(presenceData));

                // Update database
                await User.findByIdAndUpdate(userId, {
                    isOnline: false,
                    lastSeen: now,
                });

                console.log(`✅ Presence: ${userId} is now offline`);
                return true;
            } else {
                // User still has other connections
                existingData.socketIds = socketIds;
                await redis.setex(key, PRESENCE_TTL, JSON.stringify(existingData));
                console.log(`📊 Presence: ${userId} removed socket ${socketId}, still has ${socketIds.length} connections`);
                return false;
            }
        } catch (error) {
            console.error('❌ Presence removeSocket error:', error);
            return true;
        }
    }

    /**
     * Get user's presence data from Redis
     */
    static async getPresence(userId: string): Promise<PresenceData | null> {
        try {
            const key = `${PRESENCE_KEY_PREFIX}${userId}`;
            const data = await redis.get(key);

            if (!data) {
                // Fallback to database
                const user = await User.findById(userId).select('isOnline lastSeen');
                if (user) {
                    return {
                        isOnline: user.isOnline,
                        lastSeen: user.lastSeen.toISOString(),
                        socketIds: [],
                    };
                }
                return null;
            }

            return JSON.parse(data) as PresenceData;
        } catch (error) {
            console.error('❌ Presence getPresence error:', error);
            return null;
        }
    }

    /**
     * Check if a user is online
     */
    static async isOnline(userId: string): Promise<boolean> {
        const presence = await this.getPresence(userId);
        return presence?.isOnline ?? false;
    }

    /**
     * Get presence for multiple users
     */
    static async getBulkPresence(userIds: string[]): Promise<Map<string, PresenceData>> {
        const result = new Map<string, PresenceData>();

        if (userIds.length === 0) return result;

        try {
            // Use Redis pipeline for efficiency
            const pipeline = redis.pipeline();
            for (const userId of userIds) {
                pipeline.get(`${PRESENCE_KEY_PREFIX}${userId}`);
            }

            const responses = await pipeline.exec();

            if (responses) {
                for (let i = 0; i < userIds.length; i++) {
                    const [err, data] = responses[i];
                    if (!err && data) {
                        result.set(userIds[i], JSON.parse(data as string));
                    }
                }
            }
        } catch (error) {
            console.error('❌ Presence getBulkPresence error:', error);
        }

        return result;
    }

    /**
     * Get user's contact IDs (for presence broadcasting)
     */
    static async getContactIds(userId: string): Promise<string[]> {
        try {
            // Get all contacts where user is either the owner or the contact
            const contacts = await Contact.find({
                $or: [
                    { userId, status: 'accepted' },
                    { contactId: userId, status: 'accepted' },
                ],
            }).select('userId contactId');

            const contactIds = new Set<string>();
            for (const contact of contacts) {
                const otherId = contact.userId.toString() === userId
                    ? contact.contactId.toString()
                    : contact.userId.toString();
                contactIds.add(otherId);
            }

            return Array.from(contactIds);
        } catch (error) {
            console.error('❌ Presence getContactIds error:', error);
            return [];
        }
    }

    /**
     * Refresh presence TTL (heartbeat)
     */
    static async refreshPresence(userId: string): Promise<void> {
        try {
            const key = `${PRESENCE_KEY_PREFIX}${userId}`;
            const exists = await redis.exists(key);

            if (exists) {
                await redis.expire(key, PRESENCE_TTL);
            }
        } catch (error) {
            console.error('❌ Presence refresh error:', error);
        }
    }

    /**
     * Get last seen time for a user
     */
    static async getLastSeen(userId: string): Promise<Date | null> {
        const presence = await this.getPresence(userId);
        if (presence) {
            return new Date(presence.lastSeen);
        }
        return null;
    }
}

export default PresenceService;
