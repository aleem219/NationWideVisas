# NationWide Visas - Flutter App

**Making Dreams Possible...**

A beautifully designed Flutter app for NationWide Visas, featuring:
- Animated Splash Screen with NW branding
- Phone Number Login Screen (red-themed, no country picker)
- OTP Verification Screen with 4-digit input
- Smooth page transitions and micro-animations

## Color Palette
| Role         | Color       |
|--------------|-------------|
| Primary Red  | `#CC0000`   |
| Dark Red     | `#990000`   |
| Gold Accent  | `#FFD700`   |
| Background   | `#F8F8F8`   |
| Dark Text    | `#1A1A2E`   |

## Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0

### Setup & Run
```bash
# 1. Install dependencies
flutter pub get

# 2. Run on device or emulator
flutter run

# 3. Build APK
flutter build apk --release
```

## Project Structure
```
lib/
├── main.dart                        # App entry point
├── theme.dart                       # Colors & theme
└── screens/
    ├── splash_screen.dart           # Animated splash
    ├── phone_login_screen.dart      # Phone number input
    └── otp_verification_screen.dart # OTP code entry
```

## Dependencies
- `google_fonts` - Poppins typography
- `pin_code_fields` - OTP input
- `intl_phone_field` - Phone field formatting

## Screens

### 1. Splash Screen
- Full red gradient background with animated NW logo
- Brand name with gold accent
- Animated "Get Started" button
- Wave decorative element

### 2. Phone Login Screen
- Red curved header (no country picker)
- Clean phone number input
- Gold "Send Verification Code" button
- Skip option & Terms note

### 3. OTP Verification Screen
- 4-digit code input boxes
- Auto-advance on digit entry
- Resend code with 30s countdown timer
- Success dialog on verification
