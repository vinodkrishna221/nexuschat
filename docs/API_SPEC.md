# API Specification
## NexusChat - RESTful Endpoints

---

## Base Configuration

| Property | Value |
|----------|-------|
| Base URL | `https://api.nexuschat.app/v1` |
| Content-Type | `application/json` |
| Accept-Encoding | `gzip, deflate` |
| Authentication | Bearer Token (JWT) |

### Response Headers

| Header | Description |
|--------|-------------|
| `Content-Encoding` | `gzip` (responses > 1KB) |
| `ETag` | Response hash for cache validation |
| `X-RateLimit-Limit` | Rate limit ceiling |
| `X-RateLimit-Remaining` | Remaining requests |
| `X-RateLimit-Reset` | Reset timestamp |

### Rate Limiting Tiers

| Tier | Endpoints | Limit | Window |
|------|-----------|-------|--------|
| Standard | All endpoints | 100 req | 1 minute |
| Auth | `/auth/*` | 5 req | 15 minutes |
| Messaging | `/chats/*/messages` | 30 req | 1 second |
| Search | `/users/search` | 20 req | 1 minute |

---

## Authentication Endpoints

### POST /auth/register
Create a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "username": "johndoe",
  "displayName": "John Doe"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "64a1b2c3d4e5f6789",
      "email": "user@example.com",
      "username": "johndoe",
      "displayName": "John Doe",
      "avatar": null,
      "createdAt": "2026-01-03T05:30:00Z"
    },
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJSUzI1NiIs..."
  },
  "message": "Registration successful. Welcome email sent."
}
```

**Errors:**
| Code | Message |
|------|---------|
| 400 | Validation error |
| 409 | Email/username already exists |

---

### POST /auth/login
Authenticate existing user.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJSUzI1NiIs..."
  }
}
```

**Errors:**
| Code | Message |
|------|---------|
| 401 | Invalid credentials |
| 403 | Account suspended |

---

### POST /auth/refresh
Refresh access token.

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJSUzI1NiIs..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJSUzI1NiIs..."
  }
}
```

---

### POST /auth/forgot-password
Request password reset.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Password reset email sent"
}
```

---

### POST /auth/reset-password
Reset password with token.

**Request Body:**
```json
{
  "token": "reset-token-from-email",
  "newPassword": "NewSecurePass456!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Password updated successfully"
}
```

---

### POST /auth/logout
Logout and invalidate tokens.

**Headers:** `Authorization: Bearer <accessToken>`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## User Endpoints

### GET /users/me
Get current user profile.

**Headers:** `Authorization: Bearer <accessToken>`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "64a1b2c3d4e5f6789",
    "email": "user@example.com",
    "username": "johndoe",
    "displayName": "John Doe",
    "avatar": "https://cdn.nexuschat.app/avatars/abc123.jpg",
    "bio": "Flutter developer & coffee enthusiast",
    "status": "Available",
    "isOnline": true,
    "lastSeen": "2026-01-03T05:30:00Z",
    "createdAt": "2026-01-01T00:00:00Z"
  }
}
```

---

### PATCH /users/me
Update current user profile.

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body (partial):**
```json
{
  "displayName": "John D.",
  "bio": "Updated bio",
  "status": "Busy"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": { ...updatedUser }
}
```

---

### POST /users/me/avatar
Upload user avatar.

**Headers:** 
- `Authorization: Bearer <accessToken>`
- `Content-Type: multipart/form-data`

**Request:** Form data with `avatar` file field

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "avatar": "https://cdn.nexuschat.app/avatars/new-abc123.jpg"
  }
}
```

---

### GET /users/search
Search users by username or email.

**Headers:** `Authorization: Bearer <accessToken>`

**Query Parameters:**
- `q` (required): Search query
- `limit` (optional): Results limit (default: 20)

**Example:** `GET /users/search?q=john&limit=10`

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "64a1b2c3d4e5f6789",
      "username": "johndoe",
      "displayName": "John Doe",
      "avatar": "https://...",
      "isOnline": true
    }
  ]
}
```

---

### GET /users/:userId
Get user by ID.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "64a1b2c3d4e5f6789",
    "username": "johndoe",
    "displayName": "John Doe",
    "avatar": "https://...",
    "bio": "...",
    "status": "Available",
    "isOnline": true
  }
}
```

---

## Contact Endpoints

### GET /contacts
Get user's contact list.

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "contact-id",
      "user": {
        "id": "user-id",
        "username": "janedoe",
        "displayName": "Jane Doe",
        "avatar": "https://...",
        "isOnline": true,
        "status": "Available"
      },
      "addedAt": "2026-01-02T00:00:00Z"
    }
  ]
}
```

---

### POST /contacts/add
Add a new contact.

**Request Body:**
```json
{
  "userId": "64a1b2c3d4e5f6789"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": { ...contact },
  "message": "Contact added successfully"
}
```

---

### DELETE /contacts/:contactId
Remove a contact.

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Contact removed"
}
```

---

### POST /contacts/block
Block a user.

**Request Body:**
```json
{
  "userId": "64a1b2c3d4e5f6789"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "User blocked"
}
```

---

### POST /contacts/unblock
Unblock a user.

**Request Body:**
```json
{
  "userId": "64a1b2c3d4e5f6789"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "User unblocked"
}
```

---

## Chat Endpoints

### GET /chats
Get all user's chats with cursor-based pagination.

**Query Parameters:**
- `cursor` (optional): Last chat ID for pagination
- `limit` (optional): Per page (default: 20, max: 50)

**Example:** `GET /chats?cursor=64d4e5f6789ab0c1&limit=20`

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "chat-id",
      "participants": [
        { "id": "user1", "displayName": "John", "avatar": "...", "isOnline": true },
        { "id": "user2", "displayName": "Jane", "avatar": "...", "isOnline": false }
      ],
      "lastMessage": {
        "id": "msg-id",
        "content": "Hey there!",
        "senderId": "user2",
        "createdAt": "2026-01-03T05:00:00Z"
      },
      "unreadCount": 2,
      "updatedAt": "2026-01-03T05:00:00Z"
    }
  ],
  "pagination": {
    "nextCursor": "64d4e5f6789ab0c0",
    "hasMore": true
  }
}
```

---

### POST /chats
Create or get existing chat with user.

**Request Body:**
```json
{
  "participantId": "64a1b2c3d4e5f6789"
}
```

**Response (200/201):**
```json
{
  "success": true,
  "data": { ...chat }
}
```

---

### GET /chats/:chatId
Get chat details.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "chat-id",
    "participants": [...],
    "createdAt": "2026-01-01T00:00:00Z"
  }
}
```

---

### DELETE /chats/:chatId
Delete a chat (marks as deleted for user).

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Chat deleted"
}
```

---

## Message Endpoints

### GET /chats/:chatId/messages
Get chat messages with cursor-based pagination.

**Query Parameters:**
- `cursor` (optional): Message ID for pagination (loads older messages)
- `limit` (optional): Per page (default: 50, max: 100)
- `direction` (optional): `before` (default) or `after` cursor

**Example:** `GET /chats/:chatId/messages?cursor=64f6789ab0c1d2e3&limit=50`

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "msg-id",
      "chatId": "chat-id",
      "senderId": "user-id",
      "content": "Hello!",
      "type": "text",
      "status": "read",
      "readAt": "2026-01-03T05:01:00Z",
      "createdAt": "2026-01-03T05:00:00Z"
    }
  ],
  "pagination": {
    "nextCursor": "64f6789ab0c1d2e2",
    "prevCursor": "64f6789ab0c1d2e4",
    "hasMore": true
  }
}
```

---

### POST /chats/:chatId/messages
Send a message (REST fallback).

**Request Body:**
```json
{
  "content": "Hello!",
  "type": "text"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": { ...message }
}
```

---

### PATCH /chats/:chatId/messages/read
Batch mark messages as read.

**Request Body:**
```json
{
  "messageIds": ["msg-1", "msg-2", "msg-3"],
  // OR mark all messages before timestamp
  "beforeTimestamp": "2026-01-03T05:00:00Z"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "markedCount": 3
  }
}
```

---

## Batch Endpoints

### GET /users/presence
Batch fetch online status for multiple users.

**Query Parameters:**
- `ids` (required): Comma-separated user IDs (max: 50)

**Example:** `GET /users/presence?ids=user1,user2,user3`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user1": { "isOnline": true, "lastSeen": null },
    "user2": { "isOnline": false, "lastSeen": "2026-01-03T04:30:00Z" },
    "user3": { "isOnline": true, "lastSeen": null }
  }
}
```

---

### GET /chats/unread-counts
Batch fetch unread message counts for all chats.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "chat-id-1": 5,
    "chat-id-2": 0,
    "chat-id-3": 12
  },
  "total": 17
}
```

## Socket.IO Events

### Client → Server

| Event | Payload | Description |
|-------|---------|-------------|
| `message:send` | `{ chatId, content, type }` | Send message |
| `message:read` | `{ chatId, messageIds }` | Mark as read |
| `typing:start` | `{ chatId }` | Start typing |
| `typing:stop` | `{ chatId }` | Stop typing |
| `presence:online` | `{}` | User online |
| `presence:offline` | `{}` | User offline |

### Server → Client

| Event | Payload | Description |
|-------|---------|-------------|
| `message:new` | `{ message }` | New message |
| `message:delivered` | `{ messageId, chatId }` | Delivery confirmed |
| `message:read` | `{ messageIds, chatId, readBy }` | Read receipt |
| `user:typing` | `{ chatId, userId }` | Typing indicator |
| `user:online` | `{ userId }` | User online |
| `user:offline` | `{ userId, lastSeen }` | User offline |

---

## Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [
      { "field": "email", "message": "Email is required" }
    ]
  }
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Invalid input |
| `UNAUTHORIZED` | 401 | Not authenticated |
| `FORBIDDEN` | 403 | No permission |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource exists |
| `RATE_LIMITED` | 429 | Too many requests |
| `SERVER_ERROR` | 500 | Internal error |

---

*API Specification Version: 1.0 | January 3, 2026*
