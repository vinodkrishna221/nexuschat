import mongoose, { Document, Schema, Types } from 'mongoose';

// Message type enum
export type MessageType = 'text' | 'image' | 'file';

// Message status enum
export type MessageStatus = 'sent' | 'delivered' | 'read';

// Message interface
export interface IMessage extends Document {
    _id: Types.ObjectId;
    chat: Types.ObjectId;
    sender: Types.ObjectId;
    content: string;
    type: MessageType;
    status: MessageStatus;
    deliveredAt: Date | null;
    readAt: Date | null;
    createdAt: Date;
    updatedAt: Date;
}

// Message schema
const messageSchema = new Schema<IMessage>(
    {
        chat: {
            type: Schema.Types.ObjectId,
            ref: 'Chat',
            required: [true, 'Chat reference is required'],
            index: true,
        },
        sender: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: [true, 'Sender is required'],
            index: true,
        },
        content: {
            type: String,
            required: [true, 'Message content is required'],
            maxlength: [5000, 'Message cannot exceed 5000 characters'],
        },
        type: {
            type: String,
            enum: ['text', 'image', 'file'],
            default: 'text',
        },
        status: {
            type: String,
            enum: ['sent', 'delivered', 'read'],
            default: 'sent',
        },
        deliveredAt: {
            type: Date,
            default: null,
        },
        readAt: {
            type: Date,
            default: null,
        },
    },
    {
        timestamps: true,
    }
);

// Indexes for performance
// Primary query: Get messages for a chat, sorted by time
messageSchema.index({ chat: 1, createdAt: -1 });
// Secondary query: Get messages by sender
messageSchema.index({ sender: 1, createdAt: -1 });
// For cursor-based pagination
messageSchema.index({ chat: 1, _id: -1 });

// Transform output
messageSchema.set('toJSON', {
    virtuals: true,
    versionKey: false,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    transform: function (_doc: any, ret: any) {
        ret.id = ret._id;
        return ret;
    },
});

// Create and export model
export const Message = mongoose.model<IMessage>('Message', messageSchema);

export default Message;
