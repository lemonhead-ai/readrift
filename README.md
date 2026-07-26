# ReadRift 🌌

**The new way to interact with your books.**

ReadRift is a premium, immersive reading platform designed to transform your digital library into a personal "Reading Universe." It combines high-end Glassmorphism UI with cutting-edge AI and multimodal features.

---

## ✨ Features

- **Reading Universe UI**: Sleek Glassmorphism design with support for OLED Pitch Black, Sepia, and Snowy White themes.
- **Smart AI Insights**: Powered by Gemini 1.5 Flash. Get instant chapter summaries and character lookups directly in the reader.
- **Universe Sync**: All your local imports (EPUB/PDF) are automatically backed up to Firebase Storage and synced across all your devices.
- **Audio Universe**: 
    - **Audiobook Mode**: Integrated Text-to-Speech (TTS) for hands-free reading.
    - **Ambient Atmosphere**: Immersive audio loops (Rain, Café, Focus) to enhance your reading focus.
- **Intelligence**: Real-time reading speed calculations and "Time to Finish" estimates.
- **Discovery**: Integrated search with Project Gutenberg (Gutendex) and smart category discovery.
- **Gamification**: Daily reading goals and streak tracking to keep you motivated.

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: `^3.3.0`
- **Firebase Project**: Set up a Firebase project and add the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files to the respective directories.
- **Gemini API Key**: Obtain a key from [Google AI Studio](https://aistudio.google.com/).

### Running the App

To enable the **AI Insights** and other smart features, you must provide your Gemini API key as a dart-define during the build or run process.

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_API_KEY_HERE
```

### Setup Instructions

1. **Firebase Storage**: Ensure your Firebase Storage rules allow authenticated users to read/write to `users/{uid}/books/`.
2. **Firestore**: Ensure Firestore is enabled in your project. Rules should restrict access to user-specific data under the `users/{uid}/` path.

---

## 🛠️ Technology Stack

- **UI**: Flutter (Material 3 + Cupertino)
- **State Management**: Provider
- **Database/Auth**: Firebase (Auth, Firestore, Storage)
- **AI**: Gemini 1.5 Flash via `google_generative_ai`
- **Audio**: `flutter_tts` & `audioplayers`
- **Navigation**: `go_router`

---

## 📄 License

This project is for personal use and serves as a premium reading experience.


