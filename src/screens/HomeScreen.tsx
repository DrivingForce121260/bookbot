import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Text, Card, Button, ActivityIndicator, Chip } from 'react-native-paper';
import { Book, getAllBooks } from '../database/database';

export default function HomeScreen({ navigation }: any) {
  const [recentBooks, setRecentBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadRecentBooks();
  }, []);

  const loadRecentBooks = async () => {
    try {
      const books = await getAllBooks();
      // Zeige die 3 neuesten Bücher
      setRecentBooks(books.slice(0, 3));
    } catch (error) {
      console.error('Fehler beim Laden der Bücher:', error);
    } finally {
      setLoading(false);
    }
  };

  const getProgressPercentage = (book: Book) => {
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
        <ActivityIndicator size="large" />
        <Text style={styles.loadingText}>Lade Daten...</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Card style={styles.welcomeCard}>
          <Card.Content>
            <Text style={styles.welcomeTitle}>📚 Willkommen bei BookBot!</Text>
            <Text style={styles.welcomeText}>
              Verfolgen Sie Ihren Lesefortschritt und erhalten Sie intelligente Zusammenfassungen Ihrer Bücher.
            </Text>
          </Card.Content>
        </Card>

        <Card style={styles.quickActionsCard}>
          <Card.Content>
            <Text style={styles.sectionTitle}>Schnellaktionen</Text>
            <View style={styles.actionButtons}>
              <Button
                mode="contained"
                onPress={() => navigation.navigate('Books', { screen: 'AddBook' })}
                style={styles.actionButton}
                icon="plus"
              >
                Buch hinzufügen
              </Button>
              <Button
                mode="outlined"
                onPress={() => navigation.navigate('Books')}
                style={styles.actionButton}
                icon="library"
              >
                Alle Bücher
              </Button>
            </View>
          </Card.Content>
        </Card>

        <Card style={styles.recentBooksCard}>
          <Card.Content>
            <Text style={styles.sectionTitle}>Letzte Bücher</Text>
            {recentBooks.length === 0 ? (
              <View style={styles.emptyState}>
                <Text style={styles.emptyText}>Noch keine Bücher hinzugefügt</Text>
                <Text style={styles.emptySubtext}>
                  Fügen Sie Ihr erstes Buch hinzu, um loszulegen!
                </Text>
              </View>
            ) : (
              <View style={styles.booksList}>
                {recentBooks.map((book) => {
                  const progress = getProgressPercentage(book);
                  return (
                    <Card key={book.id} style={styles.bookCard}>
                      <Card.Content>
                        <View style={styles.bookHeader}>
                          <View style={styles.bookInfo}>
                            <Text style={styles.bookTitle}>{book.title}</Text>
                            <Text style={styles.bookAuthor}>von {book.author}</Text>
                          </View>
                          <Chip
                            mode="outlined"
                            style={[styles.progressChip, { backgroundColor: getProgressColor(progress) + '20' }]}
                            textStyle={{ color: getProgressColor(progress) }}
                          >
                            {Math.round(progress * 100)}%
                          </Chip>
                        </View>
                        
                        <View style={styles.progressContainer}>
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
                          <Text style={styles.progressText}>
                            {book.currentPage} / {book.totalPages} Seiten
                          </Text>
                        </View>

                        <View style={styles.bookActions}>
                          <Button
                            mode="outlined"
                            onPress={() => navigation.navigate('Books', { 
                              screen: 'BookDetail', 
                              params: { bookId: book.id } 
                            })}
                            style={styles.detailButton}
                            compact
                          >
                            Details
                          </Button>
                          <Button
                            mode="contained"
                            onPress={() => navigation.navigate('Books', { 
                              screen: 'Summary', 
                              params: { bookId: book.id } 
                            })}
                            style={styles.summaryButton}
                            compact
                          >
                            Zusammenfassung
                          </Button>
                        </View>
                      </Card.Content>
                    </Card>
                  );
                })}
              </View>
            )}
          </Card.Content>
        </Card>

        <Card style={styles.infoCard}>
          <Card.Content>
            <Text style={styles.infoTitle}>💡 Tipp</Text>
            <Text style={styles.infoText}>
              BookBot hilft Ihnen dabei, den Überblick über Ihre Bücher zu behalten. 
              Fügen Sie Bücher hinzu, verfolgen Sie Ihren Fortschritt und lassen Sie sich 
              intelligente Zusammenfassungen erstellen, um schnell wieder in die Geschichte einzusteigen.
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
  welcomeCard: {
    elevation: 2,
    backgroundColor: '#e0e7ff',
  },
  welcomeTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 8,
    textAlign: 'center',
  },
  welcomeText: {
    fontSize: 16,
    color: '#475569',
    textAlign: 'center',
    lineHeight: 24,
  },
  quickActionsCard: {
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 16,
  },
  actionButtons: {
    flexDirection: 'row',
    gap: 12,
  },
  actionButton: {
    flex: 1,
  },
  recentBooksCard: {
    elevation: 2,
  },
  emptyState: {
    alignItems: 'center',
    padding: 32,
  },
  emptyText: {
    fontSize: 16,
    color: '#6b7280',
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#9ca3af',
    textAlign: 'center',
  },
  booksList: {
    gap: 12,
  },
  bookCard: {
    elevation: 1,
  },
  bookHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  bookInfo: {
    flex: 1,
    marginRight: 8,
  },
  bookTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 4,
  },
  bookAuthor: {
    fontSize: 14,
    color: '#6b7280',
  },
  progressChip: {
    alignSelf: 'flex-start',
  },
  progressContainer: {
    marginBottom: 16,
  },
  progressBar: {
    height: 6,
    backgroundColor: '#e5e7eb',
    borderRadius: 3,
    marginBottom: 8,
  },
  progressFill: {
    height: '100%',
    borderRadius: 3,
  },
  progressText: {
    fontSize: 12,
    color: '#6b7280',
  },
  bookActions: {
    flexDirection: 'row',
    gap: 8,
  },
  detailButton: {
    flex: 1,
  },
  summaryButton: {
    flex: 1,
  },
  infoCard: {
    elevation: 2,
    backgroundColor: '#f0f9ff',
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