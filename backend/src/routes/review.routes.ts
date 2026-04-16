// ============================================================
// src/routes/review.routes.ts
// ============================================================
import { Router } from 'express';
import { postReview, getUserReviews } from '../controllers/review.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// POST /api/reviews             – taker submits a review (auth)
router.post('/',          authMiddleware, postReview);

// GET  /api/reviews/user/:id    – get reviews for a user (public)
router.get('/user/:id',   getUserReviews);

export default router;
