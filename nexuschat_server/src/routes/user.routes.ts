import { Router } from 'express';
import {
    getMe,
    updateMe,
    uploadAvatar,
    getUserById,
    searchUsers,
} from '../controllers/user.controller';
import { authenticate } from '../middleware/auth.middleware';
import { avatarUpload } from '../config/upload.config';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /users/me
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/me', getMe);

/**
 * @route   PATCH /users/me
 * @desc    Update current user profile
 * @access  Private
 */
router.patch('/me', updateMe);

/**
 * @route   POST /users/me/avatar
 * @desc    Upload user avatar
 * @access  Private
 */
router.post('/me/avatar', avatarUpload.single('avatar'), uploadAvatar);

/**
 * @route   GET /users/search
 * @desc    Search users by username or display name
 * @access  Private
 */
router.get('/search', searchUsers);

/**
 * @route   GET /users/:id
 * @desc    Get user by ID (public profile)
 * @access  Private
 */
router.get('/:id', getUserById);

export default router;
