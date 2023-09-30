import 'package:chatlator/Components/button.dart';
import 'package:chatlator/pages/home.dart';
import 'package:chatlator/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Components/textfield.dart';
import '../Routing/Navigate.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: 350,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Textfält för användarnamn
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false,
                  ),
                  // Textfält för e-post
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  // Textfält för lösenord
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  // Textfält för att upprepa lösenord
                  MyTextField(
                    controller: repeatPasswordController,
                    hintText: 'Repeat password',
                    obscureText: true,
                  ),

                  // Knapp för att registrera användaren
                  MyButton(
                      text: 'Register',
                      onPressed:
                          () async {
                        final email = emailController.text;
                        final password = passwordController.text;
                        final repeatPassword = repeatPasswordController.text;
                        final username = usernameController.text;

                        // Kontrollera om lösenorden matchar
                        if (password != repeatPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Passwords do not match.'),
                            ),
                          );
                          return;
                        }

                        try {
                          // Skapa användaren med e-post och lösenord
                          final UserCredential userCredential = await _auth
                              .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          // Om registreringen lyckas, spara användarinformation i Firestore
                          if (userCredential.user != null) {
                            await FirebaseFirestore.instance.collection('users')
                                .doc(userCredential.user!.uid)
                                .set({
                              'email': email,
                              'username': username,
                            });

                            // Navigera till hemskärmen efter registrering
                            Navigate.navigateTo(context, const Home());
                          }
                        } catch (e) {
                          print('Error: $e');
                          // Visa ett felmeddelande om registreringen misslyckas.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Registration failed: $e'),
                            ),
                          );
                        }
                      }
                  ),

                  // Länk för att gå till inloggningssidan
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigate.navigateTo(context, LoginPage());
                      },
                      child: const Text(
                        'Login Page',
                        style: TextStyle(
                          color: Color.fromRGBO(174, 196, 194, 1.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
