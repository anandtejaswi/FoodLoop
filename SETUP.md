# FoodLoop Project Setup

## Project Structure
The project now has a combined structure with both frontend (Flutter) and backend (Node.js) in one folder:

```
foodloop_app/
├── lib/                    # Flutter app source code
├── backend/                # Node.js + TypeScript backend
├── assets/                 # Images, icons, lottie files
├── RUN_APP.bat            # Quick start script (Windows)
├── RUN_APP.sh             # Quick start script (macOS/Linux)
└── pubspec.yaml           # Flutter dependencies
```

## Prerequisites

1. **Flutter SDK** - Install from https://flutter.dev
2. **Node.js** - Install from https://nodejs.org (v18+)
3. **MySQL** - Database for backend
4. **Dart** - Comes with Flutter

## Quick Start

### Option 1: Automated (Windows)
```bash
cd c:\Documents\ADF_Project\foodloop_app
RUN_APP.bat
```

### Option 2: Automated (macOS/Linux)
```bash
cd ~/Documents/ADF_Project/foodloop_app
chmod +x RUN_APP.sh
./RUN_APP.sh
```

### Option 3: Manual

**Terminal 1 - Backend:**
```bash
cd backend
npm install        # First time only
npm run dev        # Start development server
```

**Terminal 2 - Frontend:**
```bash
flutter pub get    # First time only
flutter run        # Start the app
```

## Changes Made

### Authentication System
- **Removed:** Google OAuth Sign-In (google_sign_in package)
- **Added:** Email/Password authentication
  - New Sign In screen with email & password fields
  - New Sign Up screen with name, email, password, and terms agreement
  
### Backend Integration
- Updated `signIn` and `signUp` API endpoints (replace `googleSignIn` endpoint)
- Email/password credentials now sent to backend
- Backend should implement:
  - POST `/api/auth/signin` - Email/password sign in
  - POST `/api/auth/signup` - Email/password registration

### Asset Fixes
- **Removed:** Font asset references (Poppins fonts) from pubspec.yaml
- The app now uses system fonts as specified in the code

## Backend Requirements

Your backend must implement these authentication endpoints:

### Sign In
```
POST /api/auth/signin
{
  "email": "user@example.com",
  "password": "password123"
}
Response: {
  "user": { id, email, name, role },
  "token": "jwt_token"
}
```

### Sign Up
```
POST /api/auth/signup
{
  "email": "user@example.com",
  "password": "password123",
  "name": "User Name"
}
Response: {
  "user": { id, email, name, role: "" },
  "token": "jwt_token"
}
```

## Environment Setup

### Frontend (Flutter)
- API base URL: `http://10.0.2.2:4000/api` (Android emulator)
  - For physical device/web, update in `lib/services/api_service.dart`

### Backend
Create a `.env` file in the `backend/` folder:
```
PORT=4000
DATABASE_URL=mysql://user:password@localhost:3306/foodloop_db
JWT_SECRET=your_jwt_secret_key
```

## Running on Different Platforms

### Web
```bash
flutter run -d chrome
```

### Android
```bash
flutter run -d emulator-5554
```

### iOS
```bash
flutter run -d iphone
```

## Troubleshooting

### Port Already in Use
If port 4000 is in use, update `backend/.env`:
```
PORT=5000
```
And update API URL in `lib/services/api_service.dart`:
```dart
static const String _baseUrl = 'http://10.0.2.2:5000/api';
```

### Flutter Dependencies
```bash
flutter clean
flutter pub get
```

### Backend Dependencies
```bash
cd backend
npm install
npm run build
```

## Support
For issues, check the console logs in both backend and Flutter terminals.
