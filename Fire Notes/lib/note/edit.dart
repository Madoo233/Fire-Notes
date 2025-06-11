import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_notes/components/buttons.dart';
import 'package:fire_notes/components/text_form_fild.dart';
import 'package:fire_notes/note/view.dart';
import 'package:flutter/material.dart';

class EditNote extends StatefulWidget {
  final String notedocid;
  final String value;
  final String categorydocid;
  const EditNote({
    super.key,
    required this.notedocid,
    required this.categorydocid,
    required this.value,
  });

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController noteController = TextEditingController();
  bool isLoading = false;

  Future<void> editNote() async {
    if (formState.currentState!.validate()) {
      try {
        setState(() => isLoading = true);
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categorydocid)
            .collection('note')
            .doc(widget.notedocid)
            .update({'note': noteController.text});

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => NoteView(categoryid: widget.categorydocid),
          ),
        );
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    noteController.text = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        title: Text(
          'Edit Note',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Container(
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
                  : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: formState,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Note',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Update your note content',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  CoustomTextFormFild(
                                    titleHintText: 'Note Content',
                                    hintText: 'Write your note here...',
                                    controller: noteController,
                                    maxLines: 5,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 24),
                                  Buttons(
                                    title: 'Save Changes',
                                    filledColor: Colors.orange,
                                    onPressed: editNote,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
