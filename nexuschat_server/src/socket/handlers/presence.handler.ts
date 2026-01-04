import { Server } from 'socket.io';
import {
    AuthenticatedSocket,
    ServerToClientEvents,
    ClientToServerEvents,
} from '../types';
import PresenceService from '../../services/presence.service';

/**
 * Handle user coming online
 * - Update presence in Redis
 * - Broadcast to contacts only
 */
export const handleUserOnline = async (
    io: Server<ClientToServerEvents, ServerToClientEvents>,
    socket: AuthenticatedSocket
): Promise<void> => {
    const { userId } = socket.user;

    try {
        // Update presence in Redis
        await PresenceService.setOnline(userId, socket.id);

        // Get user's contacts to broadcast presence
        const contactIds = await PresenceService.getContactIds(userId);

        // Broadcast online status to contacts only
        for (const contactId of contactIds) {
            io.to(`user:${contactId}`).emit('user:online', userId);
        }

        console.log(`🟢 Presence broadcast: ${userId} online to ${contactIds.length} contacts`);
    } catch (error) {
        console.error('❌ Error handling user online:', error);
    }
};

/**
 * Handle user going offline
 * - Update presence in Redis
 * - Broadcast to contacts only
 */
export const handleUserOffline = async (
    io: Server<ClientToServerEvents, ServerToClientEvents>,
    socket: AuthenticatedSocket
): Promise<void> => {
    const { userId } = socket.user;

    try {
        // Remove this socket from presence tracking
        const isNowOffline = await PresenceService.removeSocket(userId, socket.id);

        if (isNowOffline) {
            // Get last seen time
            const lastSeen = await PresenceService.getLastSeen(userId);
            const lastSeenStr = lastSeen?.toISOString() || new Date().toISOString();

            // Get user's contacts to broadcast presence
            const contactIds = await PresenceService.getContactIds(userId);

            // Broadcast offline status to contacts only
            for (const contactId of contactIds) {
                io.to(`user:${contactId}`).emit('user:offline', {
                    userId,
                    lastSeen: lastSeenStr,
                });
            }

            console.log(`🔴 Presence broadcast: ${userId} offline to ${contactIds.length} contacts`);
        }
    } catch (error) {
        console.error('❌ Error handling user offline:', error);
    }
};

/**
 * Register presence-related event handlers
 */
export const registerPresenceHandlers = (
    _io: Server<ClientToServerEvents, ServerToClientEvents>,
    socket: AuthenticatedSocket
): void => {
    const { userId } = socket.user;

    // Handle presence heartbeat (keep-alive)
    socket.on('presence:heartbeat', async () => {
        await PresenceService.refreshPresence(userId);
    });

    // Handle presence query for specific users
    socket.on('presence:query', async (userIds: string[], callback) => {
        try {
            const presenceMap = await PresenceService.getBulkPresence(userIds);
            const result: Record<string, { isOnline: boolean; lastSeen: string }> = {};

            for (const uid of userIds) {
                const presence = presenceMap.get(uid);
                if (presence) {
                    result[uid] = {
                        isOnline: presence.isOnline,
                        lastSeen: presence.lastSeen,
                    };
                }
            }

            callback(result);
        } catch (error) {
            console.error('❌ Error querying presence:', error);
            callback({});
        }
    });
};

export default {
    handleUserOnline,
    handleUserOffline,
    registerPresenceHandlers,
};
