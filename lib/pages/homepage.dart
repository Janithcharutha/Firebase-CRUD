import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();

  // TextEditingController for handling the text input
  TextEditingController textController = TextEditingController();

  // open dialog box to add note
  void openNoteBox({String? docID, String? existingNote}) {
    // Pre-fill the controller if editing a note
    if (existingNote != null) {
      textController.text = existingNote;
    } else {
      textController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docID == null ? "Add Note" : "Edit Note"),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: "Enter your note here...",
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              String noteText = textController.text.trim();

              if (noteText.isEmpty) {
                // Prevent saving empty notes
                Navigator.pop(context);
                return;
              }

              if (docID == null) {
                // Add a new note
                await firestoreService.addNote(noteText);
              } else {
                // Update an existing note
                await firestoreService.updateNote(docID, noteText);
              }

              textController.clear(); // Clear the text field
              Navigator.pop(context); // Close the dialog
            },
            child: Text(docID == null ? "Add" : "Update"),
          ),
          TextButton(
            onPressed: () {
              textController.clear();
              Navigator.pop(context); // Close the dialog without saving
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(" Firebase CRUD")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNoteStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;
            return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];

                  return ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: ()=>openNoteBox(docID: docID),
                      icon: Icon(Icons.settings),),
                          IconButton(onPressed: ()=>firestoreService.deleteNote(docID),
                            icon: Icon(Icons.delete),),
                        ],
                      ));
                });
          } else {
            return const Text('No Notes..');
          }
        },
      ),
    );
  }
}
