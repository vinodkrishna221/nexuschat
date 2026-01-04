import { Router } from 'express';
import {
    getContacts,
    addContact,
    removeContact,
    blockUser,
    unblockUser,
    getBlockedUsers,
} from '../controllers/contact.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /contacts
 * @desc    Get user's contact list
 * @access  Private
 */
router.get('/', getContacts);

/**
 * @route   GET /contacts/blocked
 * @desc    Get list of blocked users
 * @access  Private
 */
router.get('/blocked', getBlockedUsers);

/**
 * @route   POST /contacts/add
 * @desc    Add a new contact
 * @access  Private
 */
router.post('/add', addContact);

/**
 * @route   POST /contacts/block
 * @desc    Block a user
 * @access  Private
 */
router.post('/block', blockUser);

/**
 * @route   POST /contacts/unblock
 * @desc    Unblock a user
 * @access  Private
 */
router.post('/unblock', unblockUser);

/**
 * @route   DELETE /contacts/:id
 * @desc    Remove a contact
 * @access  Private
 */
router.delete('/:id', removeContact);

export default router;
