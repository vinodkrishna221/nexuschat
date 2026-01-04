import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import {
    getChats,
    createOrGetChat,
    getChatMessages,
} from '../controllers/chat.controller';

const router = Router();

// All chat routes require authentication
router.use(authenticate);

/**
 * @route   GET /chats
 * @desc    Get all chats for authenticated user
 * @access  Private
 */
router.get('/', getChats);

/**
 * @route   POST /chats
 * @desc    Create or get existing chat with another user
 * @access  Private
 * @body    { recipientId: string }
 */
router.post('/', createOrGetChat);

/**
 * @route   GET /chats/:id/messages
 * @desc    Get paginated messages for a chat
 * @access  Private
 * @query   cursor (optional) - Message ID to paginate from
 * @query   limit (optional) - Number of messages (default: 50, max: 100)
 */
router.get('/:id/messages', getChatMessages);

export default router;
