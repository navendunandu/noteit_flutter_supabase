import 'package:flutter/material.dart';
import 'dart:math';

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

  // Method to get greeting based on the time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;

    // Return greeting based on the current time
    if (hour < 12) {
      return "Good Morning!";
    } else if (hour < 17) {
      return "Good Afternoon!";
    } else {
      return "Good Evening!";
    }
  }

  // Method to get a random motivational quote
  String _getRandomQuote() {
    final quotes = [
      "Believe you can and you're halfway there.",
      "Every day is a new beginning.",
      "The best time for new beginnings is now.",
      "Stay positive, work hard, and make it happen.",
      "You are capable of amazing things.",
      "Good things take time. Keep pushing forward.",
    ];

    // Return a random quote from the list
    return quotes[Random().nextInt(quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    // Get greeting and random quote
    final greeting = _getGreeting();
    final quote = _getRandomQuote();

    return Container(
      // Padding for the app bar content
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Greeting and quote text display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display greeting message
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white, // White color for greeting
                      fontSize: 22,
                      fontWeight: FontWeight.bold, // Bold for greeting
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Display random quote with ellipsis if it overflows
                  Text(
                    quote,
                    style: const TextStyle(
                      color: Color.fromARGB(
                          255, 224, 137, 6), // Orange color for quote
                      fontSize: 14,
                      fontStyle: FontStyle.italic, // Italic for quote
                    ),
                    maxLines: 2, // Limit to 2 lines for the quote
                    overflow: TextOverflow
                        .ellipsis, // Show ellipsis if text overflows
                  ),
                ],
              ),
            ),
            // Icon for visual appeal
            const Icon(
              Icons.nights_stay, // Icon representing night-time or relaxation
              color:
                  Color.fromARGB(255, 224, 137, 6), // Matching the orange theme
              size: 28, // Icon size
            ),
          ],
        ),
      ),
    );
  }
}
