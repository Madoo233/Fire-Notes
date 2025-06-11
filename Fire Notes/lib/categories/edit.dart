import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_notes/components/buttons.dart';
import 'package:fire_notes/components/text_form_fild.dart';
import 'package:flutter/material.dart';

class Edit extends StatefulWidget {
  const Edit({super.key, required this.docid, required this.oldName});
  final String docid;
  final String oldName;
  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  Future<void> editCategory() async {
    if (formState.currentState!.validate()) {
      try {
        setState(() => isLoading = true);
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.docid)
            .update({'name': nameController.text});
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('HomePage', (route) => false);
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.oldName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        title: Text(
          'Edit Category',
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
                              'Edit Category',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Update your category name',
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
                                    title: 'Save Changes',
                                    filledColor: Colors.orange,
                                    onPressed: editCategory,
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
