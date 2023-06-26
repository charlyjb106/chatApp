
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../widgets/auth/auth_form.dart';

///Screen when user can login or sign up.
///Show a form to the users to fill up with their credentials
class AuthScreen extends StatefulWidget {

const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  final _formKey = GlobalKey<FormState>();

  final _firebase = FirebaseAuth.instance;
  var _isLoading = false;

  ///receives the user's input and send a request to firebase
  void _submitAuthForm(String email, String username, String password,File? selectedImage, bool isLogin)  async {

    try {
      setState(() {
        _isLoading = true;
      });

    if(isLogin){

      final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      //if user is signing up, create a new user with the profile image
    } else {

        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: email,
            password: password
        );

        //upload the image to firebase, in a folder name 'user_images',
        // whit the user's id as name
        final storageRef =
        FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(selectedImage!);
        //get the url to the image on the cloud
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': imageUrl
        });
      }

    } on FirebaseAuthException catch(error){

        if(error.code == 'email-already-in-use') {

        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.message ?? 'Authentication failed'),
        ));
    }

    setState(() {
      _isLoading = false;
    });


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: AuthForm(_submitAuthForm, _isLoading)
    );
  }
}
