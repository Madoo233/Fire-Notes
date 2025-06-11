import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fire_notes/components/buttons.dart';
import 'package:fire_notes/components/logo.dart';
import 'package:fire_notes/components/text_form_fild.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  bool isLoading = false;

  String? _validateEmail(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(val)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateUsername(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter a username';
    }
    if (val.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter a password';
    }
    if (val.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
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
                : SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        SizedBox(height: screenSize.height * 0.03),
                        Hero(tag: 'logo', child: Logo()),
                        SizedBox(height: screenSize.height * 0.04),
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: formState,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Sign up to get started',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 32),
                                CoustomTextFormFild(
                                  validator: _validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  hintText: 'Enter your email',
                                  controller: email,
                                  titleHintText: 'Email',
                                ),
                                SizedBox(height: 20),
                                CoustomTextFormFild(
                                  validator: _validateUsername,
                                  hintText: 'Enter your username',
                                  controller: userName,
                                  titleHintText: 'Username',
                                ),
                                SizedBox(height: 20),
                                CoustomTextFormFild(
                                  validator: _validatePassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  hintText: 'Enter your password',
                                  controller: password,
                                  titleHintText: 'Password',
                                  obscureText: true,
                                ),
                                SizedBox(height: 32),
                                Buttons(
                                  title: 'Sign Up',
                                  filledColor: Colors.orange,
                                  onPressed: () async {
                                    if (formState.currentState!.validate()) {
                                      try {
                                        setState(() => isLoading = true);
                                        final credential = await FirebaseAuth
                                            .instance
                                            .createUserWithEmailAndPassword(
                                              email: email.text,
                                              password: password.text,
                                            );
                                        if (credential.user != null) {
                                          await credential.user!
                                              .sendEmailVerification();

                                          if (mounted) {
                                            await AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.success,
                                              animType: AnimType.rightSlide,
                                              title: 'Success',
                                              desc:
                                                  'Account created! Please check your email for verification.',
                                              btnOkOnPress: () {
                                                Navigator.of(
                                                  context,
                                                ).pushNamedAndRemoveUntil(
                                                  'SignIn',
                                                  (route) => false,
                                                );
                                              },
                                            ).show();
                                          }
                                        }
                                      } on FirebaseAuthException catch (e) {
                                        String errorMessage =
                                            'An error occurred';
                                        if (e.code == 'email-already-in-use') {
                                          errorMessage =
                                              'This email is already in use';
                                        } else if (e.code == 'weak-password') {
                                          errorMessage =
                                              'Please use a stronger password';
                                        } else if (e.code == 'invalid-email') {
                                          errorMessage =
                                              'Please enter a valid email';
                                        }

                                        if (mounted) {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.error,
                                            animType: AnimType.rightSlide,
                                            title: 'Error',
                                            desc: errorMessage,
                                          ).show();
                                        }
                                      } finally {
                                        if (mounted)
                                          setState(() => isLoading = false);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('SignIn');
                          },
                          child: Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(color: Colors.grey[600]),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
