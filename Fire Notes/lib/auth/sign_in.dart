import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fire_notes/components/buttons.dart';
import 'package:fire_notes/components/logo.dart';
import 'package:fire_notes/components/text_form_fild.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> signInWithGoogle() async {
    try {
      setState(() => isLoading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (mounted) {
        if (userCredential.user != null && userCredential.user!.emailVerified) {
          Navigator.of(context).pushReplacementNamed('HomePage');
        } else {
          Navigator.of(context).pushReplacementNamed('HomePage');
        }
      }
    } catch (e) {
      print("Google Sign In Error: $e");
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: 'Failed to sign in with Google. Please try again.',
        ).show();
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String? _validateEmail(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{3,4}$');
    if (!emailRegex.hasMatch(val)) {
      return 'Please enter a valid email';
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
                        SizedBox(height: screenSize.height * 0.05),
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
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Sign in to continue',
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
                                  validator: _validatePassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  hintText: 'Enter your password',
                                  controller: password,
                                  titleHintText: 'Password',
                                  obscureText: true,
                                ),
                                SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () async {
                                      if (email.text.isEmpty) {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.info,
                                          animType: AnimType.rightSlide,
                                          title: 'Email Required',
                                          desc: 'Please enter your email first',
                                        ).show();
                                        return;
                                      }

                                      final emailError = _validateEmail(
                                        email.text,
                                      );
                                      if (emailError != null) {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.info,
                                          animType: AnimType.rightSlide,
                                          title: 'Invalid Email',
                                          desc:
                                              'Please enter a valid email address',
                                        ).show();
                                        return;
                                      }

                                      try {
                                        await FirebaseAuth.instance
                                            .sendPasswordResetEmail(
                                              email: email.text,
                                            );
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.success,
                                          animType: AnimType.rightSlide,
                                          title: 'Reset Email Sent',
                                          desc:
                                              'If an account exists, a password reset link has been sent.',
                                        ).show();
                                      } catch (e) {
                                        if (mounted) {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.error,
                                            animType: AnimType.rightSlide,
                                            title: 'Error',
                                            desc:
                                                'Failed to send reset email: $e',
                                          ).show();
                                        }
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.orange,
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Buttons(
                                  title: 'Sign In',
                                  filledColor: Colors.orange,
                                  onPressed: () async {
                                    if (formState.currentState!.validate()) {
                                      try {
                                        setState(() => isLoading = true);

                                        final credential = await FirebaseAuth
                                            .instance
                                            .signInWithEmailAndPassword(
                                              email: email.text,
                                              password: password.text,
                                            );

                                        if (credential.user!.emailVerified) {
                                          if (mounted) {
                                            Navigator.of(
                                              context,
                                            ).pushReplacementNamed("HomePage");
                                          }
                                        } else {
                                          await FirebaseAuth.instance.signOut();
                                          if (mounted) {
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.info,
                                              animType: AnimType.rightSlide,
                                              title: 'Verify Email',
                                              desc:
                                                  'Please verify your email before signing in\nWe sent a verify email for this gmail',
                                            ).show();
                                          }
                                        }
                                      } on FirebaseAuthException catch (e) {
                                        String message =
                                            'Invalid email or password';
                                        if (e.code == 'user-not-found') {
                                          message =
                                              'Account not found for this email';
                                        } else if (e.code == 'wrong-password') {
                                          message = 'Incorrect password';
                                        } else if (e.code ==
                                            'too-many-requests') {
                                          message =
                                              'Too many attempts. Try again later';
                                        }

                                        if (mounted) {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.error,
                                            animType: AnimType.rightSlide,
                                            title: 'Sign In Failed',
                                            desc: message,
                                          ).show();
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.error,
                                            title: 'Error',
                                            desc: 'Unexpected error: $e',
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
                        Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          icon: Image.asset(
                            'assets/images/google.png',
                            height: 24,
                          ),
                          label: Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('SignUp');
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey[600]),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
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
