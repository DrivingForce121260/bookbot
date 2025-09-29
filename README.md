# BookBot - Intelligente Leseassistentin

BookBot ist eine mobile App für Tablets und Smartphones, die Lesern hilft, den Überblick über ihre Bücher zu behalten und intelligente Zusammenfassungen zu erstellen.

## 🚀 Funktionen

- **Buchverwaltung**: Bücher hinzufügen, bearbeiten und verwalten
- **Fortschrittsverfolgung**: Aktuelle Seitenzahl speichern und Fortschritt verfolgen
- **KI-Zusammenfassungen**: Intelligente Zusammenfassungen der Geschichte bis zu einer bestimmten Seite
- **Moderne UI**: Optimiert für Tablets und Smartphones
- **Offline-Funktionalität**: Lokale Datenspeicherung mit SQLite

## 📱 Verwendung

1. **Buch hinzufügen**: Fügen Sie ein neues Buch mit Titel, Autor und Gesamtseitenzahl hinzu
2. **Fortschritt verfolgen**: Aktualisieren Sie regelmäßig Ihre aktuelle Seitenzahl
3. **Zusammenfassung erstellen**: Lassen Sie sich eine intelligente Zusammenfassung der Geschichte bis zu einer bestimmten Seite erstellen
4. **Wieder einsteigen**: Nach einer Pause können Sie schnell wieder in die Geschichte einsteigen

## 🛠️ Installation

### Voraussetzungen

- Node.js (Version 16 oder höher)
- Expo CLI
- Expo Go App auf Ihrem mobilen Gerät

### Setup

1. Abhängigkeiten installieren:
```bash
npm install
```

2. App starten:
```bash
npm start
```

3. Expo Go App öffnen und den QR-Code scannen

## 🏗️ Technologie-Stack

- **React Native** mit Expo
- **TypeScript** für Typsicherheit
- **React Navigation** für Navigation
- **React Native Paper** für UI-Komponenten
- **Expo SQLite** für lokale Datenspeicherung
- **Expo Linear Gradient** für moderne UI-Effekte

## 📁 Projektstruktur

```
src/
├── screens/           # App-Bildschirme
│   ├── HomeScreen.tsx
│   ├── BooksScreen.tsx
│   ├── AddBookScreen.tsx
│   ├── BookDetailScreen.tsx
│   └── SummaryScreen.tsx
├── database/          # Datenbanklogik
│   └── database.ts
└── styles/           # Design-System
    └── theme.ts
```

## 🔮 Zukünftige Erweiterungen

- **Echte KI-Integration**: Anbindung an OpenAI oder andere KI-Services
- **Buchcover-Upload**: Möglichkeit, Buchcover hochzuladen
- **Leseziele**: Tägliche/wöchentliche Leseziele setzen
- **Statistiken**: Detaillierte Lese-Statistiken
- **Cloud-Sync**: Synchronisation zwischen Geräten
- **Buchsuche**: Integration von Buchdatenbanken (ISBN-Suche)

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz.

## 🤝 Beitragen

Beiträge sind willkommen! Bitte erstellen Sie einen Pull Request oder öffnen Sie ein Issue für Verbesserungsvorschläge.

