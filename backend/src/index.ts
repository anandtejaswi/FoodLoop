// ============================================================
// src/index.ts  –  Express App Entry Point
// ============================================================
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';

import authRoutes    from './routes/auth.routes';
import userRoutes    from './routes/user.routes';
import foodRoutes    from './routes/food.routes';
import requestRoutes from './routes/request.routes';
import reviewRoutes  from './routes/review.routes';

// Load environment variables from .env
dotenv.config();

const app  = express();
const PORT = Number(process.env.PORT) || 4000;

// ── Ensure uploads directory exists ──────────────────────────
const uploadDir = process.env.UPLOAD_DIR || './uploads';
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

// ── Global Middleware ─────────────────────────────────────────
app.use(cors({
  origin: '*',   // Restrict to your Flutter app domain in production
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Static files (uploaded photos) ───────────────────────────
app.use('/uploads', express.static(path.resolve(uploadDir)));

// ── Health check ─────────────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ── API Routes ────────────────────────────────────────────────
app.use('/api/auth',     authRoutes);
app.use('/api/users',    userRoutes);
app.use('/api/food',     foodRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/reviews',  reviewRoutes);

// ── 404 Handler ───────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// ── Global Error Handler ──────────────────────────────────────
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('[ERROR]', err.message);
  res.status(err.status || 500).json({ message: err.message || 'Internal server error' });
});

// ── Start Server ──────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`✅  FoodLoop API running at http://localhost:${PORT}`);
  console.log(`📋  Health check: http://localhost:${PORT}/health`);
});

export default app;
