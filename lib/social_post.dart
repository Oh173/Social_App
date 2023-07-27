import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/Screens/comment.dart';
import 'package:e_commerce_app/Screens/comment_button.dart';
import 'package:e_commerce_app/Screens/delete_button.dart';
import 'package:e_commerce_app/Screens/like_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Screens/helper/helper_methods.dart';

class SocialPost extends StatefulWidget {
  const SocialPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  final String message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;

  @override
  State<SocialPost> createState() => _SocialPostState();
}

class _SocialPostState extends State<SocialPost> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  // comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    isLiked = widget.likes.contains(currentUser.email);
    super.initState();
  }

  void toogleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Access the document in firebase

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      // if the post is now liked , add the user's email to the likes field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if the post is now unliked , remove the user's email to the likes field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  //Add a comment
  void addComment(String commentText) {
    //Write the Comment to firestore under the comments collection for this post
    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .add({
      'CommentText': commentText,
      'CommentedBy': currentUser.email,
      'CommentTime': Timestamp.now(), //متنساش تعمله فورمات قبل م تعرضه
    });
  }

  // Show a dialog box for adding Comments
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(
            hintText: 'Write a comment...',
          ),
        ),
        actions: [
          // cancel button

          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: Text('Cancel'),
          ),

          // post button
          TextButton(
            onPressed: () {
              // add comment
              addComment(_commentTextController.text);

              Navigator.pop(context);

              // clear controller
              _commentTextController.clear();
            },
            child: Text('Post'),
          ),
        ],
      ),
    );
  }

  // delete a post
  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post!'),
        actions: [
          //cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
            ),
          ),

          //Delete button
          TextButton(
            onPressed: () async {
              // first delete the post from firestore
              final commentDocs = await FirebaseFirestore.instance
                  .collection('User Posts')
                  .doc(widget.postId)
                  .collection('Comments')
                  .get();

              for (var doc in commentDocs.docs){
                await FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).collection('Comments').doc(doc.id).delete();
              }

              FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).delete().then((value) =>
                  print('Post Deleted')).catchError((error) =>
                  print('Field to delete the post : $error'));

              Navigator.pop(context);
            },
            child: Text(
              'Delete',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(25),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // message and user email
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group of text < message and user >
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //message
                  Text(widget.message),

                  SizedBox(
                    height: 10,
                  ),

                  //user
                  Row(
                    children: [
                      Text(
                        widget.user,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        ' . ',
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        widget.time,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              //delete Button
              if (widget.user == currentUser.email)
                  DeleteButton(
                    onTap: deletePost
                  )
            ],
          ),

          SizedBox(
            height: 10,
          ),

          // buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Like
              Column(
                children: [
                  // like button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: () => toogleLike(),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  // like count
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(
                width: 10,
              ),

              // Comment
              Column(
                children: [
                  // Comment button
                  CommentButton(
                    onTap: showCommentDialog,
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  // Comment count
                  Text(
                    '0',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),

          //Comments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('User Posts')
                .doc(widget.postId)
                .collection('Comments')
                .orderBy(
                  'CommentTime',
                  descending: true,
                )
                .snapshots(),
            builder: (context, snapshot) {
              // show loading circle if no data yet
              if (snapshot.hasError) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    // get the comment
                    final commentData = doc.data() as Map<String, dynamic>;

                    //return the comment
                    return Comment(
                      text: commentData['CommentText'],
                      user: commentData['CommentedBy'],
                      time: formatDate(commentData['CommentTime']),
                    );
                  }).toList());
            },
          )
        ],
      ),
    );
  }
}
