import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_notes/components/buttons.dart';
import 'package:fire_notes/components/text_form_fild.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  Future<void> addCategory() async {
    if (formState.currentState!.validate()) {
      try {
        setState(() => isLoading = true);
        await FirebaseFirestore.instance.collection('categories').add({
          'name': nameController.text,
          'id': FirebaseAuth.instance.currentUser!.uid,
        });
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('HomePage', (route) => false);
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        title: Text(
          'Add Category',
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
                              'Create Category',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add a new category to organize your notes',
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
                                    titleHintText: 'Category Name',
                                    hintText: 'Enter category name',
                                    controller: nameController,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter a category name';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 24),
                                  Buttons(
                                    title: 'Create Category',
                                    filledColor: Colors.orange,
                                    onPressed: addCategory,
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
