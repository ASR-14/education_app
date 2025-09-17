# Education App 📚

A modern Flutter-based education platform that provides an interactive learning experience with real-time features.

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-orange.svg)](https://firebase.google.com)
[![Supabase](https://img.shields.io/badge/Supabase-Storage-purple.svg)](https://supabase.com)

## 🚀 Features

- **Course Management**
  - Create and manage educational courses
  - Upload course materials and videos
  - Track course progress
  - Real-time course updates

- **Interactive Learning**
  - Real-time chat functionality
  - Group discussions
  - File sharing capabilities
  - Exam

- **User Experience**
  - Modern and intuitive UI
  - Responsive design
  - Offline support
  - Push notifications

## 🏗️ Architecture

The app follows a clean architecture pattern with the following layers:

```
lib/
├── core/                 # Core functionality and utilities
│   ├── errors/          # Error handling
│   ├── utils/           # Utility functions
│   └── widgets/         # Reusable widgets
│
├── src/                 # Feature modules
│   ├── course/          # Course management
│   │   ├── data/       # Data layer
│   │   ├── domain/     # Business logic
│   │   └── presentation/# UI components
│   │
│   ├── chat/           # Chat functionality
│   │   ├── data/       # Data layer
│   │   ├── domain/     # Business logic
│   │   └── presentation/# UI components
│   │
│   └── auth/           # Authentication
│       ├── data/       # Data layer
│       ├── domain/     # Business logic
│       └── presentation/# UI components
```

## 🛠️ Technologies

- **Frontend**
  - Flutter 3.19.0
  - Dart 3.3.0
  - Bloc for state management
  - GetIt for dependency injection

- **Backend**
  - Firebase Firestore for real-time database
  - Firebase Authentication
  - Supabase for file storage
  - Cloud Functions for backend logic

- **Development Tools**
  - Very Good Analysis for code quality
  - Flutter Bloc for state management
  - Equatable for value equality
  - Freezed for code generation


## 🚀 Getting Started

1. **Prerequisites**
   - Flutter SDK 3.19.0 or higher
   - Dart SDK 3.3.0 or higher
   - Firebase CLI
   - Supabase CLI

2. **Installation**
   ```bash
   git clone https://github.com/yourusername/education_app.git
   cd education_app
   flutter pub get
   ```

3. **Configuration**
   - Set up Firebase project
   - Configure Supabase storage
   - Add configuration files

4. **Running the App**
   ```bash
   flutter run
   ```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
