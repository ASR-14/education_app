import 'dart:async';
import 'package:education_app/src/course/presentation/views/course_details_screen.dart';
import 'package:education_app/src/search/presentation/providers/search_provider.dart';
import 'package:education_app/src/search/presentation/widgets/search_result_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      context.read<SearchProvider>().search('');
    });
  }

  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _navigateToCourseDetails(String courseId) async {
    final provider = context.read<SearchProvider>();
    final course = await provider.getCourseById(courseId);

    if (course != null && mounted) {
      await Navigator.pushNamed(
        context,
        CourseDetailsScreen.routeName,
        arguments: course,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load course details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search courses...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withValues(alpha: 0.5),
            ),
          ),
          onChanged: (value) {
            _debouncer.run(() {
              context.read<SearchProvider>().search(value);
            });
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (provider.results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No courses found',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try different keywords',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.results.length,
            itemBuilder: (context, index) {
              final course = provider.results[index];
              return SearchResultCard(
                course: course,
                onTap: () => _navigateToCourseDetails(course.id),
              );
            },
          );
        },
      ),
    );
  }
}

class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
