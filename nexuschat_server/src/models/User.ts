import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcrypt';

// User interface
export interface IUser extends Document {
    email: string;
    username: string;
    passwordHash: string;
    displayName: string;
    avatar: string | null;
    bio: string;
    status: string;
    isOnline: boolean;
    lastSeen: Date;
    isVerified: boolean;
    isActive: boolean;
    resetToken: string | null;
    resetTokenExpiry: Date | null;
    refreshTokens: Array<{
        token: string;
        device: string;
        createdAt: Date;
        expiresAt: Date;
    }>;
    settings: {
        notifications: boolean;
        soundEnabled: boolean;
        theme: 'dark' | 'light';
    };
    createdAt: Date;
    updatedAt: Date;

    // Methods
    comparePassword(password: string): Promise<boolean>;
}

// User schema
const userSchema = new Schema<IUser>(
    {
        email: {
            type: String,
            required: [true, 'Email is required'],
            unique: true,
            lowercase: true,
            trim: true,
            match: [/^\S+@\S+\.\S+$/, 'Invalid email format'],
        },
        username: {
            type: String,
            required: [true, 'Username is required'],
            unique: true,
            minlength: [3, 'Username must be at least 3 characters'],
            maxlength: [20, 'Username cannot exceed 20 characters'],
            match: [/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores'],
        },
        passwordHash: {
            type: String,
            required: true,
            select: false, // Don't include in queries by default
        },
        displayName: {
            type: String,
            required: [true, 'Display name is required'],
            minlength: [1, 'Display name is required'],
            maxlength: [50, 'Display name cannot exceed 50 characters'],
        },
        avatar: {
            type: String,
            default: null,
        },
        bio: {
            type: String,
            maxlength: [150, 'Bio cannot exceed 150 characters'],
            default: '',
        },
        status: {
            type: String,
            maxlength: [50, 'Status cannot exceed 50 characters'],
            default: 'Available',
        },
        isOnline: {
            type: Boolean,
            default: false,
        },
        lastSeen: {
            type: Date,
            default: Date.now,
        },
        isVerified: {
            type: Boolean,
            default: false,
        },
        isActive: {
            type: Boolean,
            default: true,
        },
        resetToken: {
            type: String,
            default: null,
        },
        resetTokenExpiry: {
            type: Date,
            default: null,
        },
        refreshTokens: [
            {
                token: { type: String, required: true },
                device: { type: String, default: 'Unknown' },
                createdAt: { type: Date, default: Date.now },
                expiresAt: { type: Date, required: true },
            },
        ],
        settings: {
            notifications: { type: Boolean, default: true },
            soundEnabled: { type: Boolean, default: true },
            theme: { type: String, enum: ['dark', 'light'], default: 'dark' },
        },
    },
    {
        timestamps: true,
    }
);

// Indexes for performance (email and username already have unique:true which creates indexes)
userSchema.index({ displayName: 'text', username: 'text' });
userSchema.index({ isOnline: 1, lastSeen: -1 });
userSchema.index({ isActive: 1, username: 1 });

// Hash password before saving
userSchema.pre('save', async function () {
    if (!this.isModified('passwordHash')) {
        return;
    }

    const salt = await bcrypt.genSalt(12);
    this.passwordHash = await bcrypt.hash(this.passwordHash, salt);
});

// Compare password method
userSchema.methods.comparePassword = async function (password: string): Promise<boolean> {
    return bcrypt.compare(password, this.passwordHash);
};

// Transform output (remove sensitive fields)
userSchema.set('toJSON', {
    virtuals: true,
    transform: function (_doc, ret) {
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        const { passwordHash, refreshTokens, resetToken, resetTokenExpiry, __v, ...rest } = ret;
        return rest;
    },
});

// Create and export model
export const User = mongoose.model<IUser>('User', userSchema);

export default User;
