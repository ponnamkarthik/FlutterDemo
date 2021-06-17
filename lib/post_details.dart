import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialapp_studio/comments_model.dart';
import 'package:socialapp_studio/home_page.dart';
import 'package:socialapp_studio/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsPage extends StatefulWidget {
  const PostDetailsPage({Key? key, this.docId = ""}) : super(key: key);

  final String docId;

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  CollectionReference<PostModel> feedCollection = FirebaseFirestore.instance
      .collection("feed")
      .withConverter<PostModel>(
        fromFirestore: (snapshot, _) => PostModel.fromJson(snapshot.data()!),
        toFirestore: (post, _) => post.toJson(),
      );

  late CollectionReference<CommentModel> commentsCollection;

  late Stream<DocumentSnapshot<PostModel>> feedStream;

  late Stream<QuerySnapshot<CommentModel>> commentsStream;

  TextEditingController _commentEditController = TextEditingController();

  Future<void> _addComment() async {
    String comment = _commentEditController.text.trim();

    User? user = FirebaseAuth.instance.currentUser;

    String mobile = user?.phoneNumber ?? "";
    String uid = user?.uid ?? "";

    mobile = mobile.replaceAll("+91", "");

    Timestamp timestamp = Timestamp.fromDate(DateTime.now());

    Map<String, dynamic> data = {
      "comment": comment,
      "mobile": mobile,
      "uid": uid,
      "timestamp": timestamp,
    };

    feedCollection
        .doc(widget.docId)
        .collection("comments")
        .add(data)
        .then((value) {
      _commentEditController.text = "";
      FocusScope.of(context).requestFocus(FocusNode());
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  void initState() {
    commentsCollection = FirebaseFirestore.instance
        .collection("feed")
        .doc(widget.docId)
        .collection("comments")
        .withConverter<CommentModel>(
          fromFirestore: (snapshot, _) =>
              CommentModel.fromJson(snapshot.data()!),
          toFirestore: (comment, _) => comment.toJson(),
        );
    commentsStream = commentsCollection.snapshots();
    feedStream = feedCollection.doc(widget.docId).snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<DocumentSnapshot<PostModel>>(
                    stream: feedStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot<PostModel>> snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error getting feed"),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      DocumentSnapshot<PostModel> document =
                          snapshot.data as DocumentSnapshot<PostModel>;
                      PostModel post = document.data() as PostModel;

                      return FeedItemWidget(
                        username: post.mobile,
                        content: post.content,
                        time: timeago.format(post.timestamp.toDate()),
                        onDelete: () {
                          document.reference.delete();
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Text(
                      "Comments",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot<CommentModel>>(
                    stream: commentsStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<CommentModel>> snapshot) {
                      if (snapshot.hasError) {
                        return Text("Unable to load comments");
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      List<QueryDocumentSnapshot<CommentModel>> listComments =
                          snapshot.data?.docs ?? [];

                      if (listComments.length == 0) {
                        return Center(child: Text("No comments"));
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          QueryDocumentSnapshot<CommentModel> document =
                              listComments[index];
                          CommentModel comment = document.data();

                          return CommentItemWidget(
                            username: comment.mobile,
                            comment: comment.comment,
                            time: timeago.format(comment.timestamp.toDate()),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 10,
                          );
                        },
                        itemCount: listComments.length,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          TextField(
            controller: _commentEditController,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "What you say..",
                fillColor: Color(0xFF312F39),
                filled: true,
                suffixIcon: IconButton(
                  onPressed: () {
                    _addComment();
                  },
                  icon: Icon(Icons.send_rounded),
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }
}

class CommentItemWidget extends StatelessWidget {
  const CommentItemWidget({
    Key? key,
    this.username = "",
    this.comment = "",
    this.time = "",
  }) : super(key: key);

  final String username;
  final String comment;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: Color(0xFF312F39),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(.4),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            comment,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(.6),
            ),
          ),
        ],
      ),
    );
  }
}
