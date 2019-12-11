import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wadone_main/home/comment_widget.dart';

StreamBuilder<QuerySnapshot> getComments(String postId) {
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance
        .collection('comments')
        .where("post_id", isEqualTo: postId)
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData)
        return Center(
          child: CircularProgressIndicator(),
        );
      final int commentCount = snapshot.data.documents.length;
      snapshot.data.documents
          .sort((a, b) => b.data['time'].compareTo(a.data['time']));
      if (commentCount > 0) {
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: commentCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            return commentWidget(
              document['user_email'],
              document['content'],
              document['time'],
            );
          },
        );
      } else {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          alignment: Alignment.center,
          child: Text(
            'no comments...',
            style: TextStyle(fontSize: 20),
          ),
        );
      }
    },
  );
}

void createRecord(String postId, String email, String content) async {
  await Firestore.instance.collection("comments").document().setData({
    'post_id': postId,
    'user_email': email,
    'content': content,
    'time': Timestamp.now()
  });
}