class QuizAssessmentQuestion {
  final String id;
  final String categoryKey;
  final String questionKey;
  final List<QuizAssessmentOption> options;
  final Map<String, QuizAssessmentFeedback> feedbackByOptionId;

  const QuizAssessmentQuestion({
    required this.id,
    required this.categoryKey,
    required this.questionKey,
    required this.options,
    required this.feedbackByOptionId,
  });
}

class QuizAssessmentOption {
  final String id;
  final String textKey;
  final int score;

  const QuizAssessmentOption({
    required this.id,
    required this.textKey,
    required this.score,
  });
}

class QuizAssessmentFeedback {
  final String issueKey;
  final String detailKey;
  final String solutionKey;

  const QuizAssessmentFeedback({
    required this.issueKey,
    required this.detailKey,
    required this.solutionKey,
  });
}

const List<QuizAssessmentQuestion> quizAssessmentQuestions = [
  QuizAssessmentQuestion(
    id: 'brushing_frequency',
    categoryKey: 'category_brushing_frequency',
    questionKey: 'question_brushing_frequency',
    options: [
      QuizAssessmentOption(id: 'once', textKey: 'option_once', score: 1),
      QuizAssessmentOption(id: 'twice', textKey: 'option_twice', score: 5),
      QuizAssessmentOption(id: 'more_than_twice', textKey: 'option_more_than_twice', score: 4),
    ],
    feedbackByOptionId: {
      'once': QuizAssessmentFeedback(
        issueKey: 'feedback_brushing_once_issue',
        detailKey: 'feedback_brushing_once_detail',
        solutionKey: 'feedback_brushing_once_solution',
      ),
      'twice': QuizAssessmentFeedback(
        issueKey: 'feedback_brushing_twice_issue',
        detailKey: 'feedback_brushing_twice_detail',
        solutionKey: 'feedback_brushing_twice_solution',
      ),
      'more_than_twice': QuizAssessmentFeedback(
        issueKey: 'feedback_brushing_more_than_twice_issue',
        detailKey: 'feedback_brushing_more_than_twice_detail',
        solutionKey: 'feedback_brushing_more_than_twice_solution',
      ),
    },
  ),
  QuizAssessmentQuestion(
    id: 'cleaning_method',
    categoryKey: 'category_cleaning_method',
    questionKey: 'question_cleaning_method',
    options: [
      QuizAssessmentOption(id: 'fluoride_toothpaste', textKey: 'option_fluoride_toothpaste', score: 5),
      QuizAssessmentOption(id: 'neem_stick_only', textKey: 'option_neem_stick_only', score: 2),
      QuizAssessmentOption(id: 'ash_or_charcoal', textKey: 'option_ash_or_charcoal', score: 1),
      QuizAssessmentOption(id: 'salt_only', textKey: 'option_salt_only', score: 2),
    ],
    feedbackByOptionId: {
      'fluoride_toothpaste': QuizAssessmentFeedback(
        issueKey: 'feedback_cleaning_fluoride_issue',
        detailKey: 'feedback_cleaning_fluoride_detail',
        solutionKey: 'feedback_cleaning_fluoride_solution',
      ),
      'neem_stick_only': QuizAssessmentFeedback(
        issueKey: 'feedback_cleaning_neem_issue',
        detailKey: 'feedback_cleaning_neem_detail',
        solutionKey: 'feedback_cleaning_neem_solution',
      ),
      'ash_or_charcoal': QuizAssessmentFeedback(
        issueKey: 'feedback_cleaning_ash_issue',
        detailKey: 'feedback_cleaning_ash_detail',
        solutionKey: 'feedback_cleaning_ash_solution',
      ),
      'salt_only': QuizAssessmentFeedback(
        issueKey: 'feedback_cleaning_salt_issue',
        detailKey: 'feedback_cleaning_salt_detail',
        solutionKey: 'feedback_cleaning_salt_solution',
      ),
    },
  ),
  QuizAssessmentQuestion(
    id: 'between_teeth_cleaning',
    categoryKey: 'category_between_teeth_cleaning',
    questionKey: 'question_between_teeth_cleaning',
    options: [
      QuizAssessmentOption(id: 'daily', textKey: 'option_daily', score: 5),
      QuizAssessmentOption(id: 'sometimes', textKey: 'option_sometimes', score: 3),
      QuizAssessmentOption(id: 'never', textKey: 'option_never', score: 1),
    ],
    feedbackByOptionId: {
      'daily': QuizAssessmentFeedback(
        issueKey: 'feedback_flossing_daily_issue',
        detailKey: 'feedback_flossing_daily_detail',
        solutionKey: 'feedback_flossing_daily_solution',
      ),
      'sometimes': QuizAssessmentFeedback(
        issueKey: 'feedback_flossing_sometimes_issue',
        detailKey: 'feedback_flossing_sometimes_detail',
        solutionKey: 'feedback_flossing_sometimes_solution',
      ),
      'never': QuizAssessmentFeedback(
        issueKey: 'feedback_flossing_never_issue',
        detailKey: 'feedback_flossing_never_detail',
        solutionKey: 'feedback_flossing_never_solution',
      ),
    },
  ),
  QuizAssessmentQuestion(
    id: 'dental_visits',
    categoryKey: 'category_dental_visits',
    questionKey: 'question_dental_visits',
    options: [
      QuizAssessmentOption(id: 'every_6_months', textKey: 'option_every_6_months', score: 5),
      QuizAssessmentOption(id: 'once_a_year', textKey: 'option_once_a_year', score: 4),
      QuizAssessmentOption(id: 'only_when_pain', textKey: 'option_only_when_pain', score: 2),
      QuizAssessmentOption(id: 'rarely_or_never', textKey: 'option_rarely_or_never', score: 1),
    ],
    feedbackByOptionId: {
      'every_6_months': QuizAssessmentFeedback(
        issueKey: 'feedback_dental_6m_issue',
        detailKey: 'feedback_dental_6m_detail',
        solutionKey: 'feedback_dental_6m_solution',
      ),
      'once_a_year': QuizAssessmentFeedback(
        issueKey: 'feedback_dental_year_issue',
        detailKey: 'feedback_dental_year_detail',
        solutionKey: 'feedback_dental_year_solution',
      ),
      'only_when_pain': QuizAssessmentFeedback(
        issueKey: 'feedback_dental_pain_issue',
        detailKey: 'feedback_dental_pain_detail',
        solutionKey: 'feedback_dental_pain_solution',
      ),
      'rarely_or_never': QuizAssessmentFeedback(
        issueKey: 'feedback_dental_rare_issue',
        detailKey: 'feedback_dental_rare_detail',
        solutionKey: 'feedback_dental_rare_solution',
      ),
    },
  ),
  QuizAssessmentQuestion(
    id: 'sugar_exposure',
    categoryKey: 'category_sugar_exposure',
    questionKey: 'question_sugar_exposure',
    options: [
      QuizAssessmentOption(id: 'rarely', textKey: 'option_rarely', score: 5),
      QuizAssessmentOption(id: 'moderate', textKey: 'option_1_2_times_a_day', score: 3),
      QuizAssessmentOption(id: 'high', textKey: 'option_many_times_a_day', score: 1),
    ],
    feedbackByOptionId: {
      'rarely': QuizAssessmentFeedback(
        issueKey: 'feedback_sugar_rarely_issue',
        detailKey: 'feedback_sugar_rarely_detail',
        solutionKey: 'feedback_sugar_rarely_solution',
      ),
      'moderate': QuizAssessmentFeedback(
        issueKey: 'feedback_sugar_moderate_issue',
        detailKey: 'feedback_sugar_moderate_detail',
        solutionKey: 'feedback_sugar_moderate_solution',
      ),
      'high': QuizAssessmentFeedback(
        issueKey: 'feedback_sugar_high_issue',
        detailKey: 'feedback_sugar_high_detail',
        solutionKey: 'feedback_sugar_high_solution',
      ),
    },
  ),
  QuizAssessmentQuestion(
    id: 'night_brushing',
    categoryKey: 'category_night_brushing',
    questionKey: 'question_night_brushing',
    options: [
      QuizAssessmentOption(id: 'always', textKey: 'option_always', score: 5),
      QuizAssessmentOption(id: 'sometimes', textKey: 'option_sometimes', score: 3),
      QuizAssessmentOption(id: 'never', textKey: 'option_never', score: 1),
    ],
    feedbackByOptionId: {
      'always': QuizAssessmentFeedback(
        issueKey: 'feedback_night_always_issue',
        detailKey: 'feedback_night_always_detail',
        solutionKey: 'feedback_night_always_solution',
      ),
      'sometimes': QuizAssessmentFeedback(
        issueKey: 'feedback_night_sometimes_issue',
        detailKey: 'feedback_night_sometimes_detail',
        solutionKey: 'feedback_night_sometimes_solution',
      ),
      'never': QuizAssessmentFeedback(
        issueKey: 'feedback_night_never_issue',
        detailKey: 'feedback_night_never_detail',
        solutionKey: 'feedback_night_never_solution',
      ),
    },
  ),
  QuizAssessmentQuestion(
    id: 'toothbrush_care',
    categoryKey: 'category_toothbrush_care',
    questionKey: 'question_toothbrush_care',
    options: [
      QuizAssessmentOption(id: 'every_3_months', textKey: 'option_every_3_months', score: 5),
      QuizAssessmentOption(id: 'every_6_months', textKey: 'option_every_6_months_long', score: 3),
      QuizAssessmentOption(id: 'damaged', textKey: 'option_only_when_pain', score: 1),
    ],
    feedbackByOptionId: {
      'every_3_months': QuizAssessmentFeedback(
        issueKey: 'feedback_toothbrush_3m_issue',
        detailKey: 'feedback_toothbrush_3m_detail',
        solutionKey: 'feedback_toothbrush_3m_solution',
      ),
      'every_6_months': QuizAssessmentFeedback(
        issueKey: 'feedback_toothbrush_6m_issue',
        detailKey: 'feedback_toothbrush_6m_detail',
        solutionKey: 'feedback_toothbrush_6m_solution',
      ),
      'damaged': QuizAssessmentFeedback(
        issueKey: 'feedback_toothbrush_damaged_issue',
        detailKey: 'feedback_toothbrush_damaged_detail',
        solutionKey: 'feedback_toothbrush_damaged_solution',
      ),
    },
  ),
  QuizAssessmentQuestion(
    id: 'mouthwash_use',
    categoryKey: 'category_mouthwash_use',
    questionKey: 'question_mouthwash_use',
    options: [
      QuizAssessmentOption(id: 'yes_as_advised', textKey: 'option_yes_as_advised', score: 4),
      QuizAssessmentOption(id: 'sometimes', textKey: 'option_sometimes', score: 3),
      QuizAssessmentOption(id: 'no', textKey: 'option_no', score: 2),
    ],
    feedbackByOptionId: {
      'yes_as_advised': QuizAssessmentFeedback(
        issueKey: 'feedback_mouthwash_yes_issue',
        detailKey: 'feedback_mouthwash_yes_detail',
        solutionKey: 'feedback_mouthwash_yes_solution',
      ),
      'sometimes': QuizAssessmentFeedback(
        issueKey: 'feedback_mouthwash_sometimes_issue',
        detailKey: 'feedback_mouthwash_sometimes_detail',
        solutionKey: 'feedback_mouthwash_sometimes_solution',
      ),
      'no': QuizAssessmentFeedback(
        issueKey: 'feedback_mouthwash_no_issue',
        detailKey: 'feedback_mouthwash_no_detail',
        solutionKey: 'feedback_mouthwash_no_solution',
      ),
    },
  ),
  QuizAssessmentQuestion(
    id: 'after_meal_care',
    categoryKey: 'category_after_meal_care',
    questionKey: 'question_after_meal_care',
    options: [
      QuizAssessmentOption(id: 'rinse_or_brush', textKey: 'option_rinse_or_brush_soon_after', score: 5),
      QuizAssessmentOption(id: 'water_only', textKey: 'option_drink_water_only', score: 3),
      QuizAssessmentOption(id: 'nothing', textKey: 'option_do_nothing', score: 1),
    ],
    feedbackByOptionId: {
      'rinse_or_brush': QuizAssessmentFeedback(
        issueKey: 'feedback_aftermeal_rinse_issue',
        detailKey: 'feedback_aftermeal_rinse_detail',
        solutionKey: 'feedback_aftermeal_rinse_solution',
      ),
      'water_only': QuizAssessmentFeedback(
        issueKey: 'feedback_aftermeal_water_issue',
        detailKey: 'feedback_aftermeal_water_detail',
        solutionKey: 'feedback_aftermeal_water_solution',
      ),
      'nothing': QuizAssessmentFeedback(
        issueKey: 'feedback_aftermeal_none_issue',
        detailKey: 'feedback_aftermeal_none_detail',
        solutionKey: 'feedback_aftermeal_none_solution',
      ),
    },
  ),
  QuizAssessmentQuestion(
    id: 'tobacco_exposure',
    categoryKey: 'category_tobacco_exposure',
    questionKey: 'question_tobacco_exposure',
    options: [
      QuizAssessmentOption(id: 'no', textKey: 'option_no', score: 5),
      QuizAssessmentOption(id: 'occasional', textKey: 'option_occasional', score: 2),
      QuizAssessmentOption(id: 'regular', textKey: 'option_yes_regularly', score: 1),
    ],
    feedbackByOptionId: {
      'no': QuizAssessmentFeedback(
        issueKey: 'feedback_tobacco_no_issue',
        detailKey: 'feedback_tobacco_no_detail',
        solutionKey: 'feedback_tobacco_no_solution',
      ),
      'occasional': QuizAssessmentFeedback(
        issueKey: 'feedback_tobacco_occasional_issue',
        detailKey: 'feedback_tobacco_occasional_detail',
        solutionKey: 'feedback_tobacco_occasional_solution',
      ),
      'regular': QuizAssessmentFeedback(
        issueKey: 'feedback_tobacco_regular_issue',
        detailKey: 'feedback_tobacco_regular_detail',
        solutionKey: 'feedback_tobacco_regular_solution',
      ),
    },
  ),
];