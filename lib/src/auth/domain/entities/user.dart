// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class LocalUser extends Equatable {
  const LocalUser({
    required this.uid,
    required this.email,
    required this.points,
    required this.fullName,
    this.groupIds = const [],
    this.enrolledCourseIds = const [],
    this.following = const [],
    this.followers = const [],
    this.profilePic,
    this.bio,
  });

  const LocalUser.empty()
      : this(
          uid: '',
          email: '',
          points: 0,
          fullName: '',
          profilePic: '',
          bio: '',
          groupIds: const [],
          enrolledCourseIds: const [],
          followers: const [],
          following: const [],
        );

  final String uid;
  final String email;
  final String? profilePic;
  final String? bio;
  final int points;
  final String fullName;
  final List<String> groupIds;
  final List<String> enrolledCourseIds;
  final List<String> following;
  final List<String> followers;

  bool get isAdmin => email == 'nickrac0901@gmail.com';

  @override
  List<Object?> get props => [
        uid,
        email,
        profilePic,
        bio,
        points,
        fullName,
        groupIds.length,
        enrolledCourseIds.length,
        following.length,
        followers.length,
      ];

  @override
  String toString() {
    return 'LocalUser{uid: $uid, email: $email, bio: '
        '$bio, points: $points, fullName: $fullName}';
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'uid': uid,
  //     'email': email,
  //     'profilePic': profilePic,
  //     'bio': bio,
  //     'points': points,
  //     'fullName': fullName,
  //     'groupIds': enrolledCourseIds,
  //     'following': following,
  //     'followers': followers,
  //   };
  // }
}
