// ============================================================
// src/controllers/food.controller.ts  –  Food Listings CRUD
// ============================================================
import { Request, Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth.middleware';

// ── GET /api/food  ───────────────────────────────────────────
// Query params: lat, lng, radius (km), category, status
export const getFoodItems = async (req: Request, res: Response): Promise<void> => {
  try {
    const { lat, lng, radius = '10', category, status = 'available' } = req.query as Record<string, string>;

    let sql = `
      SELECT
        f.*,
        u.name      AS giver_name,
        u.avatar_url AS giver_avatar,
        u.rating     AS giver_rating
        ${lat && lng ? `,
        (6371 * ACOS(
          COS(RADIANS(?)) * COS(RADIANS(f.lat)) *
          COS(RADIANS(f.lng) - RADIANS(?)) +
          SIN(RADIANS(?)) * SIN(RADIANS(f.lat))
        )) AS distance_km` : ''}
      FROM food_items f
      JOIN users u ON f.giver_id = u.id
      WHERE f.expiry_time > NOW()
    `;

    const params: any[] = [];

    if (lat && lng) {
      params.push(lat, lng, lat);           // for SELECT distance calc
    }

    if (status)   { sql += ` AND f.status = ?`;   params.push(status); }
    if (category) { sql += ` AND f.category = ?`; params.push(category); }

    if (lat && lng) {
      sql += ` HAVING distance_km <= ?`;
      params.push(Number(radius));
      sql += ` ORDER BY distance_km ASC`;
    } else {
      sql += ` ORDER BY f.created_at DESC`;
    }

    sql += ` LIMIT 100`;

    const [rows] = await pool.query<any[]>(sql, params);
    res.json(rows);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

// ── GET /api/food/mine  ──────────────────────────────────────
export const getMyFoodItems = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.query<any[]>(
      `SELECT f.*, u.name AS giver_name, u.avatar_url AS giver_avatar, u.rating AS giver_rating
       FROM food_items f JOIN users u ON f.giver_id = u.id
       WHERE f.giver_id = ? ORDER BY f.created_at DESC`,
      [req.userId]
    );
    res.json(rows);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

// ── GET /api/food/:id  ───────────────────────────────────────
export const getFoodItem = async (req: Request, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.query<any[]>(
      `SELECT f.*, u.name AS giver_name, u.avatar_url AS giver_avatar, u.rating AS giver_rating
       FROM food_items f JOIN users u ON f.giver_id = u.id
       WHERE f.id = ? LIMIT 1`,
      [req.params.id]
    );
    if (!rows.length) { res.status(404).json({ message: 'Food item not found' }); return; }
    res.json(rows[0]);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

// ── POST /api/food  ──────────────────────────────────────────
export const createFoodItem = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { title, category, description, quantity, quantity_unit, lat, lng, address, expiry_time, giver_phone } = req.body;

    if (!title || !lat || !lng || !expiry_time) {
      res.status(400).json({ message: 'title, lat, lng, expiry_time are required' });
      return;
    }

    const photo_url = (req as any).file
      ? `/uploads/${(req as any).file.filename}`
      : null;

    const [result] = await pool.query<any>(
      `INSERT INTO food_items
        (giver_id, title, category, description, quantity, quantity_unit, lat, lng, address, expiry_time, photo_url, giver_phone)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [req.userId, title, category || 'other', description || '', quantity || 1, quantity_unit || 'portions', lat, lng, address || '', expiry_time, photo_url, giver_phone || null]
    );

    const [rows] = await pool.query<any[]>(
      `SELECT f.*, u.name AS giver_name, u.avatar_url AS giver_avatar, u.rating AS giver_rating
       FROM food_items f JOIN users u ON f.giver_id = u.id WHERE f.id = ?`,
      [result.insertId]
    );
    res.status(201).json(rows[0]);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

// ── DELETE /api/food/:id  ────────────────────────────────────
export const deleteFoodItem = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.query<any[]>('SELECT giver_id FROM food_items WHERE id = ?', [req.params.id]);
    if (!rows.length) { res.status(404).json({ message: 'Not found' }); return; }
    if (rows[0].giver_id !== req.userId) { res.status(403).json({ message: 'Forbidden' }); return; }

    await pool.query('DELETE FROM food_items WHERE id = ?', [req.params.id]);
    res.json({ message: 'Deleted successfully' });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

// ── PUT /api/food/:id/status  ────────────────────────────────
export const updateFoodStatus = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { status } = req.body as { status: string };
    await pool.query('UPDATE food_items SET status = ? WHERE id = ? AND giver_id = ?', [status, req.params.id, req.userId]);
    res.json({ message: 'Status updated' });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};
