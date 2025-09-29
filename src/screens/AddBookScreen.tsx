import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Text, TextInput, Button, Card, HelperText } from 'react-native-paper';
import { addBook } from '../database/database';

export default function AddBookScreen({ navigation }: any) {
  const [title, setTitle] = useState('');
  const [author, setAuthor] = useState('');
  const [totalPages, setTotalPages] = useState('');
  const [currentPage, setCurrentPage] = useState('');
  const [isbn, setIsbn] = useState('');
  const [loading, setLoading] = useState(false);

  const validateForm = () => {
    if (!title.trim()) {
      Alert.alert('Fehler', 'Bitte geben Sie einen Titel ein');
      return false;
    }
    if (!author.trim()) {
      Alert.alert('Fehler', 'Bitte geben Sie einen Autor ein');
      return false;
    }
    if (!totalPages.trim() || isNaN(Number(totalPages)) || Number(totalPages) <= 0) {
      Alert.alert('Fehler', 'Bitte geben Sie eine gültige Gesamtseitenzahl ein');
      return false;
    }
    const currentPageNum = Number(currentPage) || 0;
    const totalPagesNum = Number(totalPages);
    if (currentPageNum > totalPagesNum) {
      Alert.alert('Fehler', 'Die aktuelle Seite kann nicht größer als die Gesamtseitenzahl sein');
      return false;
    }
    return true;
  };

  const handleSave = async () => {
    if (!validateForm()) return;

    setLoading(true);
    try {
      await addBook({
        title: title.trim(),
        author: author.trim(),
        totalPages: Number(totalPages),
        currentPage: Number(currentPage) || 0,
        isbn: isbn.trim(),
      });

      Alert.alert(
        'Erfolg',
        'Buch wurde erfolgreich hinzugefügt',
        [
          {
            text: 'OK',
            onPress: () => navigation.goBack(),
          },
        ]
      );
    } catch (error) {
      console.error('Fehler beim Hinzufügen des Buches:', error);
      Alert.alert('Fehler', 'Buch konnte nicht hinzugefügt werden');
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Card style={styles.card}>
          <Card.Content>
            <Text style={styles.title}>Neues Buch hinzufügen</Text>
            
            <TextInput
              label="Titel *"
              value={title}
              onChangeText={setTitle}
              style={styles.input}
              mode="outlined"
              placeholder="z.B. Der Herr der Ringe"
            />
            <HelperText type="info">
              Der Titel des Buches
            </HelperText>

            <TextInput
              label="Autor *"
              value={author}
              onChangeText={setAuthor}
              style={styles.input}
              mode="outlined"
              placeholder="z.B. J.R.R. Tolkien"
            />
            <HelperText type="info">
              Der Name des Autors
            </HelperText>

            <TextInput
              label="Gesamtseitenzahl *"
              value={totalPages}
              onChangeText={setTotalPages}
              style={styles.input}
              mode="outlined"
              placeholder="z.B. 423"
              keyboardType="numeric"
            />
            <HelperText type="info">
              Die Gesamtanzahl der Seiten im Buch
            </HelperText>

            <TextInput
              label="Aktuelle Seite"
              value={currentPage}
              onChangeText={setCurrentPage}
              style={styles.input}
              mode="outlined"
              placeholder="z.B. 0 (wenn noch nicht begonnen)"
              keyboardType="numeric"
            />
            <HelperText type="info">
              Auf welcher Seite Sie sich gerade befinden (optional)
            </HelperText>

            <TextInput
              label="ISBN"
              value={isbn}
              onChangeText={setIsbn}
              style={styles.input}
              mode="outlined"
              placeholder="z.B. 978-3-86647-838-0"
            />
            <HelperText type="info">
              Die ISBN-Nummer des Buches (optional)
            </HelperText>

            <View style={styles.buttonContainer}>
              <Button
                mode="outlined"
                onPress={() => navigation.goBack()}
                style={styles.button}
                disabled={loading}
              >
                Abbrechen
              </Button>
              <Button
                mode="contained"
                onPress={handleSave}
                style={styles.button}
                loading={loading}
                disabled={loading}
              >
                Speichern
              </Button>
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
  card: {
    elevation: 4,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 24,
    textAlign: 'center',
  },
  input: {
    marginBottom: 8,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 24,
    gap: 12,
  },
  button: {
    flex: 1,
  },
});
