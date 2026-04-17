# 📖 FoodLoop – Complete User Manual

> **Audience:** Beginners, first-time contributors, and anyone who wants a thorough walkthrough of the FoodLoop project.
> **Last updated:** April 2026

---

## Table of Contents

1. [What is FoodLoop?](#1-what-is-foodloop)
2. [How the App Works – Big Picture](#2-how-the-app-works--big-picture)
3. [Project Structure](#3-project-structure)
4. [Technology Stack](#4-technology-stack)
5. [Environment Setup (First-Time)](#5-environment-setup-first-time)
6. [Running the App](#6-running-the-app)
7. [Screen-by-Screen Walkthrough](#7-screen-by-screen-walkthrough)
   - [7.1 Splash Screen](#71-splash-screen)
   - [7.2 Sign In Screen](#72-sign-in-screen)
   - [7.3 Sign Up Screen](#73-sign-up-screen)
   - [7.4 Role Selection Screen](#74-role-selection-screen)
   - [7.5 Giver Dashboard](#75-giver-dashboard)
   - [7.6 Post Food Screen](#76-post-food-screen)
   - [7.7 Giver Requests Screen](#77-giver-requests-screen)
   - [7.8 Taker Dashboard (Map View)](#78-taker-dashboard-map-view)
   - [7.9 Browse Food Screen](#79-browse-food-screen)
   - [7.10 Food Detail Screen](#710-food-detail-screen)
   - [7.11 Taker Requests Screen](#711-taker-requests-screen)
   - [7.12 Chat Screen](#712-chat-screen)
   - [7.13 Profile Screen](#713-profile-screen)
   - [7.14 Settings Screen](#714-settings-screen)
   - [7.15 Review Screen](#715-review-screen)
8. [Data Models Explained](#8-data-models-explained)
9. [Services Explained](#9-services-explained)
10. [Backend API Reference](#10-backend-api-reference)
11. [Database Schema](#11-database-schema)
12. [Security Features](#12-security-features)
13. [Common Errors & Troubleshooting](#13-common-errors--troubleshooting)
14. [Glossary](#14-glossary)

---

## 1. What is FoodLoop?

**FoodLoop** is a mobile application that connects people who have **surplus food** (called *Givers*) with people or organisations that need it (called *Takers* or NGOs). The goal is to reduce food waste and build a community that shares resources.

### Core Idea

```
Giver posts leftover food  →  Taker sees it on map  →  Taker requests it  →  Giver accepts  →  Food is collected
```

Think of it like a "marketplace", but everything is **free** and the currency is **kindness**.

### Key Values
- 🌱 **Reduce food waste** – food that would be thrown away gets a second life.
- 🤝 **Community building** – neighbours help neighbours.
- 📊 **Impact tracking** – users earn points and badges for contributions.

---

## 2. How the App Works – Big Picture

```
┌─────────────────────────────────────────────────────┐
│                   FoodLoop App                      │
│                                                     │
│   Flutter (Dart) Frontend  ←─HTTP─→  Node.js Backend│
│         (Mobile / Web)                (TypeScript)  │
│                                            │        │
│                                         MySQL DB    │
└─────────────────────────────────────────────────────┘
```

1. **Frontend** – A Flutter app written in Dart. It runs on Android, iOS, and Web.
2. **Backend** – A Node.js + TypeScript server that exposes a REST API.
3. **Database** – A MySQL database that stores users, food listings, requests, reviews, and messages.

The frontend never talks directly to the database. It always goes through the backend API.

---

## 3. Project Structure

```
foodloop_app/
│
├── lib/                        # All Flutter (Dart) source code
│   ├── main.dart               # App entry point
│   ├── config/
│   │   ├── app_routes.dart     # All navigation routes defined here
│   │   └── app_theme.dart      # Colours, fonts, and shared styles
│   ├── models/
│   │   ├── user_model.dart     # User data structure
│   │   ├── food_item_model.dart# Food listing data structure
│   │   └── request_model.dart  # Food request data structure
│   ├── screens/
│   │   ├── auth/               # Sign In & Sign Up screens
│   │   ├── onboarding/         # Role Selection screen
│   │   ├── giver/              # Giver Dashboard, Post Food, Giver Requests
│   │   ├── taker/              # Taker Dashboard (map), Food List, Food Detail, Taker Requests
│   │   └── shared/             # Chat, Profile, Settings, Review (used by both roles)
│   ├── services/
│   │   ├── api_service.dart    # All HTTP calls to the backend
│   │   ├── auth_service.dart   # Login state, token storage, rate-limiting
│   │   └── location_service.dart # GPS & reverse-geocoding (OpenStreetMap)
│   ├── utils/
│   │   └── security_utils.dart # Input validation helpers
│   └── widgets/
│       ├── food_card.dart      # Reusable food listing card widget
│       ├── loading_shimmer.dart# Skeleton loading animation
│       └── reviews_bottom_sheet.dart # Review popup sheet
│
├── backend/                    # Node.js TypeScript backend
│   ├── src/
│   │   ├── index.ts            # Server entry point
│   │   ├── db.schema.sql       # MySQL table definitions
│   │   ├── config/             # Database & environment configs
│   │   ├── controllers/        # Business logic for each route
│   │   ├── middleware/         # Auth middleware (JWT verification)
│   │   └── routes/             # Route definitions (auth, food, requests, reviews)
│   ├── uploads/                # Uploaded food photos stored here
│   ├── .env                    # Secret configuration (do NOT commit to git)
│   └── package.json            # Node.js dependencies
│
├── assets/                     # Images, icons, Lottie animations
├── pubspec.yaml                # Flutter dependencies
├── SETUP.md                    # Technical setup guide
├── CHANGES.md                  # Developer changelog
├── RUN_APP.sh                  # One-command startup (macOS/Linux)
└── RUN_APP.bat                 # One-command startup (Windows)
```

---

## 4. Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| Mobile/Web Frontend | Flutter (Dart) | Cross-platform UI |
| Navigation | `go_router` | Declarative routing between screens |
| State Management | `provider` | Sharing auth state across widgets |
| HTTP Client | `http` package | Calling the backend REST API |
| Maps | `flutter_map` + OpenStreetMap | Interactive map for Taker |
| Location | `geolocator` | Getting GPS coordinates |
| Image Picking | `image_picker` | Letting users choose food photos |
| Local Storage | `shared_preferences` | Saving JWT token locally |
| Backend | Node.js + TypeScript + Express | REST API server |
| Database | MySQL | Persistent data storage |
| Auth | JWT (JSON Web Tokens) | Secure session management |
| Deployment | Railway (cloud) | Backend hosted online |

---

## 5. Environment Setup (First-Time)

### Prerequisites – What You Need Installed

| Tool | Version | Where to Get It |
|---|---|---|
| Flutter SDK | 3.x or later | https://flutter.dev |
| Dart | Comes with Flutter | (included) |
| Node.js | v18 or later | https://nodejs.org |
| MySQL | 8.x | https://dev.mysql.com/downloads/ |
| Git | Any | https://git-scm.com |

### Step 1 – Clone the Project

```bash
git clone <your-repository-url>
cd foodloop_app
```

### Step 2 – Set Up the Database

1. Open a MySQL terminal:
   ```bash
   mysql -u root -p
   ```
2. Run the schema file to create all tables:
   ```bash
   mysql -u root -p < backend/src/db.schema.sql
   ```
   This creates the `foodloop_db` database with five tables: `users`, `food_items`, `requests`, `reviews`, and `messages`.

### Step 3 – Configure the Backend

1. Go to the backend folder:
   ```bash
   cd backend
   ```
2. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
3. Open `.env` and fill in your details:
   ```env
   PORT=4000
   DATABASE_URL=mysql://root:yourpassword@localhost:3306/foodloop_db
   JWT_SECRET=some_long_random_secret_string
   ```
   > ⚠️ **Never share your `.env` file or commit it to Git.** It contains secrets.

### Step 4 – Install Backend Dependencies

```bash
cd backend
npm install
```

### Step 5 – Install Flutter Dependencies

```bash
# Go back to the root folder
cd ..
flutter pub get
```

### Step 6 – Configure the API URL (for Local Development)

Open `lib/services/api_service.dart` and find this line:

```dart
static const String _baseUrl = 'https://foodloop-production-9c9e.up.railway.app/api';
```

If you're running the backend **locally**, change it to:

| Platform | URL to Use |
|---|---|
| Android Emulator | `http://10.0.2.2:4000/api` |
| iOS Simulator | `http://localhost:4000/api` |
| Physical Device | `http://192.168.x.x:4000/api` (your machine's IP) |
| Web (Chrome) | `http://localhost:4000/api` |

---

## 6. Running the App

### Option A – Automated (Recommended)

**macOS / Linux:**
```bash
chmod +x RUN_APP.sh
./RUN_APP.sh
```

**Windows:**
```cmd
RUN_APP.bat
```
These scripts start the backend and Flutter app at the same time.

---

### Option B – Manual (Two Terminals)

**Terminal 1 – Start the Backend:**
```bash
cd backend
npm run dev
```
You should see something like:
```
Server running on port 4000
Database connected ✓
```

**Terminal 2 – Start the Flutter App:**
```bash
flutter run
```
Choose a device when prompted (emulator, physical phone, or web browser).

---

### Running on a Specific Platform

```bash
flutter run -d chrome           # Web (Google Chrome)
flutter run -d emulator-5554    # Android Emulator
flutter run -d iphone           # iOS Simulator
```

---

## 7. Screen-by-Screen Walkthrough

This section explains every screen in the app: what it does, what the user sees, and what happens behind the scenes.

---

### 7.1 Splash Screen

**File:** `lib/screens/splash/`

**What the user sees:** The FoodLoop logo and a loading indicator while the app checks if the user is already logged in.

**What happens behind the scenes:**
- The app reads any saved JWT token from local storage (`SharedPreferences`).
- If a token exists and is valid → the user is taken directly to their dashboard (skipping login).
- If no token → the user is taken to the Sign In screen.

---

### 7.2 Sign In Screen

**File:** `lib/screens/auth/sign_in_screen.dart`

**What the user sees:**
- A "Welcome to FoodLoop" heading
- Email input field (with live validation)
- Password input field (with show/hide toggle)
- "Sign In" button
- "Don't have an account? Sign Up" link

**How to use it:**
1. Type your registered email address.
2. Type your password (tap the eye icon to reveal it).
3. Tap **Sign In**.

**What happens behind the scenes:**
1. The app validates the email format before sending anything.
2. It checks if you've failed too many times recently (rate limiting – see [Security Features](#12-security-features)).
3. It calls `POST /api/auth/signin` on the backend.
4. If successful, the JWT token and user data are saved locally.
5. Based on your saved **role** (`giver` or `taker`), you are routed to the appropriate dashboard. If you have no role yet, you go to [Role Selection](#74-role-selection-screen).

**Common errors:**
- `"Email is required"` – nothing typed in the email field.
- `"Invalid email format"` – the text doesn't look like an email.
- `"Too many failed attempts"` – you've entered the wrong password multiple times. Wait a few minutes.

---

### 7.3 Sign Up Screen

**File:** `lib/screens/auth/sign_up_screen.dart`

**What the user sees:**
- Full Name field
- Email field (validated in real time)
- Password field (with strength requirements)
- Confirm Password field
- Terms & Conditions checkbox
- "Create Account" button
- "Already have an account? Sign In" link

**How to use it:**
1. Enter your full name (e.g. `Priya Sharma`).
2. Enter a valid email address.
3. Choose a password of **at least 8 characters**.
4. Re-enter the same password to confirm.
5. Check the Terms & Conditions box.
6. Tap **Create Account**.

**What happens behind the scenes:**
1. All fields are validated locally first (no server calls until everything passes).
2. The app calls `POST /api/auth/signup` on the backend.
3. The backend creates a new user with role set to `""` (empty – no role chosen yet).
4. You receive a JWT token and are sent to [Role Selection](#74-role-selection-screen).

**Password Rules (enforced on the screen):**
- Minimum 8 characters
- Both password fields must match

---

### 7.4 Role Selection Screen

**File:** `lib/screens/onboarding/role_selection_screen.dart`

**What the user sees:**
- "Choose Your Role" heading
- Two animated cards: **Giver 🍱** and **Taker / NGO 🤝**
- A "Continue" button that becomes active once a card is selected

**What is a Giver?**
A person or business with surplus food they want to share. Givers can:
- Post food listings
- Track how much they've shared
- Earn points & impact badges

**What is a Taker?**
A person, family, or NGO looking for free food. Takers can:
- Browse food on an interactive map
- Request & claim food
- Rate their experience

**How to use it:**
1. Tap one of the cards (it will animate with a coloured border and a checkmark ✓).
2. Tap **Continue as Giver** or **Continue as Taker**.

**What happens behind the scenes:**
- The app calls `PUT /api/users/:userId` to save your chosen role in the database.
- You are then navigated to the correct dashboard.
- You can always change your role later from your **Profile** screen.

---

### 7.5 Giver Dashboard

**File:** `lib/screens/giver/giver_dashboard_screen.dart`

**What the user sees:**
- A greeting banner: "Hello, [Name]!"
- Three stat cards: **Active Listings** | **Completed** | **Avg Rating**
- Toggle chips: **Live** / **Past** listings
- A list of your current food listings (cards)
- A "Post Food" floating button (bottom-right)
- A notification bell (top-right) with a red badge showing pending requests

**How to use it:**
- **Pull down** anywhere on the list to refresh data.
- Tap **Live** to see food you have currently available.
- Tap **Past** to see food listings that are completed or expired.
- Tap any listing card to see its full details (and optionally delete it).
- Tap the 🔔 **notification bell** to go to the Requests screen.
- Tap **Post Food** (green button) to create a new food listing.
- Tap your **Avg Rating** stat card to see your reviews.

**What happens behind the scenes:**
- The dashboard auto-refreshes every **5 seconds** in the background.
- It also refreshes whenever you bring the app back from the background (app lifecycle event).
- It fetches your listings from `GET /api/food/mine` and your pending requests from `GET /api/requests/giver`.

---

### 7.6 Post Food Screen

**File:** `lib/screens/giver/post_food_screen.dart`

**What the user sees:** A scrollable form with the following fields.

| Field | Required? | Notes |
|---|---|---|
| Food Photo | ❌ Optional | Tap the photo box to pick from gallery |
| Food Title | ✅ Yes | e.g. "Leftover Dal & Rice" |
| Category | ✅ Yes | Meals 🍱 / Produce 🥦 / Bakery 🍞 / Dairy 🥛 / Other 🍴 |
| Quantity | ✅ Yes | A number (e.g. 5) |
| Unit | ✅ Yes | Portions / kg / litres / boxes / bags / pieces |
| Description | ❌ Optional | Allergens, pickup instructions, etc. |
| Pickup Location | ✅ Yes | Type an address OR tap the GPS button 📍 |
| Available Until | ✅ Yes | Tap to open date & time picker |
| Phone Number | ✅ Yes | So takers can contact you for pickup |

**How to use it:**
1. (Optional) Tap the photo area to add a food photo from your gallery.
2. Fill in all required fields (marked with *).
3. For location, tap the blue GPS button to automatically fill your current address.
4. Tap the expiry field to choose the date and time when the food will no longer be available.
5. Tap **Post Food Listing**.

**What happens behind the scenes:**
- If you picked a photo, it's sent as a multipart form upload.
- If no photo, it's sent as a simple JSON body.
- The API endpoint is `POST /api/food`.
- The GPS button calls `LocationService` which uses `geolocator` to get coordinates, then calls OpenStreetMap's Nominatim API for the human-readable address.
- On success, you are taken back to the Giver Dashboard and see a "Food posted successfully! 🎉" toast.

---

### 7.7 Giver Requests Screen

**File:** `lib/screens/giver/giver_requests_screen.dart`

**What the user sees:**
- A list of all requests that takers have made for your food listings
- Each request card shows: taker's name, food title, request status (`pending` / `accepted` / `rejected`), and the time of request

**How to use it:**
- Tap **Accept** on a request to approve the taker.
- Tap **Reject** to decline.
- Accepted requests change the food status to `claimed`.

**What happens behind the scenes:**
- Fetches from `GET /api/requests/giver`.
- Accepting calls `PUT /api/requests/:id` with `{ "status": "accepted" }`.
- Rejecting calls `PUT /api/requests/:id` with `{ "status": "rejected" }`.

---

### 7.8 Taker Dashboard (Map View)

**File:** `lib/screens/taker/taker_dashboard_screen.dart`

**What the user sees:**
- A full-screen **OpenStreetMap** map centred on your current location.
- A **blue dot** showing where you are.
- **Coloured circle pins** on the map — each pin is an available food item. The emoji inside the pin represents the food category (🍱🥦🍞🥛🍴).
- When you tap a pin, a **preview card** pops up at the bottom showing the food title, address, time remaining, and quantity.
- A **"my location" button** (bottom-right) to re-centre the map.
- A **filter icon** (top-right) to switch to the list view.

**How to use it:**
1. Allow location permission when asked.
2. The map will centre on your location and show nearby food pins within a **10 km radius**.
3. Tap any pin to see a quick preview.
4. Tap the **→ arrow** on the preview card to go to the full [Food Detail Screen](#710-food-detail-screen).
5. Tap anywhere on the map (not on a pin) to close the preview card.
6. Tap the filter icon or the location button in the top-right to switch to the list/browse view.

**What happens behind the scenes:**
- On open, calls `LocationService.getCurrentPosition()` to get GPS coordinates.
- Calls `GET /api/food?lat=X&lng=Y&radius=10&status=available` to fetch nearby food.
- `flutter_map` renders OpenStreetMap tiles from `https://tile.openstreetmap.org/{z}/{x}/{y}.png`.
- Selected pin is highlighted with a larger, primary-coloured circle.

---

### 7.9 Browse Food Screen

**File:** `lib/screens/taker/food_list_screen.dart`

**What the user sees:**
- A **search bar** at the top
- A horizontal row of **category filter chips**: All / Meals / Produce / Bakery / Dairy / Other
- A count showing how many items matched (e.g. "12 items found")
- A scrollable list of **food cards** with photo, title, giver name, distance, and time remaining

**How to use it:**
1. Type in the search bar to filter by food title, description, or giver name.
2. Tap a category chip to filter by type (e.g. only Bakery items).
3. Tap any food card to see full details.
4. Pull down to refresh the list.

**What happens behind the scenes:**
- On load, fetches all available food from `GET /api/food?status=available`.
- Search and category filtering happen **locally** (no extra API calls) – the app filters the already-loaded list in memory.
- Tapping a card navigates to `Food Detail Screen` with `?id=<food_id>` in the URL.

---

### 7.10 Food Detail Screen

**File:** `lib/screens/taker/food_detail_screen.dart`

**What the user sees:**
- A **collapsible hero image** at the top (the food photo or a category emoji if no photo)
- Food title and time remaining chip
- Category and quantity tags
- Giver's name and avatar card
- Description text
- Details: Pickup Location, Available Until, Category, Serves
- A big **"Request This Food"** button at the bottom

**How to use it:**
1. Review all the details.
2. If the food looks right, tap **Request This Food**.
3. You'll see a confirmation toast and be taken to your Requests screen.

**Button states:**
- **"Request This Food"** – normal state, food is available.
- **"Expired"** – the food's expiry time has passed; button is disabled.
- **"Already Claimed"** – someone else already claimed it; button is disabled.
- **"Requesting…"** – the request is being sent (loading state).

**What happens behind the scenes:**
- Loads via `GET /api/food/:id`.
- Tapping the button calls `POST /api/requests` with `{ "food_id": <id> }`.
- On success, navigates to the Taker Requests screen.

---

### 7.11 Taker Requests Screen

**File:** `lib/screens/taker/taker_requests_screen.dart`

**What the user sees:**
- A list of all the food requests you (as a Taker) have made
- Each card shows: food title, giver name, request status, and time
- Status can be: **Pending** ⏳ / **Accepted** ✅ / **Rejected** ❌

**How to use it:**
- If a request is **Accepted**, you can tap it to open the **Chat** screen and coordinate pickup details with the Giver.
- If a request is **Pending**, wait for the Giver to respond.
- **Pull down** to refresh.

**What happens behind the scenes:**
- Fetches from `GET /api/requests/taker`.

---

### 7.12 Chat Screen

**File:** `lib/screens/shared/chat_screen.dart`

**What the user sees:**
- A chat interface (like WhatsApp) showing a conversation between you and the other person
- Messages you sent appear on the **right** in a coloured bubble
- Messages you received appear on the **left** in a white bubble
- A timestamp is shown under each message
- A text input bar at the bottom with an attachment icon and a send button

**How to use it:**
1. Type your message in the text field.
2. Tap the **send button** (blue circle) or press Enter.
3. The message instantly appears in your bubble at the bottom.

> **Note:** The current chat implementation shows sample/demo messages. Full real-time backend chat via the `messages` table is a feature under development. The UI and message model are ready.

**What happens behind the scenes:**
- Messages are stored in a local list during the session.
- The `ScrollController` automatically scrolls to the newest message after sending.
- The database `messages` table is ready to store real messages linked to `request_id` and `sender_id`.

---

### 7.13 Profile Screen

**File:** `lib/screens/shared/profile_screen.dart`

**What the user sees:**
- A **collapsible profile header** with your avatar, name, and role badge (🍱 Giver or 🤝 Taker)
- **Stats card** showing: Food Saved (kg) | Points | Rating
- **Impact Progress bar** – shows progress towards 100 kg of food saved
- **Badges row** – earned badges glow, unearned ones are greyed out:

| Badge | Condition to Earn |
|---|---|
| 🌟 First Share | At least 1 point earned |
| 🏆 Super Giver | Impact score ≥ 50 kg |
| 💚 100 kg Saved | Impact score ≥ 100 kg |
| 🔥 10-Day Streak | (Coming soon) |
| 🌍 Eco Hero | Impact score ≥ 200 kg |

- Menu options: **Switch Role** | **Settings** | **Sign Out**

**How to use it:**
- Scroll down to see all the sections.
- Tap **Switch Role** to go back to the Role Selection screen.
- Tap **Settings** to update your name or change your password.
- Tap **Sign Out** to log out (clears your token from the device).

---

### 7.14 Settings Screen

**File:** `lib/screens/shared/settings_screen.dart`

This screen has two sections.

#### Basic Information
- **Full Name** – editable, tap "Edit" to unlock the field then "Save Changes".
- **Email** – read-only, cannot be changed here (for account security).

#### Change Password
- **Current Password** – enter your existing password to verify it's you.
- **New Password** – must be at least 8 characters.
- **Confirm New Password** – must match the new password exactly.
- Tap **Update Password** to save changes.

**How to use it:**
1. To update your name: tap **Edit** → change the name → tap **Save Changes**.
2. To change your password: fill in all three password fields → tap **Update Password**.

**What happens behind the scenes:**
- Name update calls `PUT /api/users/:id` (currently shows a success toast; full implementation pending).
- Password change calls `POST /api/auth/change-password` with `{ currentPassword, newPassword }`.

---

### 7.15 Review Screen

**File:** `lib/screens/shared/review_screen.dart`

After a food exchange is complete, either party can leave a rating and comment.

**What the user sees:**
- A star rating selector (1–5 stars)
- A comment text area
- A "Submit Review" button

**What happens behind the scenes:**
- Submits to `POST /api/reviews` with `{ request_id, rating, comment }`.
- The giver's `rating` field in the database is updated as an average.

---

## 8. Data Models Explained

Models define the **shape of data** that travels between the app and the backend.

### UserModel (`lib/models/user_model.dart`)

| Field | Type | Description |
|---|---|---|
| `id` | String | Unique user ID from database |
| `name` | String | Full display name |
| `email` | String | Login email (unique) |
| `role` | String | `"giver"`, `"taker"`, or `""` (not chosen) |
| `avatarUrl` | String? | URL to profile picture (optional) |
| `points` | int | Gamification points earned |
| `rating` | double | Average rating (0.0 – 5.0) |
| `impactScore` | int | Kilograms of food saved/shared |
| `createdAt` | DateTime | When the account was created |

### FoodItemModel (`lib/models/food_item_model.dart`)

| Field | Type | Description |
|---|---|---|
| `id` | String | Unique listing ID |
| `giverId` | String | ID of the user who posted it |
| `giverName` | String | Display name of the giver |
| `title` | String | Name of the food (e.g. "Dal & Rice") |
| `category` | String | `meals`, `produce`, `bakery`, `dairy`, `other` |
| `description` | String | Free text about the food |
| `quantity` | int | How many units |
| `quantityUnit` | String | `portions`, `kg`, `litres`, etc. |
| `lat` / `lng` | double | GPS coordinates of pickup location |
| `address` | String | Human-readable pickup address |
| `expiryTime` | DateTime | When the food is no longer available |
| `photoUrl` | String? | URL to the food photo |
| `status` | String | `available`, `claimed`, `completed`, `expired` |
| `distanceKm` | double? | Distance from taker (calculated client-side) |

**Useful computed properties:**
- `timeRemaining` → Returns a string like "3h left", "45m left", or "Expired".
- `isExpired` → `true` if the expiry time is in the past.
- `categoryIcon` → Returns the emoji for the category (e.g. `🍱` for meals).

### RequestModel (`lib/models/request_model.dart`)

| Field | Type | Description |
|---|---|---|
| `id` | String | Unique request ID |
| `foodId` | String | Which food item was requested |
| `takerId` | String | Who made the request |
| `status` | String | `pending`, `accepted`, `rejected` |
| `createdAt` | DateTime | When the request was made |

---

## 9. Services Explained

### `api_service.dart` – The HTTP Client

This is a **singleton** class (only one instance ever exists) that handles all communication with the backend. You never call `http.get()` directly in the app – you always use `ApiService.instance.someMethod()`.

**Available methods:**

| Method | HTTP | Endpoint | What it does |
|---|---|---|---|
| `signIn(email, password)` | POST | `/auth/signin` | Logs in, returns user + token |
| `signUp(email, password, name)` | POST | `/auth/signup` | Creates account |
| `getMe(token)` | GET | `/auth/me` | Gets currently logged-in user |
| `changePassword(...)` | POST | `/auth/change-password` | Updates password |
| `updateUserRole(userId, role, token)` | PUT | `/users/:id` | Saves chosen role |
| `getFoodItems(...)` | GET | `/food` | Fetches food listings (with filters) |
| `getFoodItem(id)` | GET | `/food/:id` | Single food listing detail |
| `postFoodItem(body, token)` | POST | `/food` | Creates new food listing |
| `deleteFoodItem(id, token)` | DELETE | `/food/:id` | Removes a listing |
| `completeFoodItem(foodId, token)` | PUT | `/food/:id/status` | Marks food as completed |
| `getMyFoodItems(token)` | GET | `/food/mine` | Giver's own listings |
| `createRequest(foodId, token)` | POST | `/requests` | Taker requests food |
| `getGiverRequests(token)` | GET | `/requests/giver` | Requests for giver's food |
| `getTakerRequests(token)` | GET | `/requests/taker` | Requests made by taker |
| `updateRequestStatus(id, status, token)` | PUT | `/requests/:id` | Accept or reject request |
| `postReview(requestId, rating, comment, token)` | POST | `/reviews` | Submit a review |
| `getGiverReviews(giverId)` | GET | `/reviews/user/:id` | All reviews for a giver |

### `auth_service.dart` – Authentication State

This is a `ChangeNotifier` class (it can notify the UI when things change). It:
- Holds the current `UserModel` (or `null` if not logged in).
- Saves and loads the JWT token from `SharedPreferences`.
- Implements **rate limiting** – blocks login after too many failed attempts.
- Exposes `isLoading`, `isRateLimited`, and `remainingAttempts` for the UI.

When `signIn()` or `signUp()` succeeds, it saves the token locally so the user stays logged in across app restarts.

### `location_service.dart` – GPS & Geocoding

This service:
- Asks for location permissions (if not already granted).
- Uses the `geolocator` package to get the device's GPS position.
- Calls OpenStreetMap's **Nominatim** API to convert GPS coordinates → a human-readable address (reverse geocoding).

---

## 10. Backend API Reference

The backend runs on **Express.js** with **TypeScript**. All routes are prefixed with `/api`.

### Base URL

| Mode | URL |
|---|---|
| Production (Railway) | `https://foodloop-production-9c9e.up.railway.app/api` |
| Local Development | `http://localhost:4000/api` |
| Android Emulator (local) | `http://10.0.2.2:4000/api` |

### Authentication Endpoints

#### POST `/auth/signup` – Create Account
**Request body:**
```json
{
  "name": "Priya Sharma",
  "email": "priya@example.com",
  "password": "password123"
}
```
**Success response:**
```json
{
  "user": { "id": 1, "name": "Priya Sharma", "email": "priya@example.com", "role": "" },
  "token": "eyJhbGci..."
}
```

#### POST `/auth/signin` – Login
**Request body:**
```json
{
  "email": "priya@example.com",
  "password": "password123"
}
```
**Success response:**
```json
{
  "user": { "id": 1, "name": "Priya Sharma", "email": "priya@example.com", "role": "giver" },
  "token": "eyJhbGci..."
}
```

#### GET `/auth/me` – Get Current User
**Headers:** `Authorization: Bearer <token>`
**Response:** Current user's full profile.

#### POST `/auth/change-password` – Update Password
**Headers:** `Authorization: Bearer <token>`
**Request body:**
```json
{
  "currentPassword": "oldpass",
  "newPassword": "newpass123"
}
```

---

### Food Endpoints

#### GET `/food` – List Available Food
**Query parameters (all optional):**
| Param | Example | Purpose |
|---|---|---|
| `lat` | `28.6139` | Centre latitude for location-based search |
| `lng` | `77.2090` | Centre longitude |
| `radius` | `10` | Search radius in km |
| `status` | `available` | Filter by status |
| `category` | `meals` | Filter by food category |

**Response:** Array of food items.

#### GET `/food/mine` – My Listings (Giver only)
**Headers:** `Authorization: Bearer <token>`
**Response:** Array of food items posted by the authenticated giver.

#### GET `/food/:id` – Single Food Item Detail
**Response:** Single food item object.

#### POST `/food` – Create Food Listing (Giver only)
**Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data` (if uploading a photo)
**Body fields:**
```
title, category, description, quantity, quantity_unit, lat, lng, address, expiry_time, giver_phone, photo (file, optional)
```

#### DELETE `/food/:id` – Delete a Listing (Giver only)
**Headers:** `Authorization: Bearer <token>`

#### PUT `/food/:id/status` – Update Food Status
**Body:** `{ "status": "completed" }`

---

### Request Endpoints

#### POST `/requests` – Create a Request (Taker only)
**Body:** `{ "food_id": 5 }`

#### GET `/requests/giver` – Requests for Giver's Food
**Headers:** `Authorization: Bearer <token>`

#### GET `/requests/taker` – Requests Made by Taker
**Headers:** `Authorization: Bearer <token>`

#### PUT `/requests/:id` – Accept or Reject a Request
**Body:** `{ "status": "accepted" }` or `{ "status": "rejected" }`

---

### Review Endpoints

#### POST `/reviews` – Submit a Review
**Body:** `{ "request_id": 3, "rating": 5, "comment": "Great person!" }`

#### GET `/reviews/user/:giverId` – Get Reviews for a Giver

---

## 11. Database Schema

The MySQL database has **5 tables**.

### `users`
Stores every registered user.

| Column | Type | Notes |
|---|---|---|
| `id` | INT AUTO_INCREMENT | Primary key |
| `name` | VARCHAR(100) | Not null |
| `email` | VARCHAR(100) | Unique, not null |
| `password` | VARCHAR(100) | Hashed, not null |
| `role` | VARCHAR(10) | `giver` or `taker` |
| `avatar_url` | VARCHAR(255) | Optional profile picture |
| `impact_score` | INT | Kilograms of food saved/shared |
| `points` | INT | Gamification points |
| `rating` | DOUBLE | Average community rating |
| `created_at` | TIMESTAMP | Auto-set on creation |

### `food_items`
Every food listing ever posted.

| Column | Notes |
|---|---|
| `giver_id` | Foreign key → `users.id` |
| `title`, `category`, `description` | Food info |
| `quantity`, `quantity_unit` | How much food |
| `lat`, `lng` | GPS location |
| `address` | Human-readable address |
| `photo_url` | Path to uploaded image |
| `giver_phone` | Contact number for pickup |
| `status` | `available` / `claimed` / `completed` |
| `expiry_time` | Datetime when listing expires |

### `requests`
When a Taker requests a food item.

| Column | Notes |
|---|---|
| `food_id` | Foreign key → `food_items.id` |
| `taker_id` | Foreign key → `users.id` |
| `status` | `pending` / `accepted` / `rejected` |

### `reviews`
Ratings and comments after a pickup.

| Column | Notes |
|---|---|
| `request_id` | Foreign key → `requests.id` |
| `reviewer_id` | Foreign key → `users.id` |
| `rating` | Integer 1–5 |
| `comment` | Free text |

### `messages`
In-app chat messages (ready for future real-time use).

| Column | Notes |
|---|---|
| `request_id` | Foreign key → `requests.id` |
| `sender_id` | Foreign key → `users.id` |
| `content` | The message text |

**Table Relationships:**
```
users ──< food_items (giver_id)
users ──< requests   (taker_id)
food_items ──< requests (food_id)
requests ──< reviews  (request_id)
requests ──< messages (request_id)
```

---

## 12. Security Features

FoodLoop implements several protection layers:

### JWT Token Authentication
- Every user gets a **JSON Web Token** (JWT) after signing in.
- This token is included in the `Authorization` header for every API call that requires authentication: `Authorization: Bearer <token>`.
- The backend middleware verifies the token before allowing access to protected routes.

### Rate Limiting (Login Protection)
- The `AuthService` tracks failed login attempts.
- After **5 consecutive failures**, login is blocked for **15 minutes**.
- The Sign In screen shows a countdown and disables the button during the lockout period.
- This prevents brute-force attacks.

### Input Sanitisation
- `SecurityUtils.isValidEmail()` validates email format using a regex.
- `SecurityUtils.hasSuspiciousPatterns()` checks inputs for common **SQL injection** and **XSS** attack patterns before any API call is made.

### Password Requirements
- Minimum **8 characters** enforced on Sign Up and in Settings.
- Passwords are stored **hashed** in the database (never plaintext).

### Token Storage
- The JWT token is stored in `SharedPreferences` (device local storage), not in plain memory, so it persists across app restarts.

---

## 13. Common Errors & Troubleshooting

### "SocketException: Connection refused"
**Cause:** The backend isn't running, or the API URL points to the wrong address.
**Fix:**
1. Make sure the backend server is started (`npm run dev` in the `backend/` folder).
2. Check the URL in `lib/services/api_service.dart` for your platform (see [Step 6 of Setup](#5-environment-setup-first-time)).

### "Token expired" or "Unauthorized"
**Cause:** Your login session has expired.
**Fix:** Sign out and sign back in.

### "No authentication token found"
**Cause:** The app lost the locally stored token (e.g. app reinstall, cleared storage).
**Fix:** Sign in again. Your account data is still in the database.

### "Port Already in Use"
**Cause:** Something else is running on port 4000.
**Fix:** Edit `backend/.env` and change `PORT=4000` to `PORT=5000`. Then also update the API URL in `lib/services/api_service.dart`.

### Flutter: "pub get failed"
**Cause:** Missing or incompatible packages.
**Fix:**
```bash
flutter clean
flutter pub get
```

### Backend: "Cannot connect to database"
**Cause:** MySQL isn't running or credentials in `.env` are wrong.
**Fix:**
1. Start MySQL: `sudo systemctl start mysql` (Linux) or via MySQL Workbench.
2. Double-check `DATABASE_URL` in `backend/.env`.

### Location not working on Android Emulator
**Cause:** Emulator doesn't have real GPS.
**Fix:** In Android Studio's Extended Controls → Location, set a manual location.

### App shows blank screen / frozen on loading
**Cause:** Usually a backend error. The app is waiting for a response that never comes.
**Fix:** Check the Flutter console for error messages. Also check the backend terminal for errors.

---

## 14. Glossary

| Term | Meaning |
|---|---|
| **Giver** | A user who posts surplus food for others to take |
| **Taker** | A user or NGO who requests and collects free food |
| **Listing** | A food item posted by a Giver |
| **Request** | A Taker asking to collect a specific listing |
| **JWT** | JSON Web Token – a secure string that proves you're logged in |
| **Bearer Token** | A JWT sent in the HTTP header to authenticate requests |
| **REST API** | A way for the app and backend to communicate using standard web calls (GET, POST, PUT, DELETE) |
| **Flutter** | Google's framework for building cross-platform apps using the Dart language |
| **Dart** | The programming language used to write the Flutter app |
| **TypeScript** | A typed version of JavaScript used for the backend (Node.js) |
| **Express** | A lightweight web server framework for Node.js |
| **MySQL** | A relational database where all app data is stored |
| **SharedPreferences** | Android/iOS/Web way to store small key-value data locally on the device |
| **Provider** | A Flutter state management package – allows sharing data (like login state) across screens |
| **GoRouter** | A Flutter navigation package for declaring routes and navigating between screens |
| **OSM** | OpenStreetMap – a free, community-driven map used instead of Google Maps |
| **Nominatim** | OpenStreetMap's geocoding service – converts GPS coordinates to addresses and vice versa |
| **Multipart Upload** | A way of sending a file (like a photo) together with other form data in one HTTP request |
| **Singleton** | A class that only ever has one instance (e.g. `ApiService.instance`) |
| **ChangeNotifier** | A Flutter pattern for notifying the UI when data changes (used by `AuthService`) |
| **Impact Score** | The total kg of food a Giver has shared – used for badges and progress |
| **Rate Limiting** | Blocking repeated login attempts to prevent brute-force attacks |
| **Reverse Geocoding** | Converting GPS coordinates (numbers) into a human-readable address string |

---

*This user manual covers the complete FoodLoop application as of April 2026. For setup issues, refer to `SETUP.md`. For a developer changelog, refer to `CHANGES.md`.*
