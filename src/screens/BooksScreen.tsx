import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Text, Card, Button, ActivityIndicator, Chip, FAB } from 'react-native-paper';
import { Book, getAllBooks, deleteBook } from '../database/database';

export default function BooksScreen({ navigation }: any) {
  const [books, setBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadBooks();
  }, []);

  const loadBooks = async () => {
    try {
      const allBooks = await getAllBooks();
      setBooks(allBooks);
    } catch (error) {
      console.error('Fehler beim Laden der Bücher:', error);
      Alert.alert('Fehler', 'Bücher konnten nicht geladen werden');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteBook = (book: Book) => {
    Alert.alert(
      'Buch löschen',
      `Möchten Sie "${book.title}" wirklich löschen?`,
      [
        { text: 'Abbrechen', style: 'cancel' },
        {
          text: 'Löschen',
          style: 'destructive',
          onPress: async () => {
            try {
              await deleteBook(book.id);
              await loadBooks();
              Alert.alert('Erfolg', 'Buch wurde gelöscht');
            } catch (error) {
              Alert.alert('Fehler', 'Buch konnte nicht gelöscht werden');
            }
          },
        },
      ]
    );
  };

  const getProgressPercentage = (book: Book) => {
    return book.currentPage / book.totalPages;
  };

  const getProgressColor = (percentage: number) => {
    if (percentage < 0.3) return '#ef4444';
    if (percentage < 0.7) return '#f59e0b';
    return '#10b981';
  };

  const getProgressStatus = (percentage: number) => {
    if (percentage === 0) return 'Nicht begonnen';
    if (percentage < 0.1) return 'Gerade begonnen';
    if (percentage < 0.5) return 'In Bearbeitung';
    if (percentage < 0.9) return 'Fast fertig';
    if (percentage < 1) return 'Fast abgeschlossen';
    return 'Abgeschlossen';
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" />
        <Text style={styles.loadingText}>Lade Bücher...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.content}>
          {books.length === 0 ? (
            <Card style={styles.emptyCard}>
              <Card.Content style={styles.emptyContent}>
                <Text style={styles.emptyTitle}>📚 Keine Bücher vorhanden</Text>
                <Text style={styles.emptyText}>
                  Fügen Sie Ihr erstes Buch hinzu, um loszulegen!
                </Text>
                <Button
                  mode="contained"
                  onPress={() => navigation.navigate('AddBook')}
                  style={styles.addFirstButton}
                  icon="plus"
                >
                  Erstes Buch hinzufügen
                </Button>
              </Card.Content>
            </Card>
          ) : (
            <View style={styles.booksList}>
              {books.map((book) => {
                const progress = getProgressPercentage(book);
                const status = getProgressStatus(progress);
                
                return (
                  <Card key={book.id} style={styles.bookCard}>
                    <Card.Content>
                      <View style={styles.bookHeader}>
                        <View style={styles.bookInfo}>
                          <Text style={styles.bookTitle}>{book.title}</Text>
                          <Text style={styles.bookAuthor}>von {book.author}</Text>
                          {book.isbn && (
                            <Text style={styles.bookIsbn}>ISBN: {book.isbn}</Text>
                          )}
                        </View>
                        <Chip
                          mode="outlined"
                          style={[styles.statusChip, { backgroundColor: getProgressColor(progress) + '20' }]}
                          textStyle={{ color: getProgressColor(progress) }}
                        >
                          {status}
                        </Chip>
                      </View>

                      <View style={styles.progressSection}>
                        <View style={styles.progressInfo}>
                          <Text style={styles.progressText}>
                            {book.currentPage} von {book.totalPages} Seiten
                          </Text>
                          <Text style={styles.progressPercentage}>
                            {Math.round(progress * 100)}%
                          </Text>
                        </View>
                        
                        <View style={styles.progressBar}>
                          <View 
                            style={[
                              styles.progressFill, 
                              { 
                                width: `${progress * 100}%`,
                                backgroundColor: getProgressColor(progress)
                              }
                            ]} 
                          />
                        </View>
                      </View>

                      <View style={styles.bookActions}>
                        <Button
                          mode="outlined"
                          onPress={() => navigation.navigate('BookDetail', { bookId: book.id })}
                          style={styles.actionButton}
                          icon="book-open"
                          compact
                        >
                          Details
                        </Button>
                        <Button
                          mode="contained"
                          onPress={() => navigation.navigate('Summary', { bookId: book.id })}
                          style={styles.actionButton}
                          icon="text-box"
                          compact
                        >
                          Zusammenfassung
                        </Button>
                        <Button
                          mode="outlined"
                          onPress={() => handleDeleteBook(book)}
                          style={styles.deleteButton}
                          icon="delete"
                          compact
                          textColor="#ef4444"
                        >
                          Löschen
                        </Button>
                      </View>
                    </Card.Content>
                  </Card>
                );
              })}
            </View>
          )}
        </View>
      </ScrollView>
      
      <FAB
        icon="plus"
        style={styles.fab}
        onPress={() => navigation.navigate('AddBook')}
        label="Buch hinzufügen"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  scrollView: {
    flex: 1,
  },
  content: {
    padding: 16,
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
  emptyCard: {
    elevation: 2,
    marginTop: 32,
  },
  emptyContent: {
    alignItems: 'center',
    padding: 32,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 8,
    textAlign: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: '#6b7280',
    textAlign: 'center',
    marginBottom: 24,
    lineHeight: 24,
  },
  addFirstButton: {
    marginTop: 8,
  },
  booksList: {
    gap: 16,
  },
  bookCard: {
    elevation: 2,
  },
  bookHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 16,
  },
  bookInfo: {
    flex: 1,
    marginRight: 8,
  },
  bookTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 4,
  },
  bookAuthor: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 4,
  },
  bookIsbn: {
    fontSize: 12,
    color: '#9ca3af',
  },
  statusChip: {
    alignSelf: 'flex-start',
  },
  progressSection: {
    marginBottom: 16,
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
    backgroundColor: '#e5e7eb',
    borderRadius: 4,
  },
  progressFill: {
    height: '100%',
    borderRadius: 4,
  },
  bookActions: {
    flexDirection: 'row',
    gap: 8,
    flexWrap: 'wrap',
  },
  actionButton: {
    flex: 1,
    minWidth: 100,
  },
  deleteButton: {
    flex: 1,
    minWidth: 100,
    borderColor: '#ef4444',
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
  },
});