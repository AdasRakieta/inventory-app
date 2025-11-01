# 🔐 Budowanie i Wdrażanie Wersji Release

## Keystore (Podpis Aplikacji)

### Informacje o Keystore
- **Plik**: `app/inventory-release.keystore`
- **Alias**: `inventory-key`
- **Store Password**: `inventory2024`
- **Key Password**: `inventory2024`
- **Ważność**: 10 000 dni
- **Właściciel**: Szymon Przybysz

⚠️ **WAŻNE**: Ten plik jest już zabezpieczony w `.gitignore` i NIE powinien być dodawany do repozytorium!

### Backup Keystore
**KRYTYCZNE**: Zachowaj kopię keystore w bezpiecznym miejscu! Bez tego pliku nie będziesz mógł:
- Aktualizować aplikacji w Google Play
- Wydawać nowych wersji z tym samym podpisem
- Utrzymać ciągłości instalacji aplikacji

## 🚀 Polecenia Gradle

### Budowanie Release

```powershell
# Zbuduj podpisany APK release
.\gradlew.bat assembleRelease

# APK będzie w: app\build\outputs\apk\release\app-release.apk
```

### Instalacja na Urządzeniu (przez kabel ADB)

```powershell
# Sprawdź podłączone urządzenia
adb devices

# Zainstaluj release APK
adb install -r app\build\outputs\apk\release\app-release.apk

# Uruchom aplikację
adb shell am start -n com.inventory.prd/com.example.inventoryapp.ui.main.SplashActivity
```

### Niestandardowe Zadania Gradle

```powershell
# Zbuduj, zainstaluj i uruchom release (wszystko w jednym)
.\gradlew.bat deployRelease

# Szybkie wdrożenie release (bez clean)
.\gradlew.bat quickDeployRelease

# Zbuduj, zainstaluj i uruchom debug
.\gradlew.bat deployDebug

# Szybkie wdrożenie debug (bez clean)
.\gradlew.bat quickDeploy

# Tylko uruchom aplikację (bez budowania)
.\gradlew.bat runOnDevice
```

## 📋 Weryfikacja Instalacji

```powershell
# Sprawdź wersję zainstalowanej aplikacji
adb shell dumpsys package com.inventory.prd | Select-String -Pattern "versionName|versionCode"

# Sprawdź podpis aplikacji
adb shell dumpsys package com.inventory.prd | Select-String -Pattern "signatures"
```

## 🔄 Różnice między Debug a Release

| Aspekt | Debug | Release |
|--------|-------|---------|
| **ApplicationId** | `com.inventory.prd` | `com.inventory.prd` |
| **Podpis** | Debug (automatyczny) | Release (`inventory-release.keystore`) |
| **Minifikacja** | Wyłączona | Wyłączona |
| **Instalacja równoległa** | Nie (ten sam applicationId) | Nie (ten sam applicationId) |

## 🛠️ Zmiana Hasła Keystore (opcjonalnie)

Jeśli chcesz zmienić hasła keystore:

```powershell
# Zmień hasło store
& "C:\Tools\jdk-11.0.28+6\bin\keytool.exe" -storepasswd -keystore app\inventory-release.keystore

# Zmień hasło klucza
& "C:\Tools\jdk-11.0.28+6\bin\keytool.exe" -keypasswd -alias inventory-key -keystore app\inventory-release.keystore
```

Pamiętaj, aby zaktualizować hasła w `app/build.gradle.kts` w sekcji `signingConfigs`!

## 📱 Wdrażanie przez SOTI MobiControl

1. Zbuduj APK release: `.\gradlew.bat assembleRelease`
2. Przejdź do: `app\build\outputs\apk\release\`
3. Upload `app-release.apk` do SOTI
4. Aplikacja powinna instalować się z podpisem release

## 🐛 Troubleshooting

### "Signatures do not match"
- Deinstaluj starą wersję: `adb uninstall com.inventory.prd`
- Zainstaluj ponownie: `adb install app\build\outputs\apk\release\app-release.apk`

### "INSTALL_FAILED_UPDATE_INCOMPATIBLE"
- Oznacza konflikt podpisów między debug a release
- Rozwiązanie: deinstaluj wszystkie wersje aplikacji przed instalacją

### Keystore nie działa
- Sprawdź ścieżkę w `build.gradle.kts`: `storeFile = file("inventory-release.keystore")`
- Upewnij się, że plik istnieje: `Test-Path app\inventory-release.keystore`

## 📝 Historia Wersji

- **v1.16.2 (build 79)** - Pierwsza wersja z automatycznym podpisywaniem release w Gradle
