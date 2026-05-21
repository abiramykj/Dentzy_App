import 'package:flutter/widgets.dart';

import 'quiz_assessment_localizations_en.dart';
import 'quiz_assessment_localizations_ta.dart';

class QuizAssessmentLocalizations {
  final String languageCode;

  const QuizAssessmentLocalizations._(this.languageCode);

  factory QuizAssessmentLocalizations.of(BuildContext context) {
    return QuizAssessmentLocalizations._(Localizations.localeOf(context).languageCode);
  }

  bool get isTamil => languageCode == 'ta';

  Map<String, String> get _strings => isTamil ? quizAssessmentStringsTa : quizAssessmentStringsEn;

  String text(String key) => _strings[key] ?? quizAssessmentStringsEn[key] ?? key;

  String questionNumber(int number, int total) {
    return isTamil ? 'கேள்வி $number/$total' : 'Question $number of $total';
  }

  String scoreLine(int score, int maxScore) {
    return isTamil ? 'மதிப்பெண்: $score / $maxScore' : 'Score: $score / $maxScore';
  }

  String categoryLine(String categoryKey) {
    return '${text('category_label')}: ${text(categoryKey)}';
  }

  String optionLabel(String optionKey) => text(optionKey);

  String questionLabel(String questionKey) => text(questionKey);

  String localizedPdfFilename() => text('pdf_export_filename');
}