// ============================================================
// src/routes/user.routes.ts
// ============================================================
import { Router } from 'express';
import { getUserById, updateUser } from '../controllers/user.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// GET /api/users/:id     – public profile
router.get('/:id', getUserById);

// PUT /api/users/:id     – update own profile (auth required)
router.put('/:id', authMiddleware, updateUser);

export default router;
