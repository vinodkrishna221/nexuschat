# Database Schema
## NexusChat - MongoDB Collections

---

## Overview

NexusChat uses MongoDB for flexible document storage. The schema is designed for:
- Fast message retrieval and pagination
- Efficient user search
- Real-time presence tracking
- Scalable chat history

---

## Collections

### 1. Users Collection

```javascript
// Collection: users
{
  _id: ObjectId("64a1b2c3d4e5f6789"),
  email: "user@example.com",              // Unique, indexed
  username: "johndoe",                     // Unique, indexed
  passwordHash: "$2b$12$...",             // bcrypt hash
  displayName: "John Doe",
  avatar: "https://cdn.nexuschat.app/avatars/abc123.jpg",
  bio: "Flutter developer & coffee enthusiast",
  status: "Available",                     // Custom status message
  
  // Online presence
  isOnline: true,
  lastSeen: ISODate("2026-01-03T05:30:00Z"),
  
  // Account status
  isVerified: true,
  isActive: true,
  
  // Password reset
  resetToken: null,
  resetTokenExpiry: null,
  
  // Refresh tokens (for multiple devices)
  refreshTokens: [
    {
      token: "hashed-refresh-token",
      device: "iPhone 15",
      createdAt: ISODate("2026-01-01T00:00:00Z"),
      expiresAt: ISODate("2026-01-08T00:00:00Z")
    }
  ],
  
  // Settings
  settings: {
    notifications: true,
    soundEnabled: true,
    theme: "dark"
  },
  
  // Timestamps
  createdAt: ISODate("2026-01-01T00:00:00Z"),
  updatedAt: ISODate("2026-01-03T05:30:00Z")
}
```

**Indexes:**
```javascript
// Unique indexes
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ username: 1 }, { unique: true });

// Full-text search index
db.users.createIndex({ displayName: "text", username: "text" });

// Compound indexes for performance
db.users.createIndex({ isOnline: 1, lastSeen: -1 });
db.users.createIndex({ isActive: 1, username: 1 }); // For user search
```

---

### 2. Contacts Collection

```javascript
// Collection: contacts
{
  _id: ObjectId("64b2c3d4e5f6789a"),
  userId: ObjectId("64a1b2c3d4e5f6789"),      // Owner of contact list
  contactId: ObjectId("64c3d4e5f6789ab0"),   // The contact user
  
  // Relationship status
  status: "accepted",    // "pending", "accepted", "blocked"
  blockedBy: null,       // userId if blocked
  
  // Metadata
  nickname: null,        // Optional custom nickname
  addedAt: ISODate("2026-01-02T00:00:00Z"),
  updatedAt: ISODate("2026-01-02T00:00:00Z")
}
```

**Indexes:**
```javascript
db.contacts.createIndex({ userId: 1, contactId: 1 }, { unique: true });
db.contacts.createIndex({ userId: 1, status: 1 });
db.contacts.createIndex({ contactId: 1 }); // For reverse lookups
```

---

### 3. Chats Collection

```javascript
// Collection: chats
{
  _id: ObjectId("64d4e5f6789ab0c1"),
  type: "direct",                           // "direct" | "group" (future)
  
  // Participants
  participants: [
    {
      userId: ObjectId("64a1b2c3d4e5f6789"),
      joinedAt: ISODate("2026-01-01T00:00:00Z"),
      deletedAt: null,                      // Soft delete for user
      lastReadMessageId: ObjectId("64f6789ab0c1d2e3")
    },
    {
      userId: ObjectId("64c3d4e5f6789ab0"),
      joinedAt: ISODate("2026-01-01T00:00:00Z"),
      deletedAt: null,
      lastReadMessageId: ObjectId("64f6789ab0c1d2e3")
    }
  ],
  
  // Quick access to last message (denormalized)
  lastMessage: {
    _id: ObjectId("64f6789ab0c1d2e3"),
    senderId: ObjectId("64c3d4e5f6789ab0"),
    content: "Hey there!",
    type: "text",
    createdAt: ISODate("2026-01-03T05:00:00Z")
  },
  
  // Timestamps
  createdAt: ISODate("2026-01-01T00:00:00Z"),
  updatedAt: ISODate("2026-01-03T05:00:00Z")
}
```

**Indexes:**
```javascript
db.chats.createIndex({ "participants.userId": 1 });
db.chats.createIndex({ updatedAt: -1 }); // For sorting chat list
db.chats.createIndex({ 
  "participants.userId": 1, 
  "participants.deletedAt": 1 
});
```

---

### 4. Messages Collection

```javascript
// Collection: messages
{
  _id: ObjectId("64f6789ab0c1d2e3"),
  chatId: ObjectId("64d4e5f6789ab0c1"),
  senderId: ObjectId("64a1b2c3d4e5f6789"),
  
  // Content
  content: "Hello! How are you?",
  type: "text",                            // "text" | "image" | "voice" | "file"
  
  // Attachments (for media messages)
  attachments: [
    {
      type: "image",
      url: "https://cdn.nexuschat.app/media/xyz123.jpg",
      thumbnail: "https://cdn.nexuschat.app/media/xyz123_thumb.jpg",
      size: 245000,
      dimensions: { width: 1920, height: 1080 }
    }
  ],
  
  // Message status tracking
  status: "read",                          // "sent" | "delivered" | "read"
  deliveredAt: ISODate("2026-01-03T05:00:01Z"),
  readBy: [
    {
      userId: ObjectId("64c3d4e5f6789ab0"),
      readAt: ISODate("2026-01-03T05:00:05Z")
    }
  ],
  
  // Soft delete
  deletedFor: [],                          // Array of userIds
  
  // Reply reference
  replyTo: null,                           // ObjectId of message being replied to
  
  // Timestamps
  createdAt: ISODate("2026-01-03T05:00:00Z"),
  editedAt: null
}
```

**Indexes (Critical for Performance):**
```javascript
// Primary query - message list with cursor pagination
db.messages.createIndex({ chatId: 1, _id: -1 });

// Compound index for message queries with soft delete
db.messages.createIndex({ chatId: 1, createdAt: -1, deletedFor: 1 });

// Unread message queries
db.messages.createIndex({ chatId: 1, status: 1, senderId: 1 });

// Read receipts calculation
db.messages.createIndex({ chatId: 1, "readBy.userId": 1 });

// Sender history
db.messages.createIndex({ senderId: 1, createdAt: -1 });
```

---

### 5. PushTokens Collection

```javascript
// Collection: push_tokens
{
  _id: ObjectId("64g789ab0c1d2e3f4"),
  userId: ObjectId("64a1b2c3d4e5f6789"),
  
  token: "fcm-or-apns-token-string",
  platform: "android",                     // "android" | "ios"
  device: "Samsung Galaxy S24",
  
  isActive: true,
  
  createdAt: ISODate("2026-01-01T00:00:00Z"),
  updatedAt: ISODate("2026-01-03T05:30:00Z")
}
```

**Indexes:**
```javascript
db.push_tokens.createIndex({ userId: 1 });
db.push_tokens.createIndex({ token: 1 }, { unique: true });
```

---

### 6. ArchivedMessages Collection (Cold Storage)

Messages older than 1 year are archived to this collection for cost optimization.

```javascript
// Collection: archived_messages
{
  _id: ObjectId("64h89ab0c1d2e3f45"),
  originalId: ObjectId("64f6789ab0c1d2e3"),   // Original message ID
  chatId: ObjectId("64d4e5f6789ab0c1"),
  
  // Compressed message data
  data: Binary("compressed-message-json"),
  
  // Archival metadata
  archivedAt: ISODate("2027-01-03T00:00:00Z"),
  originalCreatedAt: ISODate("2026-01-03T05:00:00Z")
}
```

**Indexes:**
```javascript
db.archived_messages.createIndex({ chatId: 1, originalCreatedAt: -1 });
db.archived_messages.createIndex({ originalId: 1 }, { unique: true });
```

**Archival Process:**
```javascript
// Monthly cron job to archive old messages
async function archiveOldMessages() {
  const oneYearAgo = new Date();
  oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);
  
  const cursor = db.messages.find({
    createdAt: { $lt: oneYearAgo }
  }).batchSize(1000);
  
  while (await cursor.hasNext()) {
    const batch = [];
    for (let i = 0; i < 1000 && await cursor.hasNext(); i++) {
      const msg = await cursor.next();
      batch.push({
        originalId: msg._id,
        chatId: msg.chatId,
        data: compress(JSON.stringify(msg)),
        archivedAt: new Date(),
        originalCreatedAt: msg.createdAt
      });
    }
    
    await db.archived_messages.insertMany(batch);
    await db.messages.deleteMany({
      _id: { $in: batch.map(b => b.originalId) }
    });
  }
}
```

---

## Relationships Diagram

```
┌───────────────────────────────────────────────────────────────────┐
│                        RELATIONSHIPS                               │
├───────────────────────────────────────────────────────────────────┤
│                                                                    │
│   ┌──────────┐         ┌────────────┐         ┌──────────────┐   │
│   │  USERS   │ ──1:N──>│  CONTACTS  │<──N:1── │    USERS     │   │
│   │          │         │            │         │  (contact)   │   │
│   └────┬─────┘         └────────────┘         └──────────────┘   │
│        │                                                          │
│        │ 1:N                                                      │
│        ▼                                                          │
│   ┌────────────┐                                                  │
│   │ PUSH_TOKENS│                                                  │
│   └────────────┘                                                  │
│                                                                    │
│   ┌──────────┐                                                    │
│   │  USERS   │──┐                                                 │
│   └──────────┘  │                                                 │
│                 │ N:M (participants)                              │
│   ┌──────────┐  │     ┌──────────┐         ┌──────────────┐      │
│   │  USERS   │──┼────>│  CHATS   │ ──1:N──>│   MESSAGES   │      │
│   └──────────┘  │     └──────────┘         └──────────────┘      │
│                 │            ▲                     │              │
│   ┌──────────┐  │            │                     │              │
│   │  USERS   │──┘            └─────────────────────┘              │
│   └──────────┘                   (senderId)                       │
│                                                                    │
└───────────────────────────────────────────────────────────────────┘
```

---

## Data Validation (Mongoose Schemas)

### User Schema Example

```javascript
const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\S+@\S+\.\S+$/, 'Invalid email format']
  },
  username: {
    type: String,
    required: true,
    unique: true,
    minlength: 3,
    maxlength: 20,
    match: [/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores']
  },
  passwordHash: {
    type: String,
    required: true
  },
  displayName: {
    type: String,
    required: true,
    minlength: 1,
    maxlength: 50
  },
  avatar: {
    type: String,
    default: null
  },
  bio: {
    type: String,
    maxlength: 150,
    default: ''
  },
  status: {
    type: String,
    maxlength: 50,
    default: 'Available'
  },
  isOnline: {
    type: Boolean,
    default: false
  },
  lastSeen: {
    type: Date,
    default: Date.now
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});
```

---

## Query Patterns

### Get User's Chats (Cursor Pagination)

```javascript
// Efficient cursor-based pagination
const getChats = async (userId, cursor, limit = 20) => {
  const query = {
    "participants.userId": userId,
    "participants.deletedAt": null
  };
  
  if (cursor) {
    query._id = { $lt: new ObjectId(cursor) };
  }
  
  return db.chats.aggregate([
    { $match: query },
    { $sort: { updatedAt: -1 } },
    { $limit: limit + 1 }, // +1 to check hasMore
    {
      $lookup: {
        from: "users",
        localField: "participants.userId",
        foreignField: "_id",
        as: "participantDetails",
        pipeline: [
          { $project: { displayName: 1, avatar: 1, isOnline: 1 } }
        ]
      }
    }
  ]);
};
```

### Get Chat Messages (Cursor Pagination)

```javascript
// O(1) performance with cursor pagination
const getMessages = async (chatId, cursor, limit = 50) => {
  const query = {
    chatId: new ObjectId(chatId),
    deletedFor: { $nin: [currentUserId] }
  };
  
  if (cursor) {
    query._id = { $lt: new ObjectId(cursor) };
  }
  
  const messages = await db.messages
    .find(query)
    .sort({ _id: -1 })
    .limit(limit + 1)
    .toArray();
  
  const hasMore = messages.length > limit;
  if (hasMore) messages.pop();
  
  return {
    messages,
    nextCursor: messages.length ? messages[messages.length - 1]._id : null,
    hasMore
  };
};
```

### Batch Unread Counts

```javascript
// Efficient aggregation for all chat unread counts
const getUnreadCounts = async (userId) => {
  return db.messages.aggregate([
    {
      $match: {
        "readBy.userId": { $ne: userId },
        senderId: { $ne: userId }
      }
    },
    {
      $group: {
        _id: "$chatId",
        count: { $sum: 1 }
      }
    }
  ]);
};
```

### Search Users (Optimized)

```javascript
// Uses compound index for fast search
db.users.find({
  isActive: true,
  $or: [
    { username: { $regex: `^${query}`, $options: 'i' } },
    { email: query } // Exact match only
  ]
})
.hint({ isActive: 1, username: 1 }) // Force index usage
.limit(20);
```

---

## Migration Strategy

For schema changes:
1. Add new fields with default values
2. Run background migration scripts
3. Update application code
4. Remove deprecated fields (if any)

---

*Database Schema Version: 1.0 | January 3, 2026*
