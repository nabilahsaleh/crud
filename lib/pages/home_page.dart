import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/firebase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firestore
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  final TextEditingController textController = TextEditingController();

// open a dialog box to add notes
void openNoteBox({String? docID}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0), // Radius of the dialog
      ),
      title: Center(
        child: Text(
          docID == null ? 'Add a Note' : 'Update Note',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      content: TextField(
        controller: textController,
        decoration: InputDecoration(
          hintText: docID == null ? 'Enter your note here' : 'Update your note',
        ),
        autofocus: true,
      ),
      actions: [
        // Button to save or update
        ElevatedButton(
          onPressed: () {
            // Add a new note or update an existing note
            if (docID == null) {
              firestoreService.addNote(textController.text);
            } else {
              firestoreService.updateNote(docID, textController.text);
            }

            // Clear the text controller
            textController.clear();

            // Close the dialog
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Text color
            backgroundColor: Colors.blueGrey, // Button color
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0), // Padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0), // Button shape
            ),
          ),
          child: Text(docID == null ? 'Add' : 'Update'), // Change text based on docID
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'N O T E S',
            style: GoogleFonts.bebasNeue(
              textStyle: const TextStyle(color: Colors.white), // Text color
              fontSize: 33, // Font size
            ),
          ),
        ),
        backgroundColor: Colors.blueGrey, // AppBar color
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        backgroundColor: Colors.blueGrey, // Button color
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white, // Icon color
        ), // Circle shape
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // if we have data, get all the docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // display as a list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                // get each individual doc
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                // get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // display as a list tile
                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // update button
                      IconButton(
                        onPressed: () => openNoteBox(docID: docID),
                        icon: const Icon(Icons.edit),
                      ),

                      // delete button
                      IconButton(
                        onPressed: () => firestoreService.deleteNote(docID),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } // if there is no notes
          else {
            return const Text('No notes...');
          }
        },
      ),
    );
  }
}