import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Text, TextInput, Button, Card, Chip, ProgressBar, IconButton } from 'react-native-paper';
import { Book, getAllBooks, updateBookProgress, deleteBook } from '../database/database';

export default function BookDetailScreen({ navigation, route }: any) {
  const { bookId } = route.params;
  const [book, setBook] = useState<Book | null>(null);
  const [currentPage, setCurrentPage] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    loadBook();
  }, [bookId]);

  const loadBook = async () => {
    try {
      const books = await getAllBooks();
      const foundBook = books.find(b => b.id === bookId);
      if (foundBook) {
        setBook(foundBook);
        setCurrentPage(foundBook.currentPage.toString());
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

  const handleUpdateProgress = async () => {
    const newPage = Number(currentPage);
    
    if (isNaN(newPage) || newPage < 0 || newPage > book!.totalPages) {
      Alert.alert('Fehler', 'Bitte geben Sie eine gültige Seitenzahl ein');
      return;
    }

    setSaving(true);
    try {
      await updateBookProgress(bookId, newPage);
      await loadBook();
      Alert.alert('Erfolg', 'Fortschritt wurde aktualisiert');
    } catch (error) {
      console.error('Fehler beim Aktualisieren:', error);
      Alert.alert('Fehler', 'Fortschritt konnte nicht aktualisiert werden');
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteBook = () => {
    Alert.alert(
      'Buch löschen',
      `Möchten Sie "${book?.title}" wirklich löschen?`,
      [
        { text: 'Abbrechen', style: 'cancel' },
        {
          text: 'Löschen',
          style: 'destructive',
          onPress: async () => {
            try {
              await deleteBook(bookId);
              navigation.navigate('BooksList');
            } catch (error) {
              Alert.alert('Fehler', 'Buch konnte nicht gelöscht werden');
            }
          },
        },
      ]
    );
  };

  const getProgressPercentage = () => {
    if (!book) return 0;
    return book.currentPage / book.totalPages;
  };

  const getProgressColor = (percentage: number) => {
    if (percentage < 0.3) return '#ef4444';
    if (percentage < 0.7) return '#f59e0b';
    return '#10b981';
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <Text>Lade Buchdetails...</Text>
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
            <View style={styles.header}>
              <View style={styles.bookInfo}>
                <Text style={styles.title}>{book.title}</Text>
                <Text style={styles.author}>von {book.author}</Text>
              </View>
              <IconButton
                icon="delete"
                size={24}
                onPress={handleDeleteBook}
                iconColor="#ef4444"
              />
            </View>

            {book.isbn && (
              <Chip
                mode="outlined"
                style={styles.chip}
                icon="barcode"
              >
                ISBN: {book.isbn}
              </Chip>
            )}

            <View style={styles.progressSection}>
              <Text style={styles.sectionTitle}>Lese-Fortschritt</Text>
              
              <View style={styles.progressInfo}>
                <Text style={styles.progressText}>
                  {book.currentPage} von {book.totalPages} Seiten gelesen
                </Text>
                <Text style={styles.progressPercentage}>
                  {Math.round(getProgressPercentage() * 100)}%
                </Text>
              </View>

              <ProgressBar
                progress={getProgressPercentage()}
                color={getProgressColor(getProgressPercentage())}
                style={styles.progressBar}
              />
            </View>

            <View style={styles.updateSection}>
              <Text style={styles.sectionTitle}>Fortschritt aktualisieren</Text>
              
              <TextInput
                label="Aktuelle Seite"
                value={currentPage}
                onChangeText={setCurrentPage}
                style={styles.input}
                mode="outlined"
                keyboardType="numeric"
                placeholder={`0-${book.totalPages}`}
              />
              
              <Button
                mode="contained"
                onPress={handleUpdateProgress}
                style={styles.updateButton}
                loading={saving}
                disabled={saving}
                icon="update"
              >
                Fortschritt speichern
              </Button>
            </View>

            <View style={styles.actionsSection}>
              <Text style={styles.sectionTitle}>Aktionen</Text>
              
              <View style={styles.actionButtons}>
                <Button
                  mode="outlined"
                  onPress={() => navigation.navigate('Summary', { bookId: book.id })}
                  style={styles.actionButton}
                  icon="text-box"
                >
                  Zusammenfassung erstellen
                </Button>
              </View>
            </View>
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
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  bookCard: {
    elevation: 4,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 16,
  },
  bookInfo: {
    flex: 1,
    marginRight: 8,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 4,
  },
  author: {
    fontSize: 16,
    color: '#6b7280',
  },
  chip: {
    alignSelf: 'flex-start',
    marginBottom: 24,
  },
  progressSection: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 12,
  },
  progressInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  progressText: {
    fontSize: 14,
    color: '#6b7280',
  },
  progressPercentage: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#1e293b',
  },
  progressBar: {
    height: 8,
    borderRadius: 4,
  },
  updateSection: {
    marginBottom: 24,
  },
  input: {
    marginBottom: 16,
  },
  updateButton: {
    marginTop: 8,
  },
  actionsSection: {
    marginBottom: 16,
  },
  actionButtons: {
    gap: 12,
  },
  actionButton: {
    marginTop: 8,
  },
});
