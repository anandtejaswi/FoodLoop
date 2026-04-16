// ============================================================
// src/controllers/auth.controller.ts  –  Email/Password + JWT
// ============================================================
import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import pool from '../config/db';
import { AuthRequest } from '../middleware/auth.middleware';

// ── Helper: generate JWT ─────────────────────────────────────
const signToken = (userId: number, role: string): string =>
  jwt.sign(
    { userId, role },
    process.env.JWT_SECRET || 'secret',
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' } as jwt.SignOptions
  );

// ── POST /api/auth/signup  ───────────────────────────────────
// Register new user with email/password
export const signUp = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password, name } = req.body as { email: string; password: string; name: string };
    
    if (!email || !password || !name) {
      res.status(400).json({ message: 'email, password, and name are required' });
      return;
    }

    const conn = await pool.getConnection();
    try {
      // Check if user already exists
      const [existing] = await conn.query<any[]>(
        'SELECT id FROM users WHERE email = ?',
        [email]
      );

      if (existing.length > 0) {
        res.status(409).json({ message: 'Email already registered' });
        return;
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Insert new user
      const [result] = await conn.query<any>(
        'INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)',
        [email, hashedPassword, name, '']
      );

      // Get created user
      const [newUser] = await conn.query<any[]>(
        'SELECT * FROM users WHERE id = ?',
        [result.insertId]
      );

      const user = newUser[0];
      const token = signToken(user.id, user.role);
      res.status(201).json({ token, user: formatUser(user) });
    } finally {
      conn.release();
    }
  } catch (err: any) {
    // Don't expose specific error details to frontend
    console.error('Sign up error:', err);
    res.status(500).json({ message: 'An error occurred during registration. Please try again.' });
  }
};

// ── POST /api/auth/signin  ───────────────────────────────────
// Login with email/password
export const signIn = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body as { email: string; password: string };

    if (!email || !password) {
      res.status(400).json({ message: 'email and password are required' });
      return;
    }

    const conn = await pool.getConnection();
    try {
      // Find user by email
      const [rows] = await conn.query<any[]>(
        'SELECT * FROM users WHERE email = ? LIMIT 1',
        [email]
      );

      if (rows.length === 0) {
        res.status(401).json({ message: 'Invalid email or password' });
        return;
      }

      const user = rows[0];

      // Compare passwords
      const isValid = await bcrypt.compare(password, user.password);
      if (!isValid) {
        res.status(401).json({ message: 'Invalid email or password' });
        return;
      }

      const token = signToken(user.id, user.role);
      res.json({ token, user: formatUser(user) });
    } finally {
      conn.release();
    }
  } catch (err: any) {
    // Don't expose specific error details to frontend
    console.error('Sign in error:', err);
    res.status(500).json({ message: 'An error occurred during login. Please try again.' });
  }
};

// ── GET /api/auth/me  ────────────────────────────────────────
export const getMe = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const [rows] = await pool.query<any[]>('SELECT * FROM users WHERE id = ?', [req.userId]);
    if (!rows.length) { res.status(404).json({ message: 'User not found' }); return; }
    res.json({ user: formatUser(rows[0]) });
  } catch (err: any) {
    res.status(500).json({ message: err.message });
  }
};

// ── POST /api/auth/change-password  ──────────────────────────
// Change user password (requires authentication)
export const changePassword = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { currentPassword, newPassword } = req.body as { currentPassword: string; newPassword: string };

    if (!currentPassword || !newPassword) {
      res.status(400).json({ message: 'currentPassword and newPassword are required' });
      return;
    }

    if (newPassword.length < 8) {
      res.status(400).json({ message: 'New password must be at least 8 characters' });
      return;
    }

    const conn = await pool.getConnection();
    try {
      // Get current user
      const [rows] = await conn.query<any[]>(
        'SELECT * FROM users WHERE id = ?',
        [req.userId]
      );

      if (rows.length === 0) {
        res.status(404).json({ message: 'User not found' });
        return;
      }

      const user = rows[0];

      // Verify current password
      const isValid = await bcrypt.compare(currentPassword, user.password);
      if (!isValid) {
        res.status(401).json({ message: 'Current password is incorrect' });
        return;
      }

      // Hash new password
      const hashedPassword = await bcrypt.hash(newPassword, 10);

      // Update password in database
      await conn.query(
        'UPDATE users SET password = ? WHERE id = ?',
        [hashedPassword, req.userId]
      );

      res.json({ message: 'Password changed successfully' });
    } finally {
      conn.release();
    }
  } catch (err: any) {
    console.error('Change password error:', err);
    res.status(500).json({ message: 'An error occurred while changing password. Please try again.' });
  }
};

// ── Kept for backward compatibility ──────────────────────────
export const googleSignIn = async (req: Request, res: Response): Promise<void> => {
  res.status(501).json({ message: 'Google Sign-In has been deprecated. Please use /signin endpoint.' });
};

// ── Helper: strip sensitive fields ───────────────────────────
const formatUser = (u: any) => ({
  id:           u.id,
  name:         u.name,
  email:        u.email,
  avatar_url:   u.avatar_url,
  role:         u.role,
  points:       u.points,
  rating:       parseFloat(u.rating),
  impact_score: u.impact_score,
  created_at:   u.created_at,
});
