import * as SQLite from 'expo-sqlite';

const db = SQLite.openDatabase('bookbot.db');

export interface Book {
  id: number;
  title: string;
  author: string;
  totalPages: number;
  currentPage: number;
  isbn?: string;
  coverImage?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Summary {
  id: number;
  bookId: number;
  pageNumber: number;
  summary: string;
  createdAt: string;
}

export const initDatabase = () => {
  db.transaction(tx => {
    // Bücher-Tabelle
    tx.executeSql(
      `CREATE TABLE IF NOT EXISTS books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        totalPages INTEGER NOT NULL,
        currentPage INTEGER DEFAULT 0,
        isbn TEXT,
        coverImage TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      );`
    );

    // Zusammenfassungen-Tabelle
    tx.executeSql(
      `CREATE TABLE IF NOT EXISTS summaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER NOT NULL,
        pageNumber INTEGER NOT NULL,
        summary TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      );`
    );
  });
};

export const addBook = (book: Omit<Book, 'id' | 'createdAt' | 'updatedAt'>): Promise<number> => {
  return new Promise((resolve, reject) => {
    const now = new Date().toISOString();
    db.transaction(tx => {
      tx.executeSql(
        'INSERT INTO books (title, author, totalPages, currentPage, isbn, coverImage, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [book.title, book.author, book.totalPages, book.currentPage || 0, book.isbn || '', book.coverImage || '', now, now],
        (_, result) => resolve(result.insertId!),
        (_, error) => {
          reject(error);
          return false;
        }
      );
    });
  });
};

export const getAllBooks = (): Promise<Book[]> => {
  return new Promise((resolve, reject) => {
    db.transaction(tx => {
      tx.executeSql(
        'SELECT * FROM books ORDER BY updatedAt DESC',
        [],
        (_, result) => {
          const books: Book[] = [];
          for (let i = 0; i < result.rows.length; i++) {
            books.push(result.rows.item(i));
          }
          resolve(books);
        },
        (_, error) => {
          reject(error);
          return false;
        }
      );
    });
  });
};

export const updateBookProgress = (id: number, currentPage: number): Promise<void> => {
  return new Promise((resolve, reject) => {
    const now = new Date().toISOString();
    db.transaction(tx => {
      tx.executeSql(
        'UPDATE books SET currentPage = ?, updatedAt = ? WHERE id = ?',
        [currentPage, now, id],
        () => resolve(),
        (_, error) => {
          reject(error);
          return false;
        }
      );
    });
  });
};

export const deleteBook = (id: number): Promise<void> => {
  return new Promise((resolve, reject) => {
    db.transaction(tx => {
      tx.executeSql(
        'DELETE FROM books WHERE id = ?',
        [id],
        () => resolve(),
        (_, error) => {
          reject(error);
          return false;
        }
      );
    });
  });
};

export const addSummary = (summary: Omit<Summary, 'id' | 'createdAt'>): Promise<number> => {
  return new Promise((resolve, reject) => {
    const now = new Date().toISOString();
    db.transaction(tx => {
      tx.executeSql(
        'INSERT INTO summaries (bookId, pageNumber, summary, createdAt) VALUES (?, ?, ?, ?)',
        [summary.bookId, summary.pageNumber, summary.summary, now],
        (_, result) => resolve(result.insertId!),
        (_, error) => {
          reject(error);
          return false;
        }
      );
    });
  });
};

export const getSummary = (bookId: number, pageNumber: number): Promise<Summary | null> => {
  return new Promise((resolve, reject) => {
    db.transaction(tx => {
      tx.executeSql(
        'SELECT * FROM summaries WHERE bookId = ? AND pageNumber = ? ORDER BY createdAt DESC LIMIT 1',
        [bookId, pageNumber],
        (_, result) => {
          if (result.rows.length > 0) {
            resolve(result.rows.item(0));
          } else {
            resolve(null);
          }
        },
        (_, error) => {
          reject(error);
          return false;
        }
      );
    });
  });
};

