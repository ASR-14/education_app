import 'package:education_app/core/utils/typedefs.dart';
import 'package:education_app/src/course/features/videos/domain/entities/video.dart';

abstract class VideoRepo {
  const VideoRepo();

  ResultFuture<List<Video>> getVideos(String courseId);

  ResultFuture<void> addVideo(Video video);
}
