# Edurance - Development Guide & Architecture

## Project Overview
AI-powered personalized learning app for Indian school children aged 5-10 (Class 1-5).
Platform: Flutter + Dart (Android & iOS)

## Tech Stack
- Framework: Flutter
- State Management: flutter_riverpod + riverpod_annotation
- Navigation: go_router
- Backend: supabase_flutter (add later)
- AI: google_generative_ai (Gemini)
- Animations: rive, lottie
- Graphics: flutter_svg
- Fonts: google_fonts

## Navigation Flow
/signup → /login → /diagnostic → /diagnostic-report → /modules → /teaching → /parent-control

## Folder Structure
lib/
├── main.dart
├── core/
│   ├── router/app_router.dart
│   ├── theme/app_theme.dart
│   └── utils/constants.dart
├── features/
│   ├── auth/
│   │   ├── signup_screen.dart
│   │   └── login_screen.dart
│   ├── diagnostic/
│   │   ├── diagnostic_test_screen.dart
│   │   └── diagnostic_report_screen.dart
│   ├── learning/
│   │   ├── modules_screen.dart
│   │   └── teaching_screen.dart
│   └── parent/
│       └── parent_control_screen.dart
├── services/
│   ├── supabase/ (add later)
│   └── ai/ (add later)
└── shared/
    ├── widgets/
    └── models/

## Design Guidelines
- Target age: 5-10 years old
- Colors: bright, warm, playful — sunny yellow, sky blue, coral orange, grass green
- Typography: large, rounded, readable — use Google Fonts (Nunito or Quicksand)
- Buttons: large, rounded corners, gradient fills
- Touch targets: minimum 48x48
- Tone: encouraging, joyful, never intimidating

## Screen List
1. Signup — child name, age stepper, gender pills, class selector (1-5), parent mobile
2. Login — email + password, simple
3. Diagnostic Test — multi-subject MCQ, 20 questions, progress bar, subject badge per question
4. Diagnostic Report — 3 sections: You're a Star At / Almost There / Let's Learn This Together
5. Modules Screen — subject cards grid with topic and progress
6. Teaching Screen — large content card (65% height) + doubt input bar at bottom
7. Parent Control — weekly lesson scheduler per subject

## Build Order
1. UI only first — no backend
2. Navigation wiring second
3. Supabase auth third
4. Gemini AI integration fourth

## Current Status
- Flutter project scaffolded
- Folder structure created
- Building UI screens one by one
- Start with: signup_screen.dart