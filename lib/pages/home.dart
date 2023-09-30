import 'package:chatlator/pages/chat.dart';
import 'package:chatlator/pages/login.dart';
import 'package:chatlator/pages/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Routing/navigate.dart';
import 'add_friend.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //Öppna en sidomeny när menyknappen trycks
  void _openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          color: Colors.white,
          onPressed: () {
            _openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: const Text('Add Friend'),
              onTap: () {
                Navigator.pop(context); // Stäng drawer
                Navigate.navigateTo(context, const AddFriend());
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Stäng drawer
                Navigator.pop(context);
                Navigate.navigateTo(context, const Settingspage());
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('rememberMe', false);
                Navigator.pop(context); // Stäng drawer
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                  (route) => false, // Tar bort alla tidigare sidor från stacken
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          // Hämta alla användare från Firestore
          final users = (snapshot.data as QuerySnapshot).docs;

          // Filtrera bort den inloggade användaren baserat på UID
          final filteredUsers =
              users.where((user) => user.id != _auth.currentUser!.uid).toList();

          // Använd filteredUsers för att visa användarlistan
          return ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final username = user['username'];

              return GestureDetector(
                onTap: () {
                  // Lägg till logik för att starta en chatt med användaren här
                  _enterChat(otherUserId: user.id);
                  // Använd användarens ID (user.id) eller annan identifierare för att komma åt användarens data
                  Navigate.navigateTo(context, Chat(otherUserId: user.id));
                },
                child: ListTile(
                  title: Text(username),
                ),
              );
            },
          );
        },
      ),
    );
  }


  void navigate(BuildContext context, Widget destination){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  // Funktion för att hantera att gå in i en chatt med en användare
  void _enterChat({required otherUserId}) async {
    final chatReference = _firestore.collection('chats').doc(otherUserId);

    // Kolla om konversationen redan finns
    final chatExists = await chatReference.get();

    if (!chatExists.exists) {
      // Skapa konversationen om den inte finns
      await chatReference.set({
        'participants': [FirebaseAuth.instance.currentUser!.uid, otherUserId],
      });
    }
  }
}
