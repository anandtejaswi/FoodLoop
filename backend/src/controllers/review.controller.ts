// ============================================================
// src/controllers/review.controller.ts  –  Reviews & Ratings
// ============================================================
import { Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth.middleware';

// ── POST /api/reviews  ───────────────────────────────────────
export const postReview = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { request_id, rating, comment } = req.body as {
      request_id: number;
      rating: number;
      comment?: string;
    };

    if (!request_id || !rating) {
      res.status(400).json({ message: 'request_id and rating are required' });
      return;
    }
    if (rating < 1 || rating > 5) {
      res.status(400).json({ message: 'Rating must be between 1 and 5' });
      return;
    }

    // Verify request exists and is completed
    const [reqs] = await pool.query<any[]>(
      'SELECT * FROM requests WHERE id = ? LIMIT 1',
      [request_id]
    );
    if (!reqs.length)                      { res.status(404).json({ message: 'Request not found' }); return; }
    if (reqs[0].status !== 'completed')    { res.status(400).json({ message: 'Can only review completed requests' }); return; }
    if (reqs[0].taker_id !== req.userId)   { res.status(403).json({ message: 'Forbidden' }); return; }

    // Insert review
    await pool.query(
      'INSERT INTO reviews (request_id, reviewer_id, rating, comment) VALUES (?, ?, ?, ?)',
      [request_id, req.userId, rating, comment || '']
    );

    // Update giver's average rating
    const [food]  = await pool.query<any[]>('SELECT giver_id FROM food_items f JOIN requests r ON r.food_id = f.id WHERE r.id = ?', [request_id]);
    const giverId = food[0]?.giver_id;
    if (giverId) {
      await pool.query(
        `UPDATE users SET rating = (
          SELECT AVG(rv.rating) FROM reviews rv
          JOIN requests rq ON rv.request_id = rq.id
          JOIN food_items fi ON rq.food_id = fi.id
          WHERE fi.giver_id = ?
        ) WHERE id = ?`,
        [giverId, giverId]
      );
    }

    res.status(201).json({ message: 'Review submitted successfully' });
  } catch (err: any) {
    if (err.code === 'ER_DUP_ENTRY') {
      res.status(409).json({ message: 'You already reviewed this request' });
    } else {
      res.status(500).json({ message: err.message });
    }
  }
};

// ── GET /api/reviews/user/:id  ───────────────────────────────
export const getUserReviews = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.query<any[]>(
      `SELECT rv.*, u.name AS reviewer_name, u.avatar_url AS reviewer_avatar, f.title AS food_title
       FROM reviews rv
       JOIN users u ON rv.reviewer_id = u.id
       JOIN requests rq ON rv.request_id = rq.id
       JOIN food_items f ON rq.food_id = f.id
       WHERE f.giver_id = ?
       ORDER BY rv.created_at DESC`,
      [req.params.id]
    );
    res.json(rows);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};
