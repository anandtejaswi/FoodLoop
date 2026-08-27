# 🍱 FoodLoop

**Smart Food Waste Management System** — connecting people with surplus food (**Givers**) to people or NGOs who need it (**Takers**), one pickup at a time.

FoodLoop is a cross-platform Flutter app backed by a Node.js/TypeScript API. Givers post leftover or surplus food with a pickup location and expiry window; Takers browse a live map, request what they need, coordinate pickup, and rate the exchange. No money changes hands — the goal is less food in landfills and stronger local communities.

```
Giver posts leftover food → Taker sees it on the map → Taker requests it → Giver accepts → Food is collected
```

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Database Setup](#database-setup)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
  - [Quick Start Scripts](#quick-start-scripts)
- [Configuring the API URL](#configuring-the-api-url)
- [Running on Different Platforms](#running-on-different-platforms)
- [API Reference](#api-reference)
- [Database Schema](#database-schema)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Documentation](#documentation)
- [Roadmap](#roadmap)
- [Contributing](#contributing)

---

## Features

**For Givers 🍱**
- Post a food listing with photo, category, quantity, pickup location, and expiry time
- One-tap GPS pickup-location tagging (reverse geocoded via OpenStreetMap)
- Dashboard with active/completed listing stats and average rating
- Accept or reject incoming pickup requests
- Earn points, an impact score (kg of food saved), and badges

**For Takers / NGOs 🤝**
- Interactive OpenStreetMap view of nearby available food (10 km radius)
- Filterable list view with search and category chips (Meals, Produce, Bakery, Dairy, Other)
- Request food with one tap and track request status (pending / accepted / rejected)
- In-app chat to coordinate pickup once a request is accepted
- Leave a rating and review after pickup

**Platform**
- Single Flutter codebase targeting Android, iOS, Web, Windows, macOS, and Linux
- Email/password authentication with JWT sessions
- Role-based navigation (Giver vs Taker), switchable anytime from the profile screen

## Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | [Flutter](https://flutter.dev) (Dart) | Cross-platform UI (mobile, web, desktop) |
| Navigation | `go_router` | Declarative routing |
| State Management | `provider` | Auth/session state |
| HTTP | `http`, `dio` | REST API calls |
| Maps | `flutter_map` + OpenStreetMap | Interactive map for Takers |
| Location | `geolocator`, `geocoding` | GPS + reverse geocoding |
| Local Storage | `shared_preferences`, `flutter_secure_storage` | JWT token persistence |
| Media | `image_picker`, `cached_network_image` | Food photos |
| Backend | Node.js + TypeScript + Express | REST API |
| Database | MySQL | Persistent storage |
| Auth | JWT (JSON Web Tokens) | Session management |
| Deployment | Railway | Hosted backend |

## Architecture

```
┌───────────────────────────────────────────────────────┐
│                      FoodLoop App                      │
│                                                         │
│   Flutter (Dart) Frontend   ←── HTTP/REST ──→  Node.js  │
│   (Android / iOS / Web /              Backend (TS)     │
│    Windows / macOS / Linux)                │           │
│                                          MySQL DB       │
└───────────────────────────────────────────────────────┘
```

The frontend never talks to the database directly — every read/write goes through the Express REST API.

## Project Structure

```
FoodLoop/
├── lib/                        # Flutter (Dart) source
│   ├── main.dart               # App entry point
│   ├── config/                 # Routes & theme
│   ├── models/                 # User, FoodItem, Request models
│   ├── screens/
│   │   ├── auth/                # Sign In / Sign Up
│   │   ├── onboarding/          # Role selection
│   │   ├── giver/                # Dashboard, Post Food, Requests
│   │   ├── taker/                # Map dashboard, Browse, Detail, Requests
│   │   └── shared/               # Chat, Profile, Settings, Review
│   ├── services/                # api_service, auth_service, location_service
│   ├── utils/                   # Input validation / security helpers
│   └── widgets/                 # Reusable UI components
│
├── backend/                    # Node.js + TypeScript API
│   └── src/
│       ├── index.ts             # Server entry point
│       ├── db.schema.sql        # MySQL schema
│       ├── config/               # DB & env config
│       ├── controllers/          # Route business logic
│       ├── middleware/           # JWT auth middleware
│       └── routes/               # auth, food, requests, reviews
│
├── android/ ios/ web/ windows/ macos/ linux/   # Flutter platform shells
├── test/                       # Flutter tests
├── assets/                     # Images, icons, Lottie animations
├── pubspec.yaml                 # Flutter dependencies
├── SETUP.md                     # Technical setup guide
├── user_manual.md               # Full screen-by-screen user manual
├── CHANGES.md                    # Developer changelog
├── RUN_APP.sh / RUN_APP.bat      # One-command startup scripts
```

## Getting Started

### Prerequisites

| Tool | Version | Link |
|---|---|---|
| Flutter SDK | 3.x+ (Dart SDK `>=3.0.0 <4.0.0`) | https://flutter.dev |
| Node.js | v18+ | https://nodejs.org |
| MySQL | 8.x | https://dev.mysql.com/downloads |
| Git | any | https://git-scm.com |

### Database Setup

```bash
mysql -u root -p < backend/src/db.schema.sql
```

This creates the `foodloop_db` database with five tables: `users`, `food_items`, `requests`, `reviews`, and `messages`.

### Backend Setup

```bash
cd backend
cp .env.example .env   # then fill in the values below
npm install
npm run dev
```

`backend/.env`:
```env
PORT=4000
DATABASE_URL=mysql://user:password@localhost:3306/foodloop_db
JWT_SECRET=your_jwt_secret_key
```

> ⚠️ Never commit your `.env` file — it contains secrets.

### Frontend Setup

```bash
flutter pub get
flutter run
```

### Quick Start Scripts

To boot the backend and Flutter app together:

```bash
# macOS / Linux
chmod +x RUN_APP.sh
./RUN_APP.sh

# Windows
RUN_APP.bat
```

## Configuring the API URL

The frontend points at the backend URL defined in `lib/services/api_service.dart`. Update it for your environment:

| Platform | URL |
|---|---|
| Production | `https://foodloop-production-9c9e.up.railway.app/api` |
| Android Emulator | `http://10.0.2.2:4000/api` |
| iOS Simulator | `http://localhost:4000/api` |
| Physical Device | `http://<your-machine-ip>:4000/api` |
| Web (Chrome) | `http://localhost:4000/api` |

## Running on Different Platforms

```bash
flutter run -d chrome           # Web
flutter run -d emulator-5554    # Android Emulator
flutter run -d iphone           # iOS Simulator
```

## API Reference

All backend routes are prefixed with `/api`.

**Auth**
| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/signup` | Create account |
| POST | `/auth/signin` | Log in, returns user + JWT |
| GET | `/auth/me` | Get current authenticated user |
| POST | `/auth/change-password` | Update password |

**Food**
| Method | Endpoint | Description |
|---|---|---|
| GET | `/food` | List available food (filter by `lat`, `lng`, `radius`, `status`, `category`) |
| GET | `/food/mine` | Giver's own listings |
| GET | `/food/:id` | Single listing detail |
| POST | `/food` | Create a listing (multipart if a photo is included) |
| PUT | `/food/:id/status` | Update listing status |
| DELETE | `/food/:id` | Delete a listing |

**Requests**
| Method | Endpoint | Description |
|---|---|---|
| POST | `/requests` | Taker requests a food item |
| GET | `/requests/giver` | Requests received by a Giver |
| GET | `/requests/taker` | Requests made by a Taker |
| PUT | `/requests/:id` | Accept or reject a request |

**Reviews**
| Method | Endpoint | Description |
|---|---|---|
| POST | `/reviews` | Submit a rating + comment |
| GET | `/reviews/user/:giverId` | Get all reviews for a Giver |

Full request/response bodies are documented in [`user_manual.md`](./user_manual.md#10-backend-api-reference).

## Database Schema

MySQL, 5 tables:

```
users ──< food_items (giver_id)
users ──< requests   (taker_id)
food_items ──< requests (food_id)
requests ──< reviews  (request_id)
requests ──< messages (request_id)
```

- **users** — profile, role (`giver`/`taker`), points, rating, impact score
- **food_items** — listing details, location, category, status, expiry
- **requests** — a Taker's claim on a listing, with status
- **reviews** — post-pickup rating and comment
- **messages** — chat schema in place for the upcoming real-time chat feature

## Security

- JWT-based authentication on all protected routes
- Login rate limiting: 5 failed attempts locks sign-in for 15 minutes
- Input sanitization guarding against SQL injection and XSS patterns
- Minimum 8-character passwords, stored hashed (never plaintext)
- JWT stored in secure local storage, persisting sessions across restarts

## Troubleshooting

| Issue | Fix |
|---|---|
| `SocketException: Connection refused` | Start the backend (`npm run dev`) and confirm the API URL in `lib/services/api_service.dart` matches your platform |
| `Token expired` / `Unauthorized` | Sign out and sign back in |
| `Port Already in Use` | Change `PORT` in `backend/.env` and update the API URL accordingly |
| `flutter pub get` fails | `flutter clean && flutter pub get` |
| Backend can't connect to DB | Ensure MySQL is running and `DATABASE_URL` in `backend/.env` is correct |
| No location on Android Emulator | Set a manual location via Android Studio → Extended Controls → Location |

More scenarios are covered in [`user_manual.md`](./user_manual.md#13-common-errors--troubleshooting).

## Documentation

- [`SETUP.md`](./SETUP.md) — condensed technical setup guide
- [`user_manual.md`](./user_manual.md) — full screen-by-screen walkthrough, data models, API reference, and glossary
- [`CHANGES.md`](./CHANGES.md) — developer changelog

## Roadmap

- [ ] Real-time chat backed by the `messages` table (UI and schema are ready; currently demo data)
- [ ] Persist and edit user profile name updates end-to-end
- [ ] 10-day streak badge logic
- [ ] Push notifications for new requests and accepted pickups

## Contributing

Issues and pull requests are welcome. Please open an issue describing the change before submitting a large PR, and keep new endpoints/screens documented in `user_manual.md`.
