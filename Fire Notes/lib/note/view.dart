import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_notes/note/add.dart';
import 'package:fire_notes/note/edit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NoteView extends StatefulWidget {
  final String categoryid;
  const NoteView({super.key, required this.categoryid});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  List<QueryDocumentSnapshot> data = [];

  bool isLoading = true;

  getData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('SignIn', (route) => false);
        return;
      }

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('categories')
              .doc(widget.categoryid)
              .collection('note')
              .get();

      data.addAll(querySnapshot.docs);
      isLoading = false;
      setState(() {});
    } catch (e) {
      print('Error fetching categories: $e');
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.note_add, color: Colors.white),
        label: Text('Add Note', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        elevation: 4,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddNote(docid: widget.categoryid),
            ),
          );
        },
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('HomePage', (route) => false);
          },
        ),
        title: Text(
          'My Notes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () async {
                GoogleSignIn googleSignIn = GoogleSignIn();
                googleSignIn.disconnect();
                await FirebaseAuth.instance.signOut();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('SignIn', (route) => false);
              },
              icon: Icon(Icons.exit_to_app, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.withOpacity(0.1), Colors.white],
          ),
        ),
        child: WillPopScope(
          child:
              isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  )
                  : data.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notes yet',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                  : Padding(
                    padding: EdgeInsets.all(16),
                    child: GridView.builder(
                      itemCount: data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        mainAxisExtent: screenSize.height * 0.22,
                      ),
                      itemBuilder: (context, i) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => EditNote(
                                      notedocid: data[i].id,
                                      categorydocid: widget.categoryid,
                                      value: '${data[i]['note']}',
                                    ),
                              ),
                            );
                          },
                          onLongPress: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.rightSlide,
                              title: 'Delete Note',
                              titleTextStyle: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              desc:
                                  'Are you sure you want to delete this note?',
                              descTextStyle: TextStyle(fontSize: 16),
                              btnCancelColor: Colors.red,
                              btnOkColor: Colors.grey,
                              btnCancelOnPress: () async {
                                await FirebaseFirestore.instance
                                    .collection('categories')
                                    .doc(widget.categoryid)
                                    .collection('note')
                                    .doc(data[i].id)
                                    .delete();

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => NoteView(
                                          categoryid: widget.categoryid,
                                        ),
                                  ),
                                );
                              },
                              btnCancelText: 'Delete',
                              btnOkText: 'Cancel',
                            ).show();
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.orange.withOpacity(0.1),
                                    Colors.orange.withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.note,
                                    color: Colors.orange,
                                    size: 32,
                                  ),
                                  SizedBox(height: 12),
                                  Expanded(
                                    child: Text(
                                      '${data[i]['note']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[800],
                                        height: 1.5,
                                      ),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          onWillPop: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('HomePage', (route) => false);
            return Future.value(false);
          },
        ),
      ),
    );
  }
}
