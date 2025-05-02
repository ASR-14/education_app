import 'package:education_app/core/common/widgets/course_picker.dart';
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
      final exam = ExamModel(
        id: '',
        courseId: courseNotifier.value!.id,
        title: examTitleController.text,
        description: examDescriptionController.text,
        timeLimit: int.parse(examDurationController.text) * 60,
        imageUrl: examImageUrlController.text.isEmpty
            ? null
            : examImageUrlController.text,
        questions: questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final correctIndex = correctAnswerIndices[index];
          if (correctIndex == null) {
            throw Exception(
              'Please select correct answer for question ${index + 1}',
            );
          }

          final questionId =
              DateTime.now().millisecondsSinceEpoch.toString() + '_$index';

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
                    CoursePicker(
                      controller: courseController,
                      notifier: courseNotifier,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: examTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Exam Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter exam title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: examDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Exam Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter exam description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: examImageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Exam Image URL (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Questions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: addQuestion,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Question'),
                        ),
                      ],
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
                              TextFormField(
                                controller: questionControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Question Text',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter question text';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(4, (i) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                    controller: choiceControllers[index][i],
                                    decoration: InputDecoration(
                                      labelText:
                                          'Choice ${String.fromCharCode(65 + i)}',
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter choice text';
                                      }
                                      return null;
                                    },
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: uploadExam,
                        child: const Text('Upload Exam'),
                      ),
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
