import { Router } from 'express';
import authRoutes from './auth.routes';
import chatRoutes from './chat.routes';
import userRoutes from './user.routes';
import contactRoutes from './contact.routes';

const router = Router();

// Mount routes
router.use('/auth', authRoutes);
router.use('/chats', chatRoutes);
router.use('/users', userRoutes);
router.use('/contacts', contactRoutes);

export default router;

