// ============================================================
// src/routes/auth.routes.ts
// ============================================================
import { Router } from 'express';
import { signUp, signIn, getMe, changePassword, googleSignIn } from '../controllers/auth.controller';
import { authMiddleware } from '../middleware/auth.middleware';
import { rateLimitMiddleware, resetRateLimit } from '../middleware/rateLimit.middleware';
import { validateSignUp, validateSignIn } from '../middleware/validation.middleware';

const router = Router();

// POST /api/auth/signup      – register with email/password
router.post('/signup', validateSignUp, signUp);

// POST /api/auth/signin      – login with email/password
router.post('/signin', rateLimitMiddleware, validateSignIn, signIn);

// GET  /api/auth/me          – get current user from JWT
router.get('/me', authMiddleware, getMe);

// POST /api/auth/change-password  – change password (requires auth)
router.post('/change-password', authMiddleware, changePassword);

// POST /api/auth/google      – verify Google ID token (deprecated)
router.post('/google', googleSignIn);

export default router;
