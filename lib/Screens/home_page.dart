import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Screens/Auth/login_screen.dart';
import 'package:e_commerce_app/Screens/helper/helper_methods.dart';
import 'package:e_commerce_app/Screens/profile_page.dart';
import 'package:e_commerce_app/social_post.dart';
import 'package:e_commerce_app/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'drawer.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();

  void postMassage() {
    // only post if there is something in the TextField
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('User Posts').add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
    // To Clear The text Field
    setState(() {
      textController.clear();
    });
  }

  // navigate to profile page
  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Center(
          child: Text(
            'Social',
          ),
        ),
      ),
      drawer: MyDrawer(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('User Posts')
                    .orderBy('TimeStamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get the message
                        final post = snapshot.data!.docs[index];
                        return SocialPost(
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Erroe : ' + snapshot.error.toString()),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            // post massage
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  //TextField
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: 'Write Something',
                      obscureText: false,
                    ),
                  ),
                  // Post Button
                  IconButton(
                      onPressed: () {
                        postMassage();
                      },
                      icon: Icon(Icons.arrow_circle_up))
                ],
              ),
            ),

            //  logged in as
            Text(
              'Logged in as : ' + currentUser.email!,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}
