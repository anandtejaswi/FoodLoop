// ============================================================
// src/middleware/validation.middleware.ts  –  Input Validation
// ============================================================
import { Request, Response, NextFunction } from 'express';

// ── Regex patterns for validation ──────────────────────────
const EMAIL_REGEX = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
const NAME_REGEX = /^[a-zA-Z\s]{2,50}$/;

// ── Sanitize string input ────────────────────────────────────
const sanitizeInput = (input: string): string => {
  if (typeof input !== 'string') return '';
  
  let sanitized = input.trim();
  // Remove null bytes
  sanitized = sanitized.replace(/\x00/g, '');
  // Remove control characters
  sanitized = sanitized.replace(/[\x00-\x1F\x7F]/g, '');
  
  return sanitized;
};

// ── Check for SQL injection patterns ──────────────────────────
const hasSuspiciousPatterns = (input: string): boolean => {
  const suspiciousPatterns = [
    /('|(OR|AND)\s*'1'='1)/gi,
    /(--|#|\/\*|\*\/)/gi,
    /(UNION|SELECT|INSERT|UPDATE|DELETE|DROP|CREATE)\s/gi,
    /(xp_|sp_|exec|execute)/gi,
  ];

  return suspiciousPatterns.some((pattern) => pattern.test(input));
};

// ── Validate signup input ────────────────────────────────────
export const validateSignUp = (req: Request, res: Response, next: NextFunction): void => {
  const { email, password, name } = req.body;

  // Check required fields
  if (!email || !password || !name) {
    res.status(400).json({ message: 'Email, password, and name are required' });
    return;
  }

  // Sanitize inputs
  const sanitizedEmail = sanitizeInput(email as string);
  const sanitizedName = sanitizeInput(name as string);

  // Validate email format
  if (!EMAIL_REGEX.test(sanitizedEmail)) {
    res.status(400).json({ message: 'Invalid email format' });
    return;
  }

  // Validate name format
  if (!NAME_REGEX.test(sanitizedName)) {
    res.status(400).json({ message: 'Name must be 2-50 characters and contain only letters and spaces' });
    return;
  }

  // Check password length
  if ((password as string).length < 8) {
    res.status(400).json({ message: 'Password must be at least 8 characters long' });
    return;
  }

  // Check for suspicious patterns
  if (hasSuspiciousPatterns(sanitizedEmail) || hasSuspiciousPatterns(sanitizedName)) {
    res.status(400).json({ message: 'Invalid input detected' });
    return;
  }

  // Update request body with sanitized values
  req.body.email = sanitizedEmail;
  req.body.name = sanitizedName;

  next();
};

// ── Validate signin input ────────────────────────────────────
export const validateSignIn = (req: Request, res: Response, next: NextFunction): void => {
  const { email, password } = req.body;

  // Check required fields
  if (!email || !password) {
    res.status(400).json({ message: 'Email and password are required' });
    return;
  }

  // Sanitize email
  const sanitizedEmail = sanitizeInput(email as string);

  // Validate email format
  if (!EMAIL_REGEX.test(sanitizedEmail)) {
    res.status(400).json({ message: 'Invalid email format' });
    return;
  }

  // Check for suspicious patterns
  if (hasSuspiciousPatterns(sanitizedEmail)) {
    res.status(400).json({ message: 'Invalid input detected' });
    return;
  }

  req.body.email = sanitizedEmail;

  next();
};
