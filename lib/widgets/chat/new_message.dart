
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

///
/// Text input where use "write" the message to send
///
class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {

  var _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  //Send the message to firebase and clear the text input
  void _submitMessage() async{

    final message = _messageController.text;

    if(message.trim().isEmpty){

      return;
    }
    //close keyboard
    FocusScope.of(context).unfocus();
    _messageController.clear();
    
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();
    
    //sending message to firebase
    FirebaseFirestore.instance
        .collection('chat')
    .add({
      'text': message,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url']
    });


  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14
      ),
      child: Row(
        children: [
           Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  labelText: 'Send a message...'
                ),
              )
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
              onPressed: _submitMessage,
              icon: const Icon(Icons.send)
          ),
        ],
      ),
    );
  }
}
