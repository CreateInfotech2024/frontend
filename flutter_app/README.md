# Beauty LMS Flutter App

A Flutter application for the Beauty LMS Video Conferencing System, providing cross-platform support for Android, iOS, and Web.

## 🚀 Features

### ✅ Implemented Features
- **Course Creation**: Create new live courses with custom details
- **Meeting Joining**: Join existing meetings using 6-digit meeting codes
- **Real-time Chat**: Socket.IO powered chat system with message history
- **Participant Management**: View and manage meeting participants in real-time
- **API Testing Suite**: Comprehensive testing tool for all backend APIs
- **Responsive Design**: Adaptive layout for mobile, tablet, and desktop
- **Cross-platform**: Runs on Android, iOS, and Web

### 🎥 Video Conferencing Components
- Meeting room interface with video placeholder
- Participant list with real-time updates
- Chat panel with system messages
- Meeting controls (mute, camera, screen share placeholders)

## 📱 Platform Support

- ✅ **Android**: Full native support
- ✅ **iOS**: Full native support
- ✅ **Web**: Progressive Web App support

## 🛠️ Setup & Installation

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- For Android: Android Studio and Android SDK
- For iOS: Xcode (macOS only)
- For Web: Chrome browser

### Installation

```bash
# Navigate to flutter_app directory
cd flutter_app

# Get dependencies
flutter pub get

# Run on your preferred platform
flutter run              # Auto-selects available device
flutter run -d chrome    # Run on Chrome (Web)
flutter run -d android   # Run on Android
flutter run -d ios       # Run on iOS (macOS only)
```

### Building for Production

```bash
# Build for Android
flutter build apk --release
flutter build appbundle --release

# Build for iOS (macOS only)
flutter build ios --release

# Build for Web
flutter build web --release
```

## 📦 Dependencies

- **http**: REST API client
- **socket_io_client**: Real-time Socket.IO communication
- **provider**: State management
- **intl**: Date and time formatting

## 🏗️ Architecture

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── live_course.dart
│   ├── participant.dart
│   └── chat_message.dart
├── services/              # Business logic
│   ├── api_service.dart
│   └── socket_service.dart
├── screens/               # Full-screen pages
│   ├── home_screen.dart
│   ├── meeting_room_screen.dart
│   ├── live_courses_screen.dart
│   └── api_tester_screen.dart
└── widgets/               # Reusable components
    ├── course_creator.dart
    ├── meeting_joiner.dart
    ├── chat_panel.dart
    └── participants_list.dart
```

## 🔧 API Integration

### Backend URL
- Production: `https://krishnabarasiya.space/api`

### REST API Endpoints
```
POST /api/live_courses           # Create new course
GET  /api/live_courses           # Get all courses
GET  /api/live_courses/:id       # Get course by ID
POST /api/live_courses/:id/start # Start course
POST /api/live_courses/join      # Join course
POST /api/live_courses/:id/leave # Leave course
POST /api/live_courses/:id/complete # Complete course
GET  /health                     # Health check
```

### Socket.IO Events
```
Client → Server:
  - join-meeting
  - leave-meeting
  - chat-message

Server → Client:
  - chat-message
  - participant-joined
  - participant-left
  - meeting-ended
```

## 🎯 Usage Guide

### 1. Create a Course
1. Launch the app
2. Fill in course details (name, description, instructor, etc.)
3. Tap "🎥 Create & Start Course"
4. You'll be automatically joined as the host

### 2. Join a Meeting
1. Launch the app
2. Enter the 6-digit meeting code
3. Enter your name
4. Tap "🚀 Join Meeting"

### 3. Meeting Features
- **Real-time Chat**: Send and receive messages instantly
- **Participant List**: See who's in the meeting
- **Meeting Controls**: Toggle chat, mute, camera controls
- **Leave/End Meeting**: Participants can leave, hosts can end

### 4. API Testing
1. Tap the bug icon in the app bar
2. Tap "🚀 Run All Tests"
3. View detailed test results with pass/fail statistics

## 🎨 UI/UX Features

- **Material Design 3**: Modern Flutter Material Design
- **Gradient Backgrounds**: Beautiful visual design
- **Responsive Layout**: Adapts to screen sizes
- **Dark/Light Theme**: Supports system theme
- **Smooth Animations**: Native Flutter animations

## 🔍 Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Code Formatting
```bash
flutter format .
```

## 🚀 Future Enhancements

- **WebRTC Integration**: Real video/audio streaming
- **Screen Sharing**: Desktop sharing capabilities
- **Recording**: Meeting recording and playback
- **File Sharing**: Document and media sharing
- **User Authentication**: Login and user management
- **Push Notifications**: Meeting reminders and notifications
- **Offline Support**: Local data caching

## 📞 Support

For issues or questions:
1. Check the API testing tool for backend connectivity
2. Verify the backend server is accessible
3. Check Flutter console for detailed error messages
4. Ensure Socket.IO connections are not blocked

## 🏷️ Version Information

- **Flutter App Version**: 1.0.0
- **Flutter SDK**: 3.0.0+
- **Backend Compatibility**: Beauty LMS API v1.0.0
- **Platform Support**: Android, iOS, Web
