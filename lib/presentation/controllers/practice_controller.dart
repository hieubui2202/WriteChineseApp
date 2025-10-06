import 'dart:math';

import 'package:get/get.dart';

import '../../core/services/audio_service.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/lesson_unit.dart';
import 'progress_controller.dart';

enum PracticeStep {
  intro,
  listenChoice,
  meaningChoice,
  writing,
  missingStroke,
  result,
}

class PracticeController extends GetxController {
  PracticeController({required this.progressController, AudioService? audioService})
      : _audioService = audioService ?? AudioService();

  final ProgressController progressController;
  final AudioService _audioService;

  final Rxn<LessonUnit> currentUnit = Rxn<LessonUnit>();
  final Rxn<Character> currentCharacter = Rxn<Character>();
  final Rx<PracticeStep> step = PracticeStep.intro.obs;
  final RxInt score = 0.obs;
  final RxBool isCorrect = false.obs;
  final RxList<String> listenOptions = <String>[].obs;
  final RxList<String> meaningOptions = <String>[].obs;

  final Random _random = Random();

  void startLesson(LessonUnit unit, Character character) {
    currentUnit.value = unit;
    currentCharacter.value = character;
    step.value = PracticeStep.intro;
    score.value = 0;
    isCorrect.value = false;
    listenOptions.assignAll(_generatePinyinOptions(character));
    meaningOptions.assignAll(_generateMeaningOptions(character));
  }

  Future<void> playAudio() async {
    final character = currentCharacter.value;
    if (character == null) return;
    await _audioService.play(character.ttsUrl);
  }

  void goToNextStep() {
    switch (step.value) {
      case PracticeStep.intro:
        step.value = PracticeStep.listenChoice;
        break;
      case PracticeStep.listenChoice:
        step.value = PracticeStep.meaningChoice;
        break;
      case PracticeStep.meaningChoice:
        step.value = PracticeStep.writing;
        break;
      case PracticeStep.writing:
        step.value = PracticeStep.missingStroke;
        break;
      case PracticeStep.missingStroke:
        step.value = PracticeStep.result;
        break;
      case PracticeStep.result:
        _completeLesson();
        break;
    }
  }

  void checkListenAnswer(String answer) {
    final character = currentCharacter.value;
    if (character == null) return;
    final correct = answer == character.pinyin;
    if (correct) {
      score.value += 20;
    }
    isCorrect.value = correct;
    goToNextStep();
  }

  void checkMeaningAnswer(String answer) {
    final character = currentCharacter.value;
    if (character == null) return;
    final correct = answer == character.meaning;
    if (correct) {
      score.value += 20;
    }
    isCorrect.value = correct;
    goToNextStep();
  }

  void completeWriting({required bool success}) {
    if (success) {
      score.value += 40;
    }
    isCorrect.value = success;
    goToNextStep();
  }

  void completeMissingStroke({required bool success}) {
    if (success) {
      score.value += 20;
    }
    isCorrect.value = success;
    step.value = PracticeStep.result;
    _completeLesson();
  }

  void _completeLesson() {
    final unit = currentUnit.value;
    final character = currentCharacter.value;
    if (unit == null || character == null) {
      return;
    }
    final clampedScore = score.value.clamp(0, 100);
    progressController.recordResult(
      character: character,
      unitId: unit.id,
      score: clampedScore,
      success: clampedScore >= 60,
    );
  }

  List<String> _generatePinyinOptions(Character character) {
    final characters = progressController.characters;
    final choices = <String>{character.pinyin};
    while (choices.length < 3 && characters.isNotEmpty) {
      final randomChar = characters[_random.nextInt(characters.length)];
      choices.add(randomChar.pinyin);
    }
    final list = choices.toList()..shuffle(_random);
    return list;
  }

  List<String> _generateMeaningOptions(Character character) {
    final characters = progressController.characters;
    final choices = <String>{character.meaning};
    while (choices.length < 3 && characters.isNotEmpty) {
      final randomChar = characters[_random.nextInt(characters.length)];
      choices.add(randomChar.meaning);
    }
    final list = choices.toList()..shuffle(_random);
    return list;
  }

  @override
  void onClose() {
    _audioService.dispose();
    super.onClose();
  }
}
