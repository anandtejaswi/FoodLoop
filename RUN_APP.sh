#!/bin/bash
echo "========================================"
echo "FoodLoop - Backend and Frontend Runner"
echo "========================================"
echo ""
echo "Starting backend server..."
echo ""
(cd backend && npm run dev) &
BACKEND_PID=$!
echo ""
echo "Waiting for backend to start..."
sleep 3
echo ""
echo "Starting Flutter app..."
echo ""
flutter run
echo ""
kill $BACKEND_PID 2>/dev/null
