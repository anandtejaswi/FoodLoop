// ============================================================
// src/middleware/rateLimit.middleware.ts  –  Rate Limiting
// ============================================================
import { Request, Response, NextFunction } from 'express';

interface RateLimitEntry {
  attempts: number;
  firstAttempt: number;
  lockedUntil?: number;
}

const rateLimitStore = new Map<string, RateLimitEntry>();

const RATE_LIMIT_WINDOW = 15 * 60 * 1000; // 15 minutes
const MAX_ATTEMPTS = 5;
const LOCKOUT_DURATION = 15 * 60 * 1000; // 15 minutes

// ── Clean up old entries periodically ──────────────────────
setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of rateLimitStore.entries()) {
    if (now - entry.firstAttempt > RATE_LIMIT_WINDOW) {
      rateLimitStore.delete(key);
    }
  }
}, 60 * 1000); // Clean up every minute

export const rateLimitMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  const identifier = req.body?.email || req.ip || 'unknown';
  const now = Date.now();

  let entry = rateLimitStore.get(identifier);

  if (!entry) {
    entry = { attempts: 0, firstAttempt: now };
    rateLimitStore.set(identifier, entry);
  }

  // Check if locked out
  if (entry.lockedUntil && now < entry.lockedUntil) {
    res.status(429).json({
      message: 'Too many login attempts. Please try again later.',
      retryAfter: Math.ceil((entry.lockedUntil - now) / 1000),
    });
    return;
  }

  // Reset if window has passed
  if (now - entry.firstAttempt > RATE_LIMIT_WINDOW) {
    entry = { attempts: 1, firstAttempt: now };
    rateLimitStore.set(identifier, entry);
    next();
    return;
  }

  // Increment attempts
  entry.attempts++;

  // Lock if max attempts exceeded
  if (entry.attempts > MAX_ATTEMPTS) {
    entry.lockedUntil = now + LOCKOUT_DURATION;
    res.status(429).json({
      message: 'Too many login attempts. Please try again in 15 minutes.',
      retryAfter: LOCKOUT_DURATION / 1000,
    });
    return;
  }

  next();
};

// ── Middleware to reset rate limit on successful login ─────
export const resetRateLimit = (req: Request, _res: Response, next: NextFunction): void => {
  const identifier = req.body?.email || req.ip || 'unknown';
  rateLimitStore.delete(identifier);
  next();
};
