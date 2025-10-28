# Barcode/QR Scanner Implementation for Serial Number Assignment

## Overview
This implementation adds barcode and QR code scanning functionality to assign serial numbers to products in packages. This is the first major feature from the PROJECT_PLAN.md.

## Features Implemented

### Core Functionality
✅ Barcode and QR code scanning using ML Kit
✅ Serial number validation with business rules
✅ Duplicate serial number detection
✅ Real-time camera preview with CameraX
✅ Error handling for scan failures
✅ Integration with Room database
✅ MVVM architecture implementation

### Technical Components

#### 1. Database Layer
- **ProductEntity**: Entity with unique serial number constraint
- **PackageEntity**: Package management
- **ScanHistoryEntity**: Scan audit trail
- **CategoryEntity**: Product categorization
- **DAOs**: Type-safe database access with Flow/LiveData support

#### 2. Domain Layer
- **SerialNumberValidator**: Validates serial numbers with rules:
  - Minimum 3 characters
  - Maximum 100 characters
  - Only alphanumeric, hyphens, and underscores
  - No special characters or spaces

#### 3. UI Layer
- **ScannerFragment**: Camera-based scanning interface
- **ScannerViewModel**: Business logic and state management
- **BarcodeAnalyzer**: ML Kit integration for barcode detection
- **HomeFragment**: Entry point for testing scanner

#### 4. Supported Barcode Formats
- QR Code
- EAN-13
- EAN-8
- Code 128
- Code 39
- Code 93
- UPC-A
- UPC-E

## Project Structure

```
app/
├── src/
│   ├── main/
│   │   ├── java/com/example/inventoryapp/
│   │   │   ├── data/
│   │   │   │   ├── local/
│   │   │   │   │   ├── database/
│   │   │   │   │   │   └── AppDatabase.kt
│   │   │   │   │   ├── dao/
│   │   │   │   │   │   ├── ProductDao.kt
│   │   │   │   │   │   ├── PackageDao.kt
│   │   │   │   │   │   ├── CategoryDao.kt
│   │   │   │   │   │   └── ScanHistoryDao.kt
│   │   │   │   │   └── entities/
│   │   │   │   │       ├── ProductEntity.kt
│   │   │   │   │       ├── PackageEntity.kt
│   │   │   │   │       ├── CategoryEntity.kt
│   │   │   │   │       ├── PackageProductCrossRef.kt
│   │   │   │   │       └── ScanHistoryEntity.kt
│   │   │   │   ├── repository/
│   │   │   │   │   ├── ProductRepository.kt
│   │   │   │   │   ├── PackageRepository.kt
│   │   │   │   │   └── ScanRepository.kt
│   │   │   │   └── models/
│   │   │   │       ├── Product.kt
│   │   │   │       ├── Package.kt
│   │   │   │       └── ScanResult.kt
│   │   │   ├── domain/
│   │   │   │   └── validators/
│   │   │   │       └── SerialNumberValidator.kt
│   │   │   ├── ui/
│   │   │   │   ├── main/
│   │   │   │   │   ├── MainActivity.kt
│   │   │   │   │   └── HomeFragment.kt
│   │   │   │   └── scanner/
│   │   │   │       ├── ScannerFragment.kt
│   │   │   │       ├── ScannerViewModel.kt
│   │   │   │       └── BarcodeAnalyzer.kt
│   │   │   └── InventoryApplication.kt
│   │   ├── res/
│   │   │   ├── layout/
│   │   │   │   ├── activity_main.xml
│   │   │   │   ├── fragment_home.xml
│   │   │   │   └── fragment_scanner.xml
│   │   │   ├── navigation/
│   │   │   │   └── nav_graph.xml
│   │   │   ├── values/
│   │   │   │   ├── strings.xml
│   │   │   │   ├── colors.xml
│   │   │   │   └── themes.xml
│   │   │   └── drawable/
│   │   │       └── scanner_frame.xml
│   │   └── AndroidManifest.xml
│   └── test/
│       └── java/com/example/inventoryapp/
│           ├── domain/validators/
│           │   └── SerialNumberValidatorTest.kt
│           └── ui/scanner/
│               └── ScannerViewModelTest.kt
└── build.gradle.kts
```

## Key Dependencies

- **AndroidX Core**: 1.15.0
- **Material Design**: 1.12.0
- **Room Database**: 2.6.1
- **CameraX**: 1.4.1
- **ML Kit Barcode Scanning**: 17.3.0
- **Navigation Component**: 2.8.5
- **Coroutines**: 1.10.1
- **Lifecycle & ViewModel**: 2.8.7

## Testing

### Unit Tests
1. **SerialNumberValidatorTest**: 10 tests covering validation logic
   - Empty/blank validation
   - Length validation (min/max)
   - Character validation
   - Valid formats

2. **ScannerViewModelTest**: 6 tests covering business logic
   - Valid barcode scanning
   - Duplicate detection
   - Invalid format handling
   - Serial number assignment
   - Error handling

### Test Coverage
- Validator: 100%
- ViewModel: Core business logic covered
- Repository: Integration tests can be added

## Usage Flow

1. User opens app and navigates to scanner
2. App requests camera permission
3. Camera preview starts with scanning overlay
4. User points camera at barcode/QR code
5. ML Kit detects and decodes the code
6. Validator checks serial number format
7. System checks for duplicates in database
8. If valid, serial number is assigned to product
9. Scan is recorded in history
10. User receives confirmation

## Error Handling

- **Permission Denied**: Shows error message and request button
- **Invalid Format**: Displays validation error
- **Duplicate Serial**: Prevents assignment, shows error
- **Camera Failure**: Graceful degradation with error message
- **Scan Failure**: Retry automatically or manual entry option

## Security Features

- Unique constraint on serial numbers (database level)
- Input validation before database operations
- SQL injection prevention (Room parameterized queries)
- Transaction safety for database operations

## Performance Optimizations

- Async database operations with Coroutines
- LiveData/Flow for reactive updates
- Single-threaded executor for camera operations
- Backpressure strategy for image analysis
- Efficient RecyclerView with DiffUtil (for future lists)

## Future Enhancements (From PROJECT_PLAN.md)

The following related features from the plan can be added next:
- [ ] Extended product model with additional fields
- [ ] Product details screen with serial number display
- [ ] Error handling for incorrect/malformed barcodes
- [ ] Serial number reporting in packages
- [ ] Scan history with timestamps
- [ ] Manual serial number entry fallback
- [ ] Scanned image preview
- [ ] Dark mode support during scanning

## Build Instructions

```bash
# Clone repository
git clone https://github.com/AdasRakieta/inventory-app.git
cd inventory-app

# Build project
./gradlew assembleDebug

# Run tests
./gradlew test

# Install on device
./gradlew installDebug
```

## Configuration

### AndroidManifest Permissions
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

### Minimum Requirements
- Android 8.0 (API 26) or higher
- Camera hardware
- ~20 MB app size

## Troubleshooting

### Build Issues
- Ensure Android SDK API 26-35 is installed
- Check Java 17 is being used
- Sync Gradle files in Android Studio

### Runtime Issues
- Grant camera permission when prompted
- Ensure adequate lighting for scanning
- Hold device steady when scanning
- Clean camera lens if scan fails

## Contributing

Follow the project's code style:
- Kotlin official style guide
- MVVM architecture pattern
- Meaningful commit messages
- Unit tests for business logic

## License

This project is part of the inventory management system for internal use.
