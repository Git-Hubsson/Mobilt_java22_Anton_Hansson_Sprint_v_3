import 'package:chatlator/Components/button.dart';
import 'package:chatlator/Components/textfield.dart';
import 'package:chatlator/Routing/Navigate.dart';
import 'package:chatlator/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 350,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  width: 100,
                  image: AssetImage('lib/images/cl.png'),
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
                // Checkbox för att komma ihåg inloggningen
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    Text('Remember Me'),
                  ],
                ),

                // Knapp för att logga in med e-post och lösenord
                MyButton(
                    text: 'Sign In',
                    onPressed: () async {
                      try {
                        // Logga in med e-post och lösenord
                        final UserCredential userCredential =
                            await widget._auth.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        if (userCredential.user != null) {
                          // Spara användarens inloggningssätt om användaren vill komma ihåg det
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (rememberMe) {
                            prefs.setBool('rememberMe', true);
                          } else {
                            prefs.setBool('rememberMe', false);
                          }
                          // Navigera till hemskärmen
                          Navigate.navigateTo(context, const Home());
                        }
                      } catch (e) {
                        print('Error: $e');
                        // Visa ett felmeddelande om autentiseringen misslyckas
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Authentication failed'),
                          ),
                        );
                      }
                    }),

                //Logga in med Google
                MyButton(
                    text: 'Sign In With Google',
                    onPressed: () async {
                      // Logga in med Google-konto
                      final User? user = await _handleGoogleSignIn();
                      if (user != null) {
                        Navigate.navigateTo(context, const Home());
                      }
                    }),

                const SizedBox(
                  height: 18,
                ),

                // Länk för att registrera sig
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Register()),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Color.fromRGBO(159, 210, 205, 1.0),
                      ),
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

  // Funktion för att hantera Google-inloggning
  Future<User?> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await widget._auth.signInWithCredential(credential);
        final User? user = authResult.user;
        return user;
      }
      return null;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
