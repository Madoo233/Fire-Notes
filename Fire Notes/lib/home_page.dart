import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_notes/categories/edit.dart';
import 'package:fire_notes/note/view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              .where("id", isEqualTo: currentUser.uid)
              .get();

      data.addAll(querySnapshot.docs);
      isLoading = false;
      setState(() {});
    } catch (e) {
      print('Error fetching categories: $e');
      isLoading = false;
      //setState(() {});
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
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Category', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        elevation: 4,
        onPressed: () {
          Navigator.of(context).pushNamed('AddCategory');
        },
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        title: Text(
          'My Categories',
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
                        Icons.folder_open,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No categories yet',
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
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      NoteView(categoryid: data[index].id),
                            ),
                          );
                        },
                        onLongPress: () {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.rightSlide,
                            title: 'Category Options',
                            titleTextStyle: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            desc:
                                'What would you like to do with this category?',
                            descTextStyle: TextStyle(fontSize: 16),
                            btnCancelColor: Colors.red,
                            btnOkColor: Colors.blue,
                            btnCancelOnPress: () async {
                              await FirebaseFirestore.instance
                                  .collection('categories')
                                  .doc(data[index].id)
                                  .delete();
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('HomePage');
                            },
                            btnCancelText: 'Delete',
                            btnOkText: 'Edit',
                            btnOkOnPress: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => Edit(
                                        docid: data[index].id,
                                        oldName: data[index]['name'],
                                      ),
                                ),
                              );
                            },
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/folder.png',
                                  height: screenSize.height * 0.1,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '${data[index]["name"]}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
