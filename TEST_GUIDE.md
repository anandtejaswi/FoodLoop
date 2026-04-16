# FoodLoop Testing Guide

## Current Status ✅

### Backend
- ✅ Server running on `http://localhost:4000`
- ✅ Database configured (MySQL - foodloop_db)
- ✅ Authentication endpoints implemented:
  - `POST /api/auth/signup` - Register with email/password
  - `POST /api/auth/signin` - Login with email/password
  - `GET /api/auth/me` - Get current user

### Frontend
- ✅ Flutter app updated to use `http://localhost:4000/api`
- ✅ Sign Up page with email/password/name fields
- ✅ Sign In page with email/password fields

## How to Test

### 1. Start Backend
```bash
cd c:\Documents\ADF_Project\foodloop_app\backend
npm run dev
```
Should see: `✅  FoodLoop API running at http://localhost:4000`

### 2. Start Frontend
```bash
cd c:\Documents\ADF_Project\foodloop_app
flutter run -d chrome
```

### 3. Test Sign Up
1. Open Chrome (should auto-launch with Flutter)
2. Click "Don't have an account? Sign Up"
3. Fill in:
   - Full Name: `Test User`
   - Email: `test@example.com`
   - Password: `password123`
   - Confirm Password: `password123`
   - Check Terms & Conditions
4. Click "Create Account"
5. Should redirect to role selection screen

### 4. Test Sign In
1. On the Sign In page, enter:
   - Email: `test@example.com`
   - Password: `password123`
2. Click "Sign In"
3. Should redirect to role selection screen

## Troubleshooting

### "Failed to fetch" error
- Make sure backend is running: `npm run dev`
- Check that it shows `✅  FoodLoop API running at http://localhost:4000`

### "Invalid email or password"
- Verify user was created in database
- Check MySQL: `SELECT * FROM foodloop_db.users;`

### Database connection errors
- Verify MySQL is running
- Check `.env` file has correct credentials:
  - DB_HOST=localhost
  - DB_PORT=3306
  - DB_USER=root
  - DB_PASSWORD=shambhavi
  - DB_NAME=foodloop_db

## Key Files

- Backend: `c:\Documents\ADF_Project\foodloop_app\backend\`
- Frontend: `c:\Documents\ADF_Project\foodloop_app\lib\`
- Database schema: `c:\Documents\ADF_Project\foodloop_app\backend\src\db.schema.sql`
