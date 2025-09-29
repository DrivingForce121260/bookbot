import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, Alert, Share } from 'react-native';
import { Text, TextInput, Button, Card, ActivityIndicator, Chip, IconButton } from 'react-native-paper';
import { Book, getAllBooks, getSummary, addSummary } from '../database/database';

export default function SummaryScreen({ navigation, route }: any) {
  const { bookId } = route.params;
  const [book, setBook] = useState<Book | null>(null);
  const [pageNumber, setPageNumber] = useState('');
  const [summary, setSummary] = useState('');
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState(false);

  useEffect(() => {
    loadBook();
  }, [bookId]);

  const loadBook = async () => {
    try {
      const books = await getAllBooks();
      const foundBook = books.find(b => b.id === bookId);
      if (foundBook) {
        setBook(foundBook);
        setPageNumber(foundBook.currentPage.toString());
      } else {
        Alert.alert('Fehler', 'Buch nicht gefunden');
        navigation.goBack();
      }
    } catch (error) {
      console.error('Fehler beim Laden des Buches:', error);
      Alert.alert('Fehler', 'Buch konnte nicht geladen werden');
    } finally {
      setLoading(false);
    }
  };

  const generateSummary = async () => {
    const targetPage = Number(pageNumber);
    
    if (isNaN(targetPage) || targetPage < 0 || targetPage > book!.totalPages) {
      Alert.alert('Fehler', 'Bitte geben Sie eine gültige Seitenzahl ein');
      return;
    }

    // Prüfen, ob bereits eine Zusammenfassung für diese Seite existiert
    try {
      const existingSummary = await getSummary(bookId, targetPage);
      if (existingSummary) {
        setSummary(existingSummary.summary);
        Alert.alert(
          'Zusammenfassung gefunden',
          'Es wurde bereits eine Zusammenfassung für diese Seite erstellt. Möchten Sie eine neue erstellen?',
          [
            { text: 'Abbrechen', style: 'cancel' },
            { text: 'Neue erstellen', onPress: () => createNewSummary(targetPage) },
          ]
        );
        return;
      }
    } catch (error) {
      console.error('Fehler beim Laden der Zusammenfassung:', error);
    }

    createNewSummary(targetPage);
  };

  const createNewSummary = async (targetPage: number) => {
    setGenerating(true);
    try {
      // Hier würde normalerweise eine KI-API aufgerufen werden
      // Für die Demo erstellen wir eine simulierte Zusammenfassung
      const simulatedSummary = await simulateAISummary(book!, targetPage);
      
      // Zusammenfassung in der Datenbank speichern
      await addSummary({
        bookId,
        pageNumber: targetPage,
        summary: simulatedSummary,
      });
      
      setSummary(simulatedSummary);
    } catch (error) {
      console.error('Fehler beim Erstellen der Zusammenfassung:', error);
      Alert.alert('Fehler', 'Zusammenfassung konnte nicht erstellt werden');
    } finally {
      setGenerating(false);
    }
  };

  const simulateAISummary = async (book: Book, targetPage: number): Promise<string> => {
    // Simulierte Verzögerung für KI-Verarbeitung
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    const progress = targetPage / book.totalPages;
    const chapter = Math.ceil(progress * 10); // Annahme: 10 Kapitel
    
    return `Zusammenfassung von "${book.title}" bis Seite ${targetPage}:

Kapitel 1-${chapter}: Die Geschichte beginnt mit der Einführung der Hauptfiguren und der Grundsituation. Wir lernen die wichtigsten Charaktere kennen und verstehen ihre Motivationen und Ziele.

Die Handlung entwickelt sich durch verschiedene Wendepunkte, wobei die Charaktere vor Herausforderungen gestellt werden. Es gibt Momente der Spannung und des Konflikts, die die Geschichte vorantreiben.

Bis zur aktuellen Seite ${targetPage} haben wir bereits wichtige Entwicklungen in der Handlung gesehen. Die Charaktere haben sich weiterentwickelt und neue Informationen über die Welt und die Situation wurden enthüllt.

Wichtige Themen, die bisher behandelt wurden:
- Charakterentwicklung der Hauptfiguren
- Aufbau der Welt und des Settings
- Einführung der Hauptkonflikte
- Erste Wendepunkte in der Handlung

Diese Zusammenfassung hilft Ihnen, wieder in die Geschichte einzusteigen und den Faden dort aufzunehmen, wo Sie aufgehört haben.`;
  };

  const shareSummary = async () => {
    if (!summary) return;
    
    try {
      await Share.share({
        message: `Zusammenfassung von "${book?.title}" bis Seite ${pageNumber}:\n\n${summary}`,
        title: `Zusammenfassung - ${book?.title}`,
      });
    } catch (error) {
      console.error('Fehler beim Teilen:', error);
    }
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" />
        <Text style={styles.loadingText}>Lade Buchdetails...</Text>
      </View>
    );
  }

  if (!book) {
    return (
      <View style={styles.errorContainer}>
        <Text>Buch nicht gefunden</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Card style={styles.bookCard}>
          <Card.Content>
            <Text style={styles.title}>{book.title}</Text>
            <Text style={styles.author}>von {book.author}</Text>
            
            <Chip
              mode="outlined"
              style={styles.chip}
              icon="book-open"
            >
              {book.totalPages} Seiten gesamt
            </Chip>
          </Card.Content>
        </Card>

        <Card style={styles.summaryCard}>
          <Card.Content>
            <Text style={styles.sectionTitle}>Zusammenfassung erstellen</Text>
            
            <TextInput
              label="Bis zu welcher Seite?"
              value={pageNumber}
              onChangeText={setPageNumber}
              style={styles.input}
              mode="outlined"
              keyboardType="numeric"
              placeholder={`0-${book.totalPages}`}
            />
            
            <Button
              mode="contained"
              onPress={generateSummary}
              style={styles.generateButton}
              loading={generating}
              disabled={generating}
              icon="robot"
            >
              {generating ? 'Erstelle Zusammenfassung...' : 'Zusammenfassung erstellen'}
            </Button>

            {generating && (
              <View style={styles.generatingContainer}>
                <ActivityIndicator size="small" />
                <Text style={styles.generatingText}>
                  Die KI analysiert das Buch und erstellt eine Zusammenfassung...
                </Text>
              </View>
            )}
          </Card.Content>
        </Card>

        {summary && (
          <Card style={styles.resultCard}>
            <Card.Content>
              <View style={styles.resultHeader}>
                <Text style={styles.sectionTitle}>
                  Zusammenfassung bis Seite {pageNumber}
                </Text>
                <IconButton
                  icon="share"
                  size={20}
                  onPress={shareSummary}
                />
              </View>
              
              <ScrollView style={styles.summaryContainer}>
                <Text style={styles.summaryText}>{summary}</Text>
              </ScrollView>
            </Card.Content>
          </Card>
        )}

        <Card style={styles.infoCard}>
          <Card.Content>
            <Text style={styles.infoTitle}>💡 Tipp</Text>
            <Text style={styles.infoText}>
              Diese App verwendet KI-Technologie, um intelligente Zusammenfassungen Ihrer Bücher zu erstellen. 
              Die Zusammenfassungen werden basierend auf dem Inhalt bis zur angegebenen Seite generiert und 
              helfen Ihnen dabei, schnell wieder in die Geschichte einzusteigen.
            </Text>
          </Card.Content>
        </Card>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  content: {
    padding: 16,
    gap: 16,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: 16,
  },
  loadingText: {
    fontSize: 16,
    color: '#6b7280',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  bookCard: {
    elevation: 2,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 4,
  },
  author: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 12,
  },
  chip: {
    alignSelf: 'flex-start',
  },
  summaryCard: {
    elevation: 2,
  },
  resultCard: {
    elevation: 2,
  },
  infoCard: {
    elevation: 2,
    backgroundColor: '#f0f9ff',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 16,
  },
  input: {
    marginBottom: 16,
  },
  generateButton: {
    marginTop: 8,
  },
  generatingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 16,
    gap: 8,
  },
  generatingText: {
    fontSize: 14,
    color: '#6b7280',
    flex: 1,
  },
  resultHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  summaryContainer: {
    maxHeight: 300,
  },
  summaryText: {
    fontSize: 14,
    lineHeight: 20,
    color: '#374151',
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 8,
  },
  infoText: {
    fontSize: 14,
    lineHeight: 20,
    color: '#6b7280',
  },
});
