import { initDatabase } from '../database/database';

export const initializeApp = async () => {
  try {
    // Datenbank initialisieren
    initDatabase();
    console.log('App erfolgreich initialisiert');
  } catch (error) {
    console.error('Fehler bei der App-Initialisierung:', error);
    throw error;
  }
};
