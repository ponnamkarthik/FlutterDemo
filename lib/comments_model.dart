import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  CommentModel({
    required this.mobile,
    required this.comment,
    required this.uid,
    required this.timestamp,
  });

  CommentModel.fromJson(Map<String, Object?> json)
      : this(
          mobile: json['mobile']! as String,
          comment: json['comment']! as String,
          uid: json['uid']! as String,
          timestamp: json['timestamp']! as Timestamp,
        );

  final String mobile;
  final String comment;
  final String uid;
  final Timestamp timestamp;

  Map<String, Object?> toJson() {
    return {
      'mobile': mobile,
      'content': comment,
      'uid': uid,
      'timestamp': timestamp,
    };
  }
}
