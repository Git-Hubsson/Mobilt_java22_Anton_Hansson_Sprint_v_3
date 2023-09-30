import 'dart:convert';
import 'package:chatlator/Components/button.dart';
import 'package:chatlator/Components/textfield.dart';
import 'package:chatlator/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Routing/Navigate.dart';

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  State<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  final usernameController = TextEditingController();

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
                Text('Change username'),
                // Textfält för username
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 18,
                ),

                //Sätter värdet på täxtfältet till ett random username
                MyButton(
                    text: 'Generate random username',
                    onPressed: () async {
                      final randomUsername = await getRandomUsername();
                      usernameController.text = randomUsername;
                    }),

                //Uppdaterar databasen med den nya infon
                MyButton(
                    text: 'Save',
                    onPressed: () async {
                      final username = usernameController.text;
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'username': username,
                      });
                      Navigate.navigateTo(context, const Home());
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //API för att hämta ett random username
  Future<String> getRandomUsername() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final username = data['results'][0]['login']['username'];
      return username;
    } else {
      throw Exception('Failed to load random username');
    }
  }
}
