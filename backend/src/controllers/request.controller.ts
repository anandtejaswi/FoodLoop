// ============================================================
// src/controllers/request.controller.ts  –  Food Requests
// ============================================================
import { Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth.middleware';

// ── POST /api/requests  ──────────────────────────────────────
// Taker creates a request for a food item
export const createRequest = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { food_id } = req.body as { food_id: number };
    if (!food_id) { res.status(400).json({ message: 'food_id required' }); return; }

    // Check food exists and is available
    const [food] = await pool.query<any[]>(
      'SELECT id, status FROM food_items WHERE id = ? LIMIT 1',
      [food_id]
    );
    if (!food.length)                     { res.status(404).json({ message: 'Food not found' }); return; }
    if (food[0].status !== 'available')   { res.status(400).json({ message: 'Food is no longer available' }); return; }

    const [result] = await pool.query<any>(
      'INSERT INTO requests (food_id, taker_id) VALUES (?, ?)',
      [food_id, req.userId]
    );

    const [rows] = await pool.query<any[]>(
      `SELECT r.*,
              f.title        AS food_title,
              f.photo_url    AS food_photo_url,
              f.giver_phone  AS giver_phone,
              g.id           AS giver_id,
              g.name         AS giver_name,
              t.id           AS taker_id,
              t.name         AS taker_name,
              t.avatar_url   AS taker_avatar
       FROM requests r
       JOIN food_items f ON r.food_id  = f.id
       JOIN users      g ON f.giver_id = g.id
       JOIN users      t ON r.taker_id = t.id
       WHERE r.id = ?`,
      [result.insertId]
    );
    res.status(201).json(rows[0]);
  } catch (err: any) {
    if (err.code === 'ER_DUP_ENTRY') {
      res.status(409).json({ message: 'You already requested this item' });
    } else {
      res.status(500).json({ message: err.message });
    }
  }
};

// ── GET /api/requests/giver  ─────────────────────────────────
// All requests for items posted by the current giver
export const getGiverRequests = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.query<any[]>(
      `SELECT r.*,
              f.title        AS food_title,
              f.photo_url    AS food_photo_url,
              f.giver_phone  AS giver_phone,
              g.id           AS giver_id,
              g.name         AS giver_name,
              t.id           AS taker_id,
              t.name         AS taker_name,
              t.avatar_url   AS taker_avatar
       FROM requests r
       JOIN food_items f ON r.food_id  = f.id
       JOIN users      g ON f.giver_id = g.id
       JOIN users      t ON r.taker_id = t.id
       WHERE g.id = ?
       ORDER BY r.created_at DESC`,
      [req.userId]
    );
    res.json(rows);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

// ── GET /api/requests/taker  ─────────────────────────────────
// All requests made by the current taker
export const getTakerRequests = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.query<any[]>(
      `SELECT r.*,
              f.title        AS food_title,
              f.photo_url    AS food_photo_url,
              f.giver_phone  AS giver_phone,
              g.id           AS giver_id,
              g.name         AS giver_name,
              t.id           AS taker_id,
              t.name         AS taker_name,
              t.avatar_url   AS taker_avatar
       FROM requests r
       JOIN food_items f ON r.food_id  = f.id
       JOIN users      g ON f.giver_id = g.id
       JOIN users      t ON r.taker_id = t.id
       WHERE r.taker_id = ?
       ORDER BY r.created_at DESC`,
      [req.userId]
    );
    res.json(rows);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

// ── PUT /api/requests/:id  ───────────────────────────────────
// Giver accepts/rejects, or marks completed
export const updateRequestStatus = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { status } = req.body as { status: 'accepted' | 'rejected' | 'completed' };
    const validStatuses = ['accepted', 'rejected', 'completed'];
    if (!validStatuses.includes(status)) { res.status(400).json({ message: 'Invalid status' }); return; }

    // Verify the acting user is the giver of the related food
    const [rows] = await pool.query<any[]>(
      `SELECT r.id, f.giver_id FROM requests r JOIN food_items f ON r.food_id = f.id WHERE r.id = ?`,
      [req.params.id]
    );
    if (!rows.length) { res.status(404).json({ message: 'Request not found' }); return; }
    if (rows[0].giver_id !== req.userId) { res.status(403).json({ message: 'Forbidden' }); return; }

    await pool.query('UPDATE requests SET status = ? WHERE id = ?', [status, req.params.id]);

    // If accepted, mark food as claimed
    if (status === 'accepted') {
      const [reqRow] = await pool.query<any[]>('SELECT food_id FROM requests WHERE id = ?', [req.params.id]);
      await pool.query("UPDATE food_items SET status = 'claimed' WHERE id = ?", [reqRow[0].food_id]);
    }

    // If completed, add impact score to giver
    if (status === 'completed') {
      await pool.query('UPDATE users SET impact_score = impact_score + 1, points = points + 10 WHERE id = ?', [req.userId]);
    }

    const [updated] = await pool.query<any[]>('SELECT * FROM requests WHERE id = ?', [req.params.id]);
    res.json(updated[0]);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};
