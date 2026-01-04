import mongoose, { Document, Schema, Types } from 'mongoose';

// Contact status types
export type ContactStatus = 'accepted' | 'blocked';

// Contact interface
export interface IContact extends Document {
    _id: Types.ObjectId;
    userId: Types.ObjectId;        // Owner of the contact
    contactId: Types.ObjectId;     // The contact user
    status: ContactStatus;
    blockedBy: Types.ObjectId | null;  // userId if blocked
    nickname: string | null;       // Optional custom nickname
    addedAt: Date;
    updatedAt: Date;
}

// Contact schema
const contactSchema = new Schema<IContact>(
    {
        userId: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: [true, 'User ID is required'],
        },
        contactId: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: [true, 'Contact ID is required'],
        },
        status: {
            type: String,
            enum: ['accepted', 'blocked'],
            default: 'accepted',
        },
        blockedBy: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            default: null,
        },
        nickname: {
            type: String,
            maxlength: [50, 'Nickname cannot exceed 50 characters'],
            default: null,
        },
        addedAt: {
            type: Date,
            default: Date.now,
        },
    },
    {
        timestamps: true,
    }
);

// Indexes for performance
contactSchema.index({ userId: 1, contactId: 1 }, { unique: true });
contactSchema.index({ userId: 1, status: 1 });
contactSchema.index({ contactId: 1 }); // For reverse lookups

// Transform output
contactSchema.set('toJSON', {
    virtuals: true,
    versionKey: false,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    transform: function (_doc: any, ret: any) {
        ret.id = ret._id;
        delete ret._id;
        return ret;
    },
});

// Create and export model
export const Contact = mongoose.model<IContact>('Contact', contactSchema);

export default Contact;
