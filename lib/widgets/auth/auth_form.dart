import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';


///
///Form use for sign up new users. And add it to Firebase
///
class AuthForm extends StatefulWidget {
  final bool isLoading;
  final void Function(
    String email,
    String username,
    String password,
    File? selectedImage,
    bool isLogin,
  ) submitAuthForm;

  AuthForm(this.submitAuthForm, this.isLoading);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userPassword = '';
  var _userUsername = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  //Check if the user's input are valid and submit the form.
  void _submitForm() {

    final isValid = _formKey.currentState!.validate();
    //close the keyboard
    FocusScope.of(context).unfocus();

    if(!isValid || !_isLogin && _selectedImage == null){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a photo'),
        duration: Duration(seconds: 3),
      ));
      return ;
    }

      _formKey.currentState!.save();

    setState((){
      _isAuthenticating = true;
    });

      //use those values to send our auth request
      widget.submitAuthForm(
          _userEmail.trim(), //.trim to delete any leading or trailing white space
          _userUsername.trim(),
          _userPassword.trim(),
          _selectedImage,
          _isLogin
      );

      setState(() {
        _isAuthenticating = false;
      });

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin:
                const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
            width: 200,
            child: Image.asset('assets/images/chat.png'),
          ),
          Card(
            margin: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(!_isLogin)
                        UserImagePicker(onPickImage: (pickedImage){
                          _selectedImage = pickedImage;
                        },),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value){

                          if(value == null || value.trim().isEmpty || !value.contains('@')){
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userEmail = value!;
                        },
                      ),
                      if(!_isLogin)
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Username'),
                        enableSuggestions: false,
                        validator: (value){

                          if(value == null || value.trim().isEmpty || value.trim().length < 4){
                            return 'Username must be at least 4 characters ';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userUsername = value!;
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {

                          if(value == null || value.trim().isEmpty || value.trim().length < 6){
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userPassword = value!;
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      if(_isAuthenticating)
                        const CircularProgressIndicator(),
                      if(!_isAuthenticating)
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer
                          ),
                          onPressed: _submitForm,
                          child: Text(_isLogin
                              ? 'Login'
                              : 'Signup')
                      ),
                      if(!_isAuthenticating)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(_isLogin
                            ? 'Create an account'
                            : 'I already have an account'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
