import mongoose, { Document, Schema, Types } from 'mongoose';

// Chat interface
export interface IChat extends Document {
    _id: Types.ObjectId;
    participants: Types.ObjectId[];
    lastMessage: Types.ObjectId | null;
    lastActivity: Date;
    createdAt: Date;
    updatedAt: Date;
}

// Chat schema
const chatSchema = new Schema<IChat>(
    {
        participants: {
            type: [{ type: Schema.Types.ObjectId, ref: 'User' }],
            required: true,
            validate: {
                validator: function (v: Types.ObjectId[]) {
                    return v.length === 2;
                },
                message: 'Chat must have exactly 2 participants',
            },
        },
        lastMessage: {
            type: Schema.Types.ObjectId,
            ref: 'Message',
            default: null,
        },
        lastActivity: {
            type: Date,
            default: Date.now,
        },
    },
    {
        timestamps: true,
    }
);

// Indexes for performance
chatSchema.index({ participants: 1 });
chatSchema.index({ lastActivity: -1 });
// Compound index to find chats between two specific users
chatSchema.index({ participants: 1, lastActivity: -1 });

// Transform output
chatSchema.set('toJSON', {
    virtuals: true,
    versionKey: false,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    transform: function (_doc: any, ret: any) {
        ret.id = ret._id;
        return ret;
    },
});

// Create and export model
export const Chat = mongoose.model<IChat>('Chat', chatSchema);

export default Chat;
