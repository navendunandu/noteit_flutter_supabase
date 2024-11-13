import 'package:flutter/material.dart';
import 'package:flutter_notes_supabase/screen.dart'; // Importing the screen where your app's main UI is defined
import 'package:supabase_flutter/supabase_flutter.dart'; // Importing the Supabase Flutter package

// Main entry point of the Flutter application
void main() async {
  // Ensures that the app is fully initialized before anything is executed
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Supabase instance with your project URL and anon key
  await Supabase.initialize(
    url: 'SUPABASE_URL', // Replace with your Supabase project's URL
    anonKey: 'SUPABASE_ANON_KEY', // Replace with your Supabase anonymous key
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
            MainScreen()); // Main screen of the app, where the notes will be shown
  }
}
