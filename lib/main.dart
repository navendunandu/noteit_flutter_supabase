import 'package:flutter/material.dart';
import 'package:flutter_notes_supabase/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importing the Supabase Flutter package

// Main entry point of the Flutter application
void main() async {
  // Ensures that the app is fully initialized before anything is executed
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Supabase instance with your project URL and anon key
  await Supabase.initialize(
    url: 'https://wtqzqtnofaxczcpohdfw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0cXpxdG5vZmF4Y3pjcG9oZGZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzExNTcwODcsImV4cCI6MjA0NjczMzA4N30.9q09jTP1QuyrDNmIxSoafAnFbaQ70rhQhBBda-c4zGY',
  );

  // Run the app after Supabase initialization is complete
  runApp(const MainApp());
}

// Initialize the Supabase client for later use across the app
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  // Constructor for MainApp widget
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The main widget for the app, which is a MaterialApp
    // `home` points to the MainScreen widget, where the app's UI will be built
    return const MaterialApp(
        debugShowCheckedModeBanner: false, // Disables the debug banner
        home:
            LoginScreen()); // Main screen of the app, where the notes will be shown
  }
}
