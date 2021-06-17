import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialapp_studio/add_post_page.dart';
import 'package:socialapp_studio/post_details.dart';
import 'package:socialapp_studio/post_model.dart';
import 'package:socialapp_studio/splash_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference<PostModel> feedCollection =
      FirebaseFirestore.instance.collection("feed").withConverter<PostModel>(
        fromFirestore: (snapshot, _) => PostModel.fromJson(snapshot.data()!),
        toFirestore: (post, _) => post.toJson(),
      );

  late Stream<QuerySnapshot<PostModel>> feedStream;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SplashScreen()),
      (route) => false,
    );
  }

  @override
  void initState() {
    feedStream = feedCollection.orderBy('timestamp', descending: true).snapshots();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Social App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Logout",
            onPressed: () {
              _logout();
            },
            icon: Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<PostModel>>(
        stream: feedStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<PostModel>> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot<PostModel>> listPosts = snapshot.data?.docs ?? [];

          return ListView.separated(
            itemBuilder: (context, index) {
              QueryDocumentSnapshot document = listPosts[index];
              var post = document.data() as PostModel;
              return FeedItemWidget(
                username: post.mobile,
                time: timeago.format(post.timestamp.toDate()),
                content: post.content,
                onDelete: () {
                  document.reference.delete();
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PostDetailsPage(
                      docId: document.id,
                    ))
                  );
                },
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 12,
              );
            },
            itemCount: listPosts.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddPostPage(),
              fullscreenDialog: true,
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class FeedItemWidget extends StatelessWidget {
  const FeedItemWidget({
    Key? key,
    this.username = "",
    this.content = "",
    this.time = "",
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  final String username;
  final String content;
  final String time;
  final Function? onDelete;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(.4),
                      ),
                    ),
                    SizedBox(width: 8,),
                    InkWell(
                      onTap: () {
                        onDelete?.call();
                      },
                      child: Icon(Icons.delete, size: 14,),
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              height: 12,
            ),
            Text(content,
                style: TextStyle(
                  color: Colors.white.withOpacity(.6),
                )),
          ],
        ),
      ),
    );
  }
}
