# BookBot APK erstellen - Anleitung

## 🚀 APK erstellen mit Expo Application Services (EAS)

### Schritt 1: Expo Account erstellen
1. Gehen Sie zu: https://expo.dev
2. Erstellen Sie einen kostenlosen Account
3. Melden Sie sich an

### Schritt 2: EAS CLI installieren
```bash
npm install -g @expo/cli
```

### Schritt 3: Bei Expo anmelden
```bash
npx expo login
```

### Schritt 4: APK erstellen
```bash
npx eas build --platform android
```

## 🎯 Alternative: APK über Web-Interface erstellen

### Schritt 1: Projekt hochladen
1. Gehen Sie zu: https://expo.dev
2. Klicken Sie auf "New Project"
3. Laden Sie den BookBot-Ordner hoch

### Schritt 2: Build starten
1. Wählen Sie "Android" als Platform
2. Klicken Sie auf "Build"
3. Warten Sie auf den Download-Link

## 📱 APK installieren

### Schritt 1: APK herunterladen
- Die APK-Datei wird als Download-Link bereitgestellt
- Laden Sie die Datei auf Ihren Computer herunter

### Schritt 2: Auf Android-Gerät installieren
1. Aktivieren Sie "Unbekannte Quellen" in den Android-Einstellungen
2. Übertragen Sie die APK-Datei auf Ihr Android-Gerät
3. Tippen Sie auf die APK-Datei zum Installieren

## 🔧 Lokale APK-Erstellung (Erweitert)

Falls Sie Android Studio installiert haben:

### Schritt 1: Android Studio konfigurieren
1. Installieren Sie Android Studio
2. Konfigurieren Sie das Android SDK
3. Erstellen Sie einen Android Virtual Device (AVD)

### Schritt 2: APK erstellen
```bash
npx expo run:android --variant release
```

## 💡 Empfehlung

Die einfachste Methode ist die **Web-Interface-Methode**:
1. Gehen Sie zu https://expo.dev
2. Erstellen Sie einen Account
3. Laden Sie das Projekt hoch
4. Erstellen Sie eine APK

Die APK wird dann automatisch erstellt und Sie erhalten einen Download-Link!



