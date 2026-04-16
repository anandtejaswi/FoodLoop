// ============================================================
// src/routes/request.routes.ts
// ============================================================
import { Router } from 'express';
import {
  createRequest,
  getGiverRequests,
  getTakerRequests,
  updateRequestStatus,
} from '../controllers/request.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// All request routes require auth
router.use(authMiddleware);

// POST /api/requests           – taker creates a request
router.post('/',        createRequest);

// GET  /api/requests/giver     – giver sees incoming requests (MUST COME BEFORE /:id)
router.get('/giver',    getGiverRequests);

// GET  /api/requests/taker     – taker sees own requests (MUST COME BEFORE /:id)
router.get('/taker',    getTakerRequests);

// PUT  /api/requests/:id       – accept / reject / complete
router.put('/:id',      updateRequestStatus);

export default router;
