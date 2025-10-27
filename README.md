# Inventory App

Native Android inventory management application built with Kotlin. This app helps manage products, packages, and serial numbers using barcode/QR code scanning.

## Features

### ✅ Implemented
- **Barcode/QR Scanner**: Assign serial numbers to products using camera-based scanning
- **Serial Number Validation**: Automatic validation and duplicate detection
- **Room Database**: Offline-first local data storage
- **MVVM Architecture**: Clean, maintainable code structure
- **Multiple Barcode Formats**: Support for QR, EAN-13, EAN-8, Code 128, and more

### 🚧 In Progress (See PROJECT_PLAN.md)
- Product and package management
- Shipping label generation
- Data export/import
- Multi-device synchronization

## Tech Stack

- **Language**: Kotlin
- **Minimum SDK**: API 26 (Android 8.0)
- **Target SDK**: API 35
- **Architecture**: MVVM with Repository pattern
- **Database**: Room (SQLite)
- **Camera**: CameraX API
- **Barcode Scanning**: ML Kit
- **DI**: Manual dependency injection (Hilt planned)
- **Testing**: JUnit, Mockito, Espresso

## Getting Started

### Prerequisites
- Android Studio Hedgehog (2023.1.1) or newer
- Android SDK API 26-35
- JDK 17

### Build
```bash
./gradlew assembleDebug
```

### Run Tests
```bash
./gradlew test
./gradlew connectedAndroidTest
```

### Install on Device
```bash
./gradlew installDebug
```

## Project Structure

```
inventory-app/
├── app/                    # Application module
│   ├── src/
│   │   ├── main/          # Main source set
│   │   │   ├── java/      # Kotlin source files
│   │   │   └── res/       # Resources (layouts, strings, etc.)
│   │   ├── test/          # Unit tests
│   │   └── androidTest/   # Instrumented tests
│   └── build.gradle.kts   # App-level build configuration
├── build.gradle.kts       # Project-level build configuration
├── settings.gradle.kts    # Gradle settings
├── PROJECT_PLAN.md        # Detailed project roadmap
├── IMPLEMENTATION.md      # Implementation details
└── README.md             # This file
```

## Documentation

- **[PROJECT_PLAN.md](PROJECT_PLAN.md)**: Complete project roadmap and feature list
- **[IMPLEMENTATION.md](IMPLEMENTATION.md)**: Technical implementation details for the scanner feature

## Contributing

1. Check PROJECT_PLAN.md for uncompleted tasks
2. Create a feature branch
3. Implement the feature with tests
4. Submit a pull request
5. Update PROJECT_PLAN.md marking task as complete

## License

Internal use only.
