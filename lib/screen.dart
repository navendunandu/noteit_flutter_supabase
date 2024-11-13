import 'package:flutter/material.dart';
import 'package:flutter_notes_supabase/appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Controller to manage text input for notes
  final TextEditingController _noteController = TextEditingController();

  // To store the deleted note for undo functionality
  late Map<String, dynamic> deletedNote;

  // GlobalKey for AnimatedList to manage note animations
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // List to store all notes fetched from the database
  List<Map<String, dynamic>> notes = [];

  // Method to insert a new note into the database
  Future<void> insertNote(String note) async {
    try {
      // Inserting the note into Supabase
      final response = await Supabase.instance.client
          .from('notes')
          .insert({'body': note}) // The column in your database is 'body'
          .select()
          .single(); // Get the newly inserted note back to update the UI

      setState(() {
        notes.insert(
            0, response); // Add the new note at the beginning of the list
        _listKey.currentState?.insertItem(0); // Animate insertion in the list
      });
    } catch (e) {
      print('Exception during insert: $e');
    }
  }

  // Method to delete a note by its id
  Future<void> deleteNote(int id, String noteBody, int index) async {
    try {
      // Save the deleted note so we can restore it in case of undo
      deletedNote = {'id': id, 'body': noteBody};

      // Delete the note from the database
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', id); // Use the note's id to delete it

      // Animate the removal of the note from the list with fade-out effect
      _listKey.currentState?.removeItem(
        index,
        (context, animation) {
          return FadeTransition(
            opacity: animation,
            child: Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  noteBody,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      );

      // Show a SnackBar with an Undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Note deleted successfully'),
          action: SnackBarAction(
            label: 'Undo', // Show the undo button in SnackBar
            onPressed: () async {
              // Insert the note back into the database and UI
              await insertNote(deletedNote['body']);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Undo successful')),
              );
            },
          ),
        ),
      );
    } catch (e) {
      print('Exception during delete: $e');
    }
  }

  // Stream to listen to real-time changes in the 'notes' table
  final _notesStream =
      Supabase.instance.client.from('notes').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with custom height
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: MyAppBar(),
      ),
      backgroundColor: Colors.black, // Set background color to black
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // Center docked position
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter, // Place at the bottom center
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0), // Optional padding
          child: FloatingActionButton(
            shape: const CircleBorder(
              side: BorderSide(
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Color.fromARGB(255, 46, 46, 46), // Border color
                width: 4.0, // Border width (thickness)
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 224, 137, 6),
            onPressed: () {
              // Show the note dialog to add a new note
              showNoteDialog(context: context);
            },
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Listen for updates from the 'notes' table
        stream: _notesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator()); // Loading state
          }
          final newNotes = snapshot.data ?? [];
          notes = newNotes; // Update the notes list with the latest data

          // Display the notes in an AnimatedList for smooth transitions
          return AnimatedList(
            key: _listKey,
            initialItemCount: notes.length,
            itemBuilder: (context, index, animation) {
              return FadeTransition(
                opacity: animation,
                child: Card(
                  color: Colors.grey[900],
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the note body text
                        Text(
                          notes[index]['body'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Display the timestamp and action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Timestamp display
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.white54,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat('yyyy-MM-dd HH:mm:ss')
                                      .format(DateTime.now()),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            // Action buttons (Edit and Delete)
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    deleteNote(notes[index]['id'],
                                        notes[index]['body'], index);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color.fromARGB(255, 224, 137, 6),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showNoteDialog(
                                      context: context,
                                      isEditing: true,
                                      noteId: notes[index]['id'],
                                      initialText: notes[index]['body'],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color.fromARGB(255, 224, 137, 6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to show the note dialog for adding/editing notes
  void showNoteDialog(
      {required BuildContext context,
      bool isEditing = false,
      int? noteId,
      String? initialText}) {
    _noteController.text = initialText ?? ''; // Set initial text if editing

    showDialog(
      context: context,
      builder: (context) {
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Dialog(
            backgroundColor: const Color.fromARGB(221, 41, 41, 41),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'Edit Note' : 'Add New Note',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Text input field for note content
                  TextFormField(
                    controller: _noteController,
                    style: const TextStyle(color: Colors.white),
                    onFieldSubmitted: (value) async {
                      if (value.isNotEmpty) {
                        if (isEditing && noteId != null) {
                          await updateNote(noteId, value);
                        } else {
                          await insertNote(value);
                        }
                        _noteController.clear();
                        Navigator.pop(context);
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      hintText: isEditing
                          ? 'Edit your note here'
                          : 'Enter your note here',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Action buttons (Cancel and Save)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      // Save button
                      ElevatedButton(
                        onPressed: () async {
                          final noteContent = _noteController.text;
                          if (noteContent.isNotEmpty) {
                            if (isEditing && noteId != null) {
                              await updateNote(noteId, noteContent);
                            } else {
                              await insertNote(noteContent);
                            }
                            _noteController.clear();
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 224, 137, 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Method to update a note in the database
  Future<void> updateNote(int id, String note) async {
    try {
      // Update the note in the database by its id
      await Supabase.instance.client
          .from('notes')
          .update({'body': note}).eq('id', id);
    } catch (e) {
      print('Error: $e');
    }
  }
}
