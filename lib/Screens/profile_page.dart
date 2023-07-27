import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Screens/my_text_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //all users
  final usersCollaction = FirebaseFirestore.instance.collection('SocialUsers');

  // edit field
  Future<void> editField(String field) async {
    String newValue = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Edit ' + field,
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Enter new $field',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // cancel button
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed : ()=> Navigator.pop(context),
          ),

          //save button
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed : ()=> Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    // Update in fireStore
    if(newValue.trim().length>0){
      //only update if there somenthing in the text field
      await usersCollaction.doc(currentUser.email).update({field:newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Center(
            child: Text('Profile Page'),
          ),
          backgroundColor: Colors.grey[900],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('SocialUsers')
              .doc(currentUser.email!)
              .snapshots(),
          builder: (context, snapshot) {
            // get user data
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                children: [
                  SizedBox(
                    height: 35,
                  ),

                  // Profile pic
                  Icon(
                    Icons.person,
                    size: 72,
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  // User Email
                  Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  SizedBox(
                    height: 50,
                  ),

                  //  user Details
                  Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                      'My Details',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),

                  // userName
                  MyTextBox(
                    text: userData['username'],
                    sectionName: "username",
                    onPressed: () => editField('username'),
                  ),

                  // bio
                  MyTextBox(
                    text: userData['bio'],
                    sectionName: "bio",
                    onPressed: () => editField('bio'),
                  ),

                  SizedBox(
                    height: 50,
                  ),
                  
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error ${snapshot.error}'),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
