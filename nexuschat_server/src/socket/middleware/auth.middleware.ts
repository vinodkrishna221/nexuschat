import { Socket } from 'socket.io';
import { verifyAccessToken, DecodedToken } from '../../services/jwt.service';
import { AuthenticatedSocket } from '../types';

/**
 * Socket.IO authentication middleware
 * Validates JWT token from handshake and attaches user data to socket
 */
export const socketAuthMiddleware = (
    socket: Socket,
    next: (err?: Error) => void
): void => {
    try {
        // Get token from handshake auth or query params
        const token =
            socket.handshake.auth?.token ||
            socket.handshake.query?.token as string;

        if (!token) {
            console.log(`🔒 Socket auth failed: No token provided [${socket.id}]`);
            return next(new Error('Authentication required'));
        }

        // Verify the access token
        const decoded: DecodedToken | null = verifyAccessToken(token);

        if (!decoded) {
            console.log(`🔒 Socket auth failed: Invalid token [${socket.id}]`);
            return next(new Error('Invalid or expired token'));
        }

        // Attach user data to socket
        (socket as AuthenticatedSocket).user = {
            userId: decoded.userId,
            email: decoded.email,
        };

        console.log(`🔓 Socket authenticated: ${decoded.email} [${socket.id}]`);
        next();
    } catch (error) {
        console.error('❌ Socket auth error:', error);
        next(new Error('Authentication failed'));
    }
};

export default socketAuthMiddleware;
