import 'dart:io';
import 'package:education_app/core/common/widgets/course_picker.dart';
import 'package:education_app/core/common/widgets/titled_input_field.dart';
import 'package:education_app/core/enums/notification_enum.dart';
import 'package:education_app/core/utils/core_utils.dart';
import 'package:education_app/src/course/domain/entities/course.dart';
import 'package:education_app/src/course/features/exams/data/models/exam_model.dart';
import 'package:education_app/src/course/features/exams/data/models/exam_question_model.dart';
import 'package:education_app/src/course/features/exams/data/models/question_choice_model.dart';
import 'package:education_app/src/course/features/exams/presentation/app/cubit/exam_cubit.dart';
import 'package:education_app/src/notifications/presentation/presentation/widgets/notification_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddExamUIView extends StatefulWidget {
  const AddExamUIView({super.key});

  static const routeName = '/add-exam-ui';

  @override
  State<AddExamUIView> createState() => _AddExamUIViewState();
}

class _AddExamUIViewState extends State<AddExamUIView> {
  final formKey = GlobalKey<FormState>();
  final courseController = TextEditingController();
  final courseNotifier = ValueNotifier<Course?>(null);
  final examTitleController = TextEditingController();
  final examDescriptionController = TextEditingController();
  final examImageUrlController = TextEditingController();
  final examDurationController = TextEditingController();

  final questions = <ExamQuestionModel>[];
  final questionControllers = <TextEditingController>[];
  final choiceControllers = <List<TextEditingController>>[];
  final correctAnswerIndices = <int?>[];

  File? imageFile;
  bool isFile = false;

  @override
  void initState() {
    super.initState();
    examImageUrlController.addListener(() {
      if (isFile && examImageUrlController.text.isEmpty) {
        imageFile = null;
        isFile = false;
      }
    });
  }

  Future<String?> uploadImageToSupabase(File image, String examId) async {
    try {
      final fileName = '$examId.${image.path.split('.').last}';
      final filePath = 'courses/${courseNotifier.value!.id}/exams/$fileName';

      await Supabase.instance.client.storage.from('storage').upload(
            filePath,
            image,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = Supabase.instance.client.storage
          .from('storage')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      CoreUtils.showSnackBar(context, 'Failed to upload image: $e');
      return null;
    }
  }

  void addQuestion() {
    setState(() {
      questions.add(const ExamQuestionModel.empty());
      questionControllers.add(TextEditingController());
      choiceControllers.add(List.generate(4, (_) => TextEditingController()));
      correctAnswerIndices.add(null);
    });
  }

  void removeQuestion(int index) {
    setState(() {
      questions.removeAt(index);
      questionControllers[index].dispose();
      questionControllers.removeAt(index);
      for (final controller in choiceControllers[index]) {
        controller.dispose();
      }
      choiceControllers.removeAt(index);
      correctAnswerIndices.removeAt(index);
    });
  }

  Future<void> uploadExam() async {
    if (formKey.currentState!.validate()) {
      final examId = DateTime.now().millisecondsSinceEpoch.toString();
      String? imageUrl;

      if (isFile && imageFile != null) {
        imageUrl = await uploadImageToSupabase(imageFile!, examId);
        if (imageUrl == null) return;
      } else if (examImageUrlController.text.isNotEmpty) {
        imageUrl = examImageUrlController.text;
      }

      final exam = ExamModel(
        id: examId,
        courseId: courseNotifier.value!.id,
        title: examTitleController.text,
        description: examDescriptionController.text,
        timeLimit: int.parse(examDurationController.text) * 60,
        imageUrl: imageUrl,
        questions: questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final correctIndex = correctAnswerIndices[index];
          if (correctIndex == null) {
            throw Exception(
              'Please select correct answer for question ${index + 1}',
            );
          }

          final questionId = '${examId}_$index';

          final choices = List.generate(
            4,
            (i) => QuestionChoiceModel(
              questionId: questionId,
              identifier: String.fromCharCode(65 + i),
              choiceAnswer: choiceControllers[index][i].text,
            ),
          );

          final correctAnswer = String.fromCharCode(65 + correctIndex);

          return question.copyWith(
            id: questionId,
            questionText: questionControllers[index].text,
            choices: choices,
            correctAnswer: correctAnswer,
          );
        }).toList(),
      );
      await context.read<ExamCubit>().uploadExam(exam);
    }
  }

  bool showingDialog = false;

  @override
  void dispose() {
    courseController.dispose();
    courseNotifier.dispose();
    examTitleController.dispose();
    examDescriptionController.dispose();
    examImageUrlController.dispose();
    examDurationController.dispose();
    for (final controller in questionControllers) {
      controller.dispose();
    }
    for (final controllers in choiceControllers) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationWrapper(
      onNotificationSent: () {
        Navigator.of(context).pop();
      },
      child: BlocListener<ExamCubit, ExamState>(
        listener: (_, state) {
          if (showingDialog == true) {
            Navigator.pop(context);
            showingDialog = false;
          }
          if (state is UploadingExam) {
            CoreUtils.showLoadingDialog(context);
            showingDialog = true;
          } else if (state is ExamError) {
            CoreUtils.showSnackBar(context, state.message);
          } else if (state is ExamUploaded) {
            CoreUtils.showSnackBar(context, 'Exam uploaded successfully');
            CoreUtils.sendNotification(
              context,
              title: 'New ${courseNotifier.value!.title} exam',
              body: 'A new exam has been added for '
                  '${courseNotifier.value!.title}',
              category: NotificationCategory.TEST,
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(title: const Text('Add Exam UI')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Exam',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CoursePicker(
                      controller: courseController,
                      notifier: courseNotifier,
                    ),
                    const SizedBox(height: 20),
                    TitledInputField(
                      controller: examTitleController,
                      title: 'Exam Title',
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: examDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Exam Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter exam description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TitledInputField(
                      controller: examImageUrlController,
                      title: 'Exam Image',
                      required: false,
                      hintText: 'Enter Image URL or pick from gallery',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final image = await CoreUtils.pickImage();
                          if (image != null) {
                            setState(() {
                              isFile = true;
                              imageFile = image;
                              final imageName = image.path.split('/').last;
                              examImageUrlController.text = imageName;
                            });
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: examDurationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Question ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => removeQuestion(index),
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TitledInputField(
                                controller: questionControllers[index],
                                title: 'Question Text',
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(4, (i) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TitledInputField(
                                    controller: choiceControllers[index][i],
                                    title:
                                        'Choice ${String.fromCharCode(65 + i)}',
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                value: correctAnswerIndices[index],
                                decoration: const InputDecoration(
                                  labelText: 'Correct Answer',
                                  border: OutlineInputBorder(),
                                ),
                                items: List.generate(
                                  4,
                                  (i) => DropdownMenuItem(
                                    value: i,
                                    child: Text(
                                      'Choice ${String.fromCharCode(65 + i)}',
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      correctAnswerIndices[index] = value;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select the correct answer';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: addQuestion,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Question'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.grey.shade800,
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: uploadExam,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Upload Exam'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
