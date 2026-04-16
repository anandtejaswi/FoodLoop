@echo off
echo ========================================
echo FoodLoop - Backend and Frontend Runner
echo ========================================
echo.
echo Starting backend server...
echo.
start "FoodLoop Backend" cmd /k "cd backend && npm run dev"
echo.
echo Waiting for backend to start...
timeout /t 3 /nobreak
echo.
echo Starting Flutter app...
echo.
flutter run
echo.
pause
