# System Architecture
## NexusChat - Technical Infrastructure

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                    │
│  ┌─────────────────────┐      ┌─────────────────────┐                       │
│  │     iOS App         │      │    Android App      │                       │
│  │   (Flutter/Dart)    │      │   (Flutter/Dart)    │                       │
│  │  • Local Cache      │      │  • Local Cache      │                       │
│  │  • Optimistic UI    │      │  • Optimistic UI    │                       │
│  └──────────┬──────────┘      └──────────┬──────────┘                       │
│             │                            │                                   │
│             └───────────┬────────────────┘                                   │
│                         │                                                    │
│                         ▼                                                    │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    API GATEWAY / LOAD BALANCER                        │   │
│  │              (Nginx / AWS ALB + Compression + Rate Limiting)          │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                         │                                                    │
└─────────────────────────┼────────────────────────────────────────────────────┘
                          │
┌─────────────────────────┼────────────────────────────────────────────────────┐
│                         ▼           BACKEND LAYER                            │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                     NODE.JS + EXPRESS.JS                              │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐      │   │
│  │  │   Auth     │  │   Users    │  │   Chats    │  │  Messages  │      │   │
│  │  │  Service   │  │  Service   │  │  Service   │  │  Service   │      │   │
│  │  └────────────┘  └────────────┘  └────────────┘  └────────────┘      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                         │                                                    │
│  ┌──────────────────────┼───────────────────────────────────────────────┐   │
│  │                      ▼                                                │   │
│  │  ┌────────────────────────────────────────────────────────────────┐  │   │
│  │  │                    SOCKET.IO SERVER                            │  │   │
│  │  │         (Namespaced: /chat, /presence, /typing)                │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  │                      │                                                │   │
│  │  ┌───────────────────┼────────────────────────────────────────────┐  │   │
│  │  │                   ▼         REDIS LAYER                        │  │   │
│  │  │   ┌─────────────────────────────────────────────────────────┐ │  │   │
│  │  │   │ Socket Adapter │ Pub/Sub │ Session │ Rate Limit │ Queue │ │  │   │
│  │  │   └─────────────────────────────────────────────────────────┘ │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  │                      │                                                │   │
│  │  ┌───────────────────┼────────────────────────────────────────────┐  │   │
│  │  │                   ▼     MESSAGE QUEUE (BullMQ)                 │  │   │
│  │  │   ┌─────────────────────────────────────────────────────────┐ │  │   │
│  │  │   │  Message Processing │ Retry Logic │ Dead Letter Queue   │ │  │   │
│  │  │   └─────────────────────────────────────────────────────────┘ │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                         │                                                    │
└─────────────────────────┼────────────────────────────────────────────────────┘
                          │
┌─────────────────────────┼────────────────────────────────────────────────────┐
│                         ▼           DATA LAYER                               │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    MONGODB (Replica Set)                              │   │
│  │  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌────────────────────┐  │   │
│  │  │ PRIMARY  │  │SECONDARY │  │ SECONDARY │  │ Archived Messages  │  │   │
│  │  │ (Write)  │  │ (Read)   │  │  (Read)   │  │   (Cold Storage)   │  │   │
│  │  └──────────┘  └──────────┘  └───────────┘  └────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                        CDN + FILE STORAGE                             │   │
│  │  ┌────────────────┐          ┌───────────────────────────────────┐  │   │
│  │  │  CloudFront    │ ◄─────── │      AWS S3 / Cloudinary          │  │   │
│  │  │  (Edge Cache)  │          │  Avatars, Media, Voice Messages   │  │   │
│  │  │  TTL: 7-30 days│          └───────────────────────────────────┘  │   │
│  │  └────────────────┘                                                  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────┼────────────────────────────────────────────────────┐
│                         ▼        EXTERNAL SERVICES                           │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐             │
│  │  SendGrid  │  │    FCM     │  │    APNs    │  │ Cloudinary │             │
│  │   Email    │  │   (Push)   │  │   (Push)   │  │   (Media)  │             │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘             │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Technology Stack

### 2.1 Frontend (Flutter)

| Component | Technology | Purpose |
|-----------|------------|---------|
| Framework | Flutter 3.x | Cross-platform UI |
| Language | Dart | Type-safe development |
| State Management | Riverpod / BLoC | Reactive state |
| HTTP Client | Dio | REST API calls |
| WebSocket | socket_io_client | Real-time messaging |
| Local Storage | Hive / SharedPreferences | Offline data |
| Image Handling | cached_network_image | Avatar caching |
| Animations | flutter_animate | Micro-interactions |

### 2.2 Backend (Node.js)

| Component | Technology | Purpose |
|-----------|------------|---------|
| Runtime | Node.js 20+ (LTS) | Server environment |
| Framework | Express.js | REST API framework |
| Real-time | Socket.IO 4.x | WebSocket management |
| Message Queue | BullMQ | Reliable message processing |
| Validation | Zod | Type-safe input validation |
| Authentication | jsonwebtoken | JWT handling |
| Password Hashing | bcrypt | Secure passwords |
| Email | SendGrid | Transactional emails |
| File Upload | Multer + Sharp | Multipart + image optimization |
| Compression | compression | Response gzip/deflate |
| Rate Limiting | express-rate-limit + Redis | Tiered rate limiting |

### 2.3 Database

| Component | Technology | Purpose |
|-----------|------------|---------|
| Primary DB | MongoDB 7.x | Document storage |
| ODM | Mongoose 8.x | Schema modeling |
| Caching | Redis 7.x | Session/Socket/Queue state |
| File Storage | AWS S3 | Primary media storage |
| CDN | CloudFront | Edge caching for media |

---

## 3. Folder Structure

### 3.1 Flutter Client

```
nexuschat_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── colors.dart
│   │   │   ├── typography.dart
│   │   │   └── api_endpoints.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── dark_theme.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   └── formatters.dart
│   │   └── errors/
│   │       └── exceptions.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── message_model.dart
│   │   │   └── chat_model.dart
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── chat_repository.dart
│   │   │   └── user_repository.dart
│   │   └── providers/
│   │       ├── auth_provider.dart
│   │       └── socket_provider.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   └── widgets/
│   │   ├── chat/
│   │   │   ├── screens/
│   │   │   │   ├── chat_list_screen.dart
│   │   │   │   └── chat_screen.dart
│   │   │   └── widgets/
│   │   │       ├── message_bubble.dart
│   │   │       ├── chat_input.dart
│   │   │       └── typing_indicator.dart
│   │   ├── contacts/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── profile/
│   │       ├── screens/
│   │       └── widgets/
│   └── shared/
│       └── widgets/
│           ├── custom_button.dart
│           ├── avatar.dart
│           └── loading_indicator.dart
├── assets/
│   ├── images/
│   ├── icons/
│   └── animations/
├── test/
└── pubspec.yaml
```

### 3.2 Node.js Backend

```
nexuschat_server/
├── src/
│   ├── index.js
│   ├── app.js
│   ├── config/
│   │   ├── database.js
│   │   ├── redis.js
│   │   └── env.js
│   ├── middleware/
│   │   ├── auth.js
│   │   ├── validation.js
│   │   ├── errorHandler.js
│   │   └── rateLimiter.js
│   ├── models/
│   │   ├── User.js
│   │   ├── Chat.js
│   │   ├── Message.js
│   │   └── Contact.js
│   ├── routes/
│   │   ├── index.js
│   │   ├── auth.routes.js
│   │   ├── users.routes.js
│   │   ├── chats.routes.js
│   │   └── messages.routes.js
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── users.controller.js
│   │   ├── chats.controller.js
│   │   └── messages.controller.js
│   ├── services/
│   │   ├── email.service.js
│   │   ├── jwt.service.js
│   │   └── upload.service.js
│   ├── socket/
│   │   ├── index.js
│   │   ├── handlers/
│   │   │   ├── message.handler.js
│   │   │   ├── presence.handler.js
│   │   │   └── typing.handler.js
│   │   └── middleware/
│   │       └── socketAuth.js
│   └── utils/
│       ├── logger.js
│       └── helpers.js
├── tests/
├── .env.example
└── package.json
```

---

## 4. Data Flow Diagrams

### 4.1 Authentication Flow

```
┌────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ Client │     │   API   │     │  Auth   │     │ MongoDB │     │  Email  │
│  App   │     │ Gateway │     │ Service │     │         │     │ Service │
└───┬────┘     └────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘
    │               │               │               │               │
    │  POST /signup │               │               │               │
    │──────────────>│               │               │               │
    │               │   Validate    │               │               │
    │               │──────────────>│               │               │
    │               │               │  Check email  │               │
    │               │               │──────────────>│               │
    │               │               │<──────────────│               │
    │               │               │  Hash pass    │               │
    │               │               │  Create user  │               │
    │               │               │──────────────>│               │
    │               │               │<──────────────│               │
    │               │               │  Send email   │               │
    │               │               │──────────────────────────────>│
    │               │               │  Generate JWT │               │
    │               │<──────────────│               │               │
    │<──────────────│               │               │               │
    │  JWT + User   │               │               │               │
```

### 4.2 Real-time Message Flow (with Queue)

```
┌────────┐   ┌──────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌────────┐
│ Sender │   │ Socket.IO│   │ BullMQ  │   │  Worker │   │ MongoDB │   │Receiver│
│ Client │   │  Server  │   │  Queue  │   │         │   │         │   │ Client │
└───┬────┘   └────┬─────┘   └────┬────┘   └────┬────┘   └────┬────┘   └────┬───┘
    │             │              │             │             │             │
    │ msg:send    │              │             │             │             │
    │────────────>│              │             │             │             │
    │             │   Enqueue    │             │             │             │
    │             │─────────────>│             │             │             │
    │   msg:queued│              │             │             │             │
    │<────────────│              │             │             │             │
    │             │              │   Process   │             │             │
    │             │              │────────────>│             │             │
    │             │              │             │   Save      │             │
    │             │              │             │────────────>│             │
    │             │              │             │   Broadcast │             │
    │             │              │             │────────────────────────────>│
    │             │              │             │             │   msg:new   │
    │             │              │             │             │────────────>│
    │             │              │             │             │             │
    │             │              │             │             │ msg:read    │
    │             │<───────────────────────────────────────────────────────│
    │ status:read │              │             │             │             │
    │<────────────│              │             │             │             │
```

**Queue Benefits:**
- Instant acknowledgment to sender (< 100ms)
- Guaranteed delivery with retry logic
- Dead letter queue for failed messages
- Handles traffic spikes gracefully

---

## 5. Security Architecture

### 5.1 Authentication & Authorization

| Layer | Implementation |
|-------|----------------|
| Password Storage | bcrypt (12 salt rounds) |
| Token Type | JWT (RS256) |
| Access Token TTL | 15 minutes |
| Refresh Token TTL | 7 days |
| Token Storage | HttpOnly cookies (web), Secure storage (mobile) |

### 5.2 API Security

```
┌─────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                           │
├─────────────────────────────────────────────────────────────┤
│  1. HTTPS/TLS 1.3        │ Encrypted transport             │
│  2. Rate Limiting        │ 100 req/min per IP              │
│  3. Input Validation     │ Joi/Zod schemas                 │
│  4. JWT Verification     │ Signature + expiry check        │
│  5. CORS Policy          │ Whitelist origins               │
│  6. Helmet.js            │ Security headers                │
│  7. MongoDB Injection    │ Mongoose sanitization           │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. Scalability Strategy

### 6.1 Horizontal Scaling

```
                    ┌────────────────┐
                    │  Load Balancer │
                    │ (Sticky Sessions)│
                    └───────┬────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼───────┐   ┌───────▼───────┐   ┌───────▼───────┐
│   Node.js     │   │   Node.js     │   │   Node.js     │
│  Instance 1   │   │  Instance 2   │   │  Instance 3   │
│  + Workers    │   │  + Workers    │   │  + Workers    │
└───────┬───────┘   └───────┬───────┘   └───────┬───────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐
│  Redis Cluster │  │  Redis Cluster │  │  Redis Cluster │
│    (Queue)     │  │   (Pub/Sub)    │  │   (Cache)      │
└───────┬────────┘  └───────┬────────┘  └───────┬────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐
│  MongoDB       │  │  MongoDB       │  │  MongoDB       │
│  PRIMARY       │  │  SECONDARY     │  │  SECONDARY     │
│  (Write)       │  │  (Read)        │  │  (Read)        │
└────────────────┘  └────────────────┘  └────────────────┘
```

### 6.2 Capacity Planning

| Component | Initial | Scale Trigger | Max | Notes |
|-----------|---------|---------------|-----|-------|
| Node.js API | 2 instances | CPU > 70% | 10 | Auto-scaling |
| Queue Workers | 2 workers | Queue depth > 1000 | 8 | Separate from API |
| MongoDB | 1 primary + 2 secondary | Storage > 80% | Sharded | Read replicas for queries |
| Redis Cluster | 3 nodes | Memory > 75% | 6 nodes | Separate for queue/pub-sub |
| CDN | CloudFront | - | - | Edge locations auto-scale |

---

## 7. Deployment Architecture

### Development
- Local Docker Compose
- MongoDB Atlas (free tier)
- Redis Cloud (free tier)

### Production (AWS Example)
- EC2/ECS for Node.js
- DocumentDB for MongoDB
- ElastiCache for Redis
- S3 for file storage
- CloudFront CDN
- Route 53 DNS

---

*Architecture Version: 1.0 | January 3, 2026*
