import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  final String otherUserId;

  const Chat({super.key, required this.otherUserId});

  @override
  State<Chat> createState() => _ChatState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _ChatState extends State<Chat> {
  TextEditingController messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final currentUser = _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            //Hämtar alla meddelanden
            child: StreamBuilder(
              stream: firestore
                  .collection('chats')
                  .doc(getChatDocumentId(currentUser!.uid, widget.otherUserId))
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final chatData = snapshot.data as QuerySnapshot;
                  final messages = chatData.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();

                  return Column(
                    children: [
                      Expanded(
                        //Bygger en scrollbar lista av alla meddelanden
                        child: ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final sender = message['sender']
                                as String?;
                            final text = message['text']
                                as String?;

                            return ListTile(
                              title: Text(text!),
                              subtitle: Text('Sent by: $sender'),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
                    final username = userDoc['username'] as String;
                    if (currentUser != null && messageController.text.isNotEmpty) {
                      final chatReference = firestore.collection('chats').doc(
                          getChatDocumentId(currentUser.uid, widget.otherUserId));

                      // Skapa ett nytt meddelandeobjekt
                      final message = {
                        'sender': username,
                        // currentUser.email,
                        'text': messageController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      };

                      // Hämta den aktuella konversationen från Firestore
                      final chatSnapshot = await chatReference.get();

                      if (chatSnapshot.exists) {
                        // Om konversationen finns, uppdatera meddelandelistan i underkollektionen
                        chatReference.collection('messages').add(message);
                      } else {
                        // Om konversationen inte finns, skapa den först
                        await chatReference.set({
                          'participants': [currentUser.uid, widget.otherUserId],
                        });

                        // Skapa den första meddelandet i underkollektionen
                        chatReference.collection('messages').add(message);
                      }
                      // Rensa textfältet efter att meddelandet har skickats
                      messageController.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],

      ),
    );
  }

  String getChatDocumentId(String userId1, String userId2) {
    List<String> sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
}
