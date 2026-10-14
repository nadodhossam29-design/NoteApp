import 'package:flutter/material.dart';
import 'database/app_database.dart';
import 'screens/notes_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.buildDatabase();
  runApp(NotesApp(database: database));
}

class NotesApp extends StatelessWidget {
  final AppDatabase database;
  const NotesApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD8B4FE),
          primary: const Color(0xFFD8B4FE),
          secondary: const Color(0xFFE879AC),
          surface: const Color(0xFFFDF4FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFFDF4FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD8B4FE),
          foregroundColor: Color(0xFF4B0082),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE879AC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE879AC),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8B4FE)),
          ),
        ),
        useMaterial3: true,
      ),
      home: NotesListScreen(database: database),
    );
  }
}
