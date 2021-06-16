import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {

  TextEditingController _postContentController = TextEditingController();
  CollectionReference feedCollection = FirebaseFirestore.instance.collection("feed");

  Future<void> _postFeed() async {
    String content = _postContentController.text.trim();

    User? user = FirebaseAuth.instance.currentUser;

    String mobile = user?.phoneNumber ?? "";
    String uid = user?.uid ?? "";

    mobile = mobile.replaceAll("+91", "");

    Timestamp timestamp = Timestamp.fromDate(DateTime.now());

    Map<String, dynamic> data = {
      "content": content,
      "mobile": mobile,
      "uid": uid,
      "timestamp": timestamp,
    };

    feedCollection.add(data).then((value) {
      print("Post Added");
      _postContentController.text = "";
      Navigator.of(context).pop();
    })
    .catchError((onError) {
      print(onError);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Post",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _postContentController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xFF312F39),
                  filled: true,
                  hintText: "Whats on your mind..."),
              minLines: 5,
              maxLines: 6,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                _postFeed();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    "Post",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
