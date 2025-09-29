import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../screens/home_screen.dart';
import '../screens/books_screen.dart';
import '../screens/add_book_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/summary_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/books',
            builder: (context, state) => const BooksScreen(),
          ),
          GoRoute(
            path: '/add-book',
            builder: (context, state) => const AddBookScreen(),
          ),
          GoRoute(
            path: '/book/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return BookDetailScreen(bookId: id);
            },
          ),
          GoRoute(
            path: '/summary/:bookId',
            builder: (context, state) {
              final bookId = int.parse(state.pathParameters['bookId']!);
              return SummaryScreen(bookId: bookId);
            },
          ),
        ],
      ),
    ],
  );
}

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/books');
              break;
            case 2:
              context.go('/add-book');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Start',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Bücher',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Hinzufügen',
          ),
        ],
      ),
    );
  }
}