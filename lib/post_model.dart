import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  PostModel({
    required this.mobile,
    required this.content,
    required this.uid,
    required this.timestamp,
  });

  PostModel.fromJson(Map<String, Object?> json)
      : this(
          mobile: json['mobile']! as String,
          content: json['content']! as String,
          uid: json['uid']! as String,
          timestamp: json['timestamp']! as Timestamp,
        );

  final String mobile;
  final String content;
  final String uid;
  final Timestamp timestamp;

  Map<String, Object?> toJson() {
    return {
      'mobile': mobile,
      'content': content,
      'uid': uid,
      'timestamp': timestamp,
    };
  }
}
