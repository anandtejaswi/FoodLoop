// ============================================================
// src/controllers/user.controller.ts  –  User Profile & Role
// ============================================================
import { Response } from 'express';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth.middleware';

// ── GET /api/users/:id  ──────────────────────────────────────
export const getUserById = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const [rows] = await pool.query<any[]>(
      `SELECT id, name, email, avatar_url, role, points, rating, impact_score, created_at
       FROM users WHERE id = ? LIMIT 1`,
      [id]
    );
    if (!rows.length) { res.status(404).json({ message: 'User not found' }); return; }
    res.json(rows[0]);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

// ── PUT /api/users/:id  ──────────────────────────────────────
// Update name, avatar, or role
export const updateUser = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;

    // Only allow updating own profile
    if (req.userId !== Number(id)) {
      res.status(403).json({ message: 'Forbidden' });
      return;
    }

    const { name, avatar_url, role } = req.body as {
      name?: string;
      avatar_url?: string;
      role?: 'giver' | 'taker';
    };

    const fields: string[] = [];
    const values: any[]   = [];

    if (name)       { fields.push('name = ?');       values.push(name); }
    if (avatar_url) { fields.push('avatar_url = ?'); values.push(avatar_url); }
    if (role)       { fields.push('role = ?');       values.push(role); }

    if (!fields.length) { res.status(400).json({ message: 'No fields to update' }); return; }

    values.push(id);
    await pool.query(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`, values);

    const [rows] = await pool.query<any[]>('SELECT * FROM users WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};
