
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

///
///Organize the messages get from Firebase.
///
///
class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key});

  @override
  Widget build(BuildContext context) {

    final authenticateUser = FirebaseAuth.instance.currentUser!;

    //get message list from Firebase
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('chat')
            .orderBy('createdAt', descending:true)
            .snapshots(),
        builder: (ctx, chatSnapshots){
          if(chatSnapshots.connectionState == ConnectionState.waiting) {

            return  const Center(
                child:CircularProgressIndicator()
            );
          }

          //show a Center text if there is not messages
          if(!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty){
            return  const Center(
                child: Text('No messages found')
            );
          }

          if(chatSnapshots.hasError){
            return  const Center(
                child: Text('Something went wrong...')
            );
          }

          final loadedMessages = chatSnapshots.data!.docs;

          //List with the messages
          return ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 40,
                left: 13,
                right: 13
              ),
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (ctx, index) {
                //check if there is next message
                final chatMessage = loadedMessages[index].data();
                final nextChatMessage = index + 1 < loadedMessages.length
                    ?  loadedMessages[index +1].data()
                    : null;

                final currentMessageId = chatMessage['userId'];
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage['userId']
                        : null;
                final nextUserIsSame = nextMessageUserId == currentMessageId;

                //if the message is from the last user who send a message
                //add a bubble under last bubble, else add on the other side
                if(nextUserIsSame) {
                  return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticateUser.uid == currentMessageId,
                  );

                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['userImage'],
                      username: chatMessage['username']
                      , message: chatMessage['text'],
                      isMe: authenticateUser.uid == currentMessageId
                  );
                }


              }
          );

        }
    );

  }
}
