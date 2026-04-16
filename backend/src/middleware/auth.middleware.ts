// ============================================================
// src/middleware/auth.middleware.ts  –  JWT Guard
// ============================================================
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface AuthRequest extends Request {
  userId?: number;
  userRole?: string;
}

export const authMiddleware = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    res.status(401).json({ message: 'No token provided' });
    return;
  }
  const token = header.split(' ')[1];
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET || 'secret') as {
      userId: number;
      role: string;
    };
    req.userId   = payload.userId;
    req.userRole = payload.role;
    next();
  } catch {
    res.status(401).json({ message: 'Invalid or expired token' });
  }
};
