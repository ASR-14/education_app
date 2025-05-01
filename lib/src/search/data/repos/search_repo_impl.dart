import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/src/course/domain/entities/course.dart';
import 'package:education_app/src/search/domain/repos/search_repo.dart';

class SearchRepoImpl implements SearchRepo {
  SearchRepoImpl(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<List<Course>> search(String query) async {
    try {
      final coursesSnapshot = await _firestore.collection('courses').get();
      final courses = coursesSnapshot.docs.map((doc) {
        final data = doc.data();
        return Course(
          id: doc.id,
          title: data['title']?.toString() ?? '',
          description: data['description']?.toString(),
          image: data['image']?.toString(),
          groupId: data['groupId']?.toString() ?? '',
          numberOfExams: (data['numberOfExams'] as num?)?.toInt() ?? 0,
          numberOfMaterials: (data['numberOfMaterials'] as num?)?.toInt() ?? 0,
          numberOfVideos: (data['numberOfVideos'] as num?)?.toInt() ?? 0,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        );
      }).toList();

      if (query.isEmpty) {
        return courses;
      }

      final lowercaseQuery = query.toLowerCase();
      return courses.where((course) {
        return course.title.toLowerCase().contains(lowercaseQuery) ||
            (course.description?.toLowerCase().contains(lowercaseQuery) ??
                false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search courses: $e');
    }
  }

  @override
  Future<Course?> getCourseById(String courseId) async {
    try {
      final doc = await _firestore.collection('courses').doc(courseId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Course(
        id: doc.id,
        title: data['title']?.toString() ?? '',
        description: data['description']?.toString(),
        image: data['image']?.toString(),
        groupId: data['groupId']?.toString() ?? '',
        numberOfExams: (data['numberOfExams'] as num?)?.toInt() ?? 0,
        numberOfMaterials: (data['numberOfMaterials'] as num?)?.toInt() ?? 0,
        numberOfVideos: (data['numberOfVideos'] as num?)?.toInt() ?? 0,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      throw Exception('Failed to get course: $e');
    }
  }
}
