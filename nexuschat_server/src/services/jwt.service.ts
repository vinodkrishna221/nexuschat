import jwt, { JwtPayload, SignOptions } from 'jsonwebtoken';
import { env } from '../config/env';

// Token payload interface
export interface TokenPayload {
    userId: string;
    email: string;
    type: 'access' | 'refresh';
}

// Decoded token interface
export interface DecodedToken extends JwtPayload {
    userId: string;
    email: string;
    type: 'access' | 'refresh';
}

// Token pair interface
export interface TokenPair {
    accessToken: string;
    refreshToken: string;
}

/**
 * Generate an access token
 */
export const generateAccessToken = (userId: string, email: string): string => {
    const payload: TokenPayload = {
        userId,
        email,
        type: 'access',
    };

    const options: SignOptions = {
        expiresIn: '7d',
    };

    return jwt.sign(payload, env.JWT_ACCESS_SECRET, options);
};

/**
 * Generate a refresh token
 */
export const generateRefreshToken = (userId: string, email: string): string => {
    const payload: TokenPayload = {
        userId,
        email,
        type: 'refresh',
    };

    const options: SignOptions = {
        expiresIn: '7d',
    };

    return jwt.sign(payload, env.JWT_REFRESH_SECRET, options);
};

/**
 * Generate both access and refresh tokens
 */
export const generateTokenPair = (userId: string, email: string): TokenPair => {
    return {
        accessToken: generateAccessToken(userId, email),
        refreshToken: generateRefreshToken(userId, email),
    };
};

/**
 * Verify an access token
 */
export const verifyAccessToken = (token: string): DecodedToken | null => {
    try {
        const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET) as DecodedToken;
        if (decoded.type !== 'access') {
            return null;
        }
        return decoded;
    } catch {
        return null;
    }
};

/**
 * Verify a refresh token
 */
export const verifyRefreshToken = (token: string): DecodedToken | null => {
    try {
        const decoded = jwt.verify(token, env.JWT_REFRESH_SECRET) as DecodedToken;
        if (decoded.type !== 'refresh') {
            return null;
        }
        return decoded;
    } catch {
        return null;
    }
};

/**
 * Get token expiry date
 */
export const getRefreshTokenExpiry = (): Date => {
    const match = env.JWT_REFRESH_EXPIRY.match(/^(\d+)([dhms])$/);
    if (!match) {
        return new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // Default 7 days
    }

    const value = parseInt(match[1], 10);
    const unit = match[2];

    const multipliers: Record<string, number> = {
        's': 1000,
        'm': 60 * 1000,
        'h': 60 * 60 * 1000,
        'd': 24 * 60 * 60 * 1000,
    };

    return new Date(Date.now() + value * multipliers[unit]);
};

export default {
    generateAccessToken,
    generateRefreshToken,
    generateTokenPair,
    verifyAccessToken,
    verifyRefreshToken,
    getRefreshTokenExpiry,
};
