# SceneLink

**SceneLink** is a Flutter mobile application that connects creative professionals across the West Midlands — film-makers, photographers, sound engineers, radio producers, and more — so they can discover each other, collaborate on projects, and build their portfolios together.

---

## Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Tech Stack](#tech-stack)
4. [Project Structure](#project-structure)
5. [Setup & Installation](#setup--installation)
6. [Firebase Configuration](#firebase-configuration)
7. [Architecture](#architecture)
8. [Screens & Navigation](#screens--navigation)
9. [Data Models](#data-models)
10. [Authentication](#authentication)
11. [Premium Features](#premium-features)
12. [Accessibility](#accessibility)
13. [Contributing](#contributing)

---

## Overview

SceneLink was built to solve a real problem in the creative industry: talented people working in isolation when they could be collaborating. The app lets you:

- **Discover** other creatives by skill, role, and location
- **Post and browse** collaboration project briefs
- **Apply** to projects with optional **Blind Collaboration Mode** (your identity is hidden during the first review stage)
- **Message** collaborators in real time via Firebase
- **Share** your portfolio and receive peer reviews
- **Unlock Premium** for analytics, priority visibility, and advanced insights

---

## Key Features

| Feature | Description |
|---|---|
| 🔍 **Discovery** | Search and filter creatives by role, experience level, skills, and location |
| 📁 **Projects** | Browse, create, edit, and apply to collaboration briefs |
| 🙈 **Blind Mode** | Apply to a project anonymously — your name and photo are hidden during first review |
| 💬 **Real-time Messaging** | One-to-one chat powered by Firestore real-time streams |
| 🗺️ **Nearby Map** | Discover studios, venues, hubs, and active projects on an interactive map |
| 🏆 **Premium** | Subscription plan unlocking analytics dashboard, priority search placement, and portfolio insights |
| 🌐 **Social Feed** | Creative posts and peer reviews from your network |
| ♿ **Accessibility** | Configurable text scale, high-contrast mode, reduced-motion toggle, screen-reader support |
| 🌙 **Theme** | Light, dark, and system-adaptive themes |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart 3.x) |
| **State Management** | Provider (`ChangeNotifier`) |
| **Navigation** | go_router 17 |
| **Backend / Auth** | Firebase Authentication (Email + Google Sign-In) |
| **Database** | Cloud Firestore |
| **File Storage** | Firebase Storage |
| **Maps** | flutter_map + latlong2 + geolocator |
| **Fonts** | Google Fonts (Plus Jakarta Sans, Poppins) |
| **Image Caching** | cached_network_image |
| **Local Storage** | shared_preferences |
| **Media Picking** | image_picker + file_picker |
| **Internationalisation** | intl |

---

## Project Structure

```
lib/
├── main.dart                    # Entry point — detects Firebase availability
├── firebase_options.dart        # Auto-generated Firebase config
└── src/
    ├── app.dart                 # Root widget: MaterialApp.router + Provider
    ├── bootstrap.dart           # Firebase initialisation
    ├── models/
    │   └── app_models.dart      # All data classes (AppUser, CreativeProject, ChatThread, …)
    ├── state/
    │   └── app_controller.dart  # Single ChangeNotifier — all business logic + repository calls
    ├── repositories/
    │   ├── app_repository.dart          # Abstract interface
    │   ├── firebase_app_repository.dart # Firestore / Auth / Storage implementation
    │   └── mock_app_repository.dart     # In-memory mock for tests / demo
    ├── core/
    │   ├── routing/
    │   │   └── scene_link_router.dart   # go_router configuration
    │   ├── theme/
    │   │   └── scene_link_theme.dart    # Material 3 light + dark themes
    │   ├── services/
    │   │   └── local_preferences_service.dart  # shared_preferences wrapper
    │   └── data/
    │       └── seed_data.dart           # Demo/fallback seed data
    ├── screens/
    │   ├── auth/           # Login, Signup, AuthGate
    │   ├── home/           # Home feed (trending creatives + latest projects)
    │   ├── projects/       # Project list, detail, create/edit
    │   ├── messages/       # Conversation list + real-time chat
    │   ├── social/         # Discover creatives (friends/network)
    │   ├── feed/           # Social posts feed
    │   ├── maps/           # Interactive flutter_map
    │   ├── profile/        # Own profile + any user's public profile
    │   ├── premium/        # Subscription / payment screen
    │   ├── settings/       # Theme, accessibility, premium analytics dashboard
    │   ├── search/         # Global search
    │   ├── shell/          # AppShell — bottom nav + IndexedStack for tabs
    │   └── splash_screen.dart
    └── widgets/
        ├── scene_link_widgets.dart  # Shared design-system widgets (SceneCard, SceneTag, …)
        ├── google_logo_icon.dart    # Official Google "G" four-colour logo (CustomPainter)
        └── auth_shell.dart          # Gradient wrapper for auth screens
```

---

## Setup & Installation

### Prerequisites

- Flutter SDK **≥ 3.x** (`flutter --version`)
- Dart SDK **≥ 3.11**
- A Firebase project (see [Firebase Configuration](#firebase-configuration))
- Android Studio / VS Code with Flutter plugin

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/your-org/screenlink.git
cd screenlink

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

> **Tip:** Use `flutter run --release` for a production build.

---

## Firebase Configuration

SceneLink uses Firebase for authentication, real-time database, and file storage.

### Required Firebase services

| Service | Purpose |
|---|---|
| Firebase Authentication | Email/password + Google Sign-In |
| Cloud Firestore | Users, projects, chats, messages |
| Firebase Storage | Profile photos and portfolio media |

### Steps

1. Go to the [Firebase Console](https://console.firebase.google.com) and create a project.
2. Add an **Android** app (package: `com.example.screenlink`) and download `google-services.json` → place in `android/app/`.
3. Add an **iOS** app and download `GoogleService-Info.plist` → place in `ios/Runner/`.
4. Enable **Authentication** → Sign-in methods: Email/Password and Google.
5. Create a **Firestore** database (start in test mode for development).
6. Enable **Storage**.
7. Run `flutterfire configure` to regenerate `lib/firebase_options.dart`.

### Firestore collections

| Collection | Description |
|---|---|
| `users/{uid}` | User profile document |
| `projects/{projectId}` | Collaboration brief |
| `chats/{chatId}` | Chat thread metadata (participants, lastMessage) |
| `chats/{chatId}/messages` | Sub-collection of messages |

### Firestore security rules (development)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

> Replace with tighter rules before shipping to production.

---

## Architecture

SceneLink follows a simple **Repository → Controller → UI** pattern:

```
UI Screens
    │  context.watch<AppController>()
    ▼
AppController (ChangeNotifier)
    │  repository.someMethod()
    ▼
AppRepository (abstract interface)
    │
    ├── FirebaseAppRepository  ← real Firebase calls (production)
    └── MockAppRepository      ← in-memory mock (tests / demo)
```

- **`AppController`** is the single source of truth. It holds all in-memory state (current user, projects list, filter selections, etc.) and exposes methods that call the repository then call `notifyListeners()`.
- **Screens** consume the controller via `context.watch<AppController>()` (reactive) or `context.read<AppController>()` (one-shot).
- **GoRouter** rebuilds the navigation tree whenever `AppController` notifies (because it is passed as `refreshListenable`), which handles automatic redirects on login/logout.
- **SeedData** provides fallback demo content when Firebase is unavailable or the Firestore collections are empty.

---

## Screens & Navigation

### Bottom-tab screens (inside `AppShell`)

| Tab | Route | Screen |
|---|---|---|
| Home | `/app` (default) | Home feed — trending creatives + latest projects |
| Search | `/search` | Filter-driven search for creatives and projects |
| Projects | `/projects` | Full project list with status filters |
| Maps | `/maps` | flutter_map showing studios, venues, and project locations |
| Messages | `/messages` | Conversation list |
| Profile | `/profile` | Authenticated user's own profile |

### Push screens (full-page routes)

| Route | Screen |
|---|---|
| `/login` | Sign-in form + Google sign-in |
| `/signup` | Registration form |
| `/projects/new` | Create a new project brief |
| `/projects/:projectId` | Project detail + apply flow |
| `/projects/:projectId/edit` | Edit an existing project |
| `/messages/:chatId` | Real-time chat thread |
| `/profile/:userId` | Another user's public profile |
| `/premium` | Subscription / payment screen |
| `/premium-dashboard` | Premium analytics dashboard |
| `/settings` | App settings (theme, accessibility, sign-out) |
| `/accessibility` | Accessibility configuration |
| `/friends` | Discover and connect with other creatives |

---

## Data Models

### `AppUser`
Core user profile stored in Firestore under `users/{uid}`.

| Field | Type | Description |
|---|---|---|
| `uid` | `String` | Firebase Auth UID |
| `name` | `String` | Display name |
| `role` | `UserRole` | `student`, `freelancer`, or `professional` |
| `skills` | `List<String>` | Creative skills (e.g. Directing, Audio Editing) |
| `experienceLevel` | `ExperienceLevel` | `beginner`, `intermediate`, or `advanced` |
| `verified` | `bool` | Manually verified badge |
| `profileImage` | `String` | URL or base64 data URL |
| `portfolio` | `List<String>` | URLs to portfolio items |
| `savedProjectIds` | `List<String>` | Projects saved by the user |

### `CreativeProject`
Collaboration brief stored under `projects/{projectId}`.

| Field | Type | Description |
|---|---|---|
| `title` | `String` | Project name |
| `category` | `String` | e.g. Film, Radio, Photography |
| `requiredRoles` | `List<String>` | Roles being sought |
| `deadline` | `DateTime` | Application close date |
| `status` | `ProjectStatus` | `open`, `inProgress`, or `completed` |
| `applicants` | `List<String>` | UIDs of normal applicants |
| `blindApplications` | `List<String>` | UIDs of anonymous applicants |
| `budget` | `double?` | Optional project budget (£) |

### `CreativeMessage`
Individual chat message stored under `chats/{chatId}/messages`.

| Field | Type | Description |
|---|---|---|
| `senderId` | `String` | Sender's UID |
| `receiverId` | `String` | Recipient's UID |
| `message` | `String` | Message text |
| `timestamp` | `DateTime` | Server timestamp from Firestore |
| `read` | `bool` | Read receipt |
| `chatId` | `String` | Parent chat ID |

---

## Authentication

- **Email/Password** — sign-up creates a Firestore `users` document on first registration.
- **Google Sign-In** — uses `google_sign_in` package on mobile; `signInWithPopup` on web. A Firestore profile document is created automatically if one doesn't exist.
- **Session persistence** — Firebase Auth handles token refresh automatically.
- **Route guards** — GoRouter's `redirect` callback (powered by `AppController.isReady` and `currentUser`) automatically redirects unauthenticated users to `/login` and authenticated users away from auth screens.

---

## Blind Collaboration Mode

One of SceneLink's signature features. When applying to a project:

- **Blind mode ON** (default): your UID is added to `blindApplications`. The project owner sees a count of blind applicants but cannot see names or profile images.
- **Blind mode OFF**: normal application — your profile is visible to the project owner from the start.

This reduces unconscious bias and ensures applications are evaluated on skill and portfolio, not appearance or identity.

---

## Premium Features

Premium is a simulated subscription (Stripe integration ready). After subscribing:

| Feature | Description |
|---|---|
| Analytics dashboard | Profile views, project engagement, collaboration requests, portfolio clicks |
| Priority search listing | Premium users appear higher in discovery results |
| Unlimited applications | No cap on project applications |
| Portfolio insights | Detailed click-through and view metrics |

Navigate to **Settings → Upgrade to Premium** or tap **Premium** from the home screen features carousel. After payment confirmation, the app navigates to the **Premium Dashboard** (`/premium-dashboard`).

---

## Accessibility

SceneLink is built with accessibility as a first-class concern:

| Setting | Description |
|---|---|
| **Text scale factor** | Scales all text from 0.8× to 1.6× |
| **High contrast** | Increases border contrast and removes translucent surfaces |
| **Reduced motion** | Disables animations throughout the app |
| **Screen-reader friendly** | Enables `accessibleNavigation` in `MediaQuery` |

Settings are persisted locally via `shared_preferences` and synced to the user's Firestore profile so they roam across devices.

---

## Contributing

1. Fork the repo and create a feature branch: `git checkout -b feat/my-feature`
2. Follow the existing architecture (Repository → Controller → UI).
3. Run `flutter analyze` and resolve all warnings before submitting a PR.
4. Test on both Android and iOS (or their emulators).

---

## License

This project is proprietary. All rights reserved.
