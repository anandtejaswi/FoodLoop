// ============================================================
// src/routes/food.routes.ts
// ============================================================
import { Router, Request, Response, NextFunction } from 'express';
import multer from 'multer';
import path from 'path';
import {
  getFoodItems,
  getMyFoodItems,
  getFoodItem,
  createFoodItem,
  deleteFoodItem,
  updateFoodStatus,
} from '../controllers/food.controller';
import { authMiddleware } from '../middleware/auth.middleware';

// ── Multer – disk storage for food photos ────────────────────
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, process.env.UPLOAD_DIR || './uploads'),
  filename:    (_req, file, cb) => cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${path.extname(file.originalname)}`),
});
const upload = multer({
  storage,
  limits: { fileSize: (Number(process.env.MAX_FILE_SIZE_MB) || 5) * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (/image\/(jpeg|png|webp)/.test(file.mimetype)) cb(null, true);
    else cb(new Error('Only JPEG/PNG/WEBP images allowed'));
  },
});

// ── Middleware: Handle both JSON and multipart file uploads ──
const handleJsonOrMultipart = (req: Request, res: Response, next: NextFunction) => {
  const contentType = req.get('content-type') || '';
  if (contentType.includes('multipart/form-data')) {
    upload.single('photo')(req, res, next);
  } else {
    next();
  }
};

const router = Router();

// GET  /api/food             – list (with geo filter, public)
router.get('/',       getFoodItems);

// GET  /api/food/mine        – giver's own listings (auth) - MUST COME BEFORE /:id
router.get('/mine',   authMiddleware, getMyFoodItems);

// GET  /api/food/:id         – single item (public)
router.get('/:id',    getFoodItem);

// POST /api/food             – create listing (auth + optional photo)
// Handles both JSON (from web) and multipart (from mobile with file)
router.post('/',      authMiddleware, handleJsonOrMultipart, createFoodItem);

// DELETE /api/food/:id       – delete own listing (auth)
router.delete('/:id', authMiddleware, deleteFoodItem);

// PUT /api/food/:id/status   – update status (auth)
router.put('/:id/status', authMiddleware, updateFoodStatus);

export default router;
