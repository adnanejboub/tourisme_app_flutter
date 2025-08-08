import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';
import 'package:tourisme_app_flutter/core/services/localization_service.dart';

class TravelPreferencesPage extends StatefulWidget {
  const TravelPreferencesPage({Key? key}) : super(key: key);

  @override
  _TravelPreferencesPageState createState() => _TravelPreferencesPageState();
}

class _TravelPreferencesPageState extends State<TravelPreferencesPage> {
  bool isDarkMode = false;
  late PageController _pageController;
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};

  List<Map<String, dynamic>> _buildQuestions(LocalizationService localization) => [
    {
      'id': 'duration',
      'title': localization.translate('duration_question_title'),
      'type': 'slider',
      'icon': Icons.calendar_today,
      'minValue': 1.0,
      'maxValue': 30.0,
      'defaultValue': 7.0,
      'unit': localization.translate('duration_unit')
    },
    {
      'id': 'budget',
      'title': localization.translate('budget_question_title'),
      'type': 'single_choice',
      'icon': Icons.attach_money,
      'options': [
        {
          'value': 'budget',
          'label': localization.translate('budget_friendly'),
        },
        {
          'value': 'moderate',
          'label': localization.translate('budget_moderate'),
        },
        {
          'value': 'luxury',
          'label': localization.translate('budget_luxury'),
        },
      ]
    },
    {
      'id': 'transportation',
      'title': localization.translate('transportation_question_title'),
      'type': 'multiple_choice',
      'icon': Icons.directions,
      'options': [
        {
          'value': 'flight',
          'label': localization.translate('transportation_flight'),
        },
        {
          'value': 'car_rental',
          'label': localization.translate('transportation_car_rental'),
        },
        {
          'value': 'private_driver',
          'label': localization.translate('transportation_private_driver'),
        },
        {
          'value': 'public_transport',
          'label': localization.translate('transportation_public_transport'),
        },
        {
          'value': 'train',
          'label': localization.translate('transportation_train'),
        },
        {
          'value': 'taxi_ride_share',
          'label': localization.translate('transportation_taxi_ride_share'),
        },
        {
          'value': 'bicycle',
          'label': localization.translate('transportation_bicycle'),
        },
        {
          'value': 'walking',
          'label': localization.translate('transportation_walking'),
        },
      ]
    },
    {
      'id': 'accommodation_type',
      'title': localization.translate('accommodation_question_title'),
      'type': 'multiple_choice',
      'icon': Icons.hotel,
      'options': [
        {
          'value': 'luxury_hotel',
          'label': localization.translate('accommodation_luxury_hotel'),
        },
        {
          'value': 'boutique_hotel',
          'label': localization.translate('accommodation_boutique_hotel'),
        },
        {
          'value': 'business_hotel',
          'label': localization.translate('accommodation_business_hotel'),
        },
        {
          'value': 'budget_hotel',
          'label': localization.translate('accommodation_budget_hotel'),
        },
        {
          'value': 'resort',
          'label': localization.translate('accommodation_resort'),
        },
        {
          'value': 'riad',
          'label': localization.translate('accommodation_riad'),
        },
        {
          'value': 'guesthouse',
          'label': localization.translate('accommodation_guesthouse'),
        },
        {
          'value': 'airbnb',
          'label': localization.translate('accommodation_airbnb'),
        },
        {
          'value': 'hostel',
          'label': localization.translate('accommodation_hostel'),
        },
        {
          'value': 'camping',
          'label': localization.translate('accommodation_camping'),
        },
        {
          'value': 'apartment',
          'label': localization.translate('accommodation_apartment'),
        },
        {
          'value': 'villa',
          'label': localization.translate('accommodation_villa'),
        },
      ]
    },
    {
      'id': 'activities',
      'title': localization.translate('activities_question_title'),
      'type': 'multiple_choice',
      'icon': Icons.local_activity,
      'options': [
        {
          'value': 'culture_history',
          'label': localization.translate('activity_culture_history'),
        },
        {
          'value': 'nature_wildlife',
          'label': localization.translate('activity_nature_wildlife'),
        },
        {
          'value': 'beach_water',
          'label': localization.translate('activity_beach_water'),
        },
        {
          'value': 'adventure_sports',
          'label': localization.translate('activity_adventure_sports'),
        },
        {
          'value': 'nightlife_entertainment',
          'label': localization.translate('activity_nightlife_entertainment'),
        },
        {
          'value': 'food_gastronomy',
          'label': localization.translate('activity_food_gastronomy'),
        },
        {
          'value': 'shopping',
          'label': localization.translate('activity_shopping'),
        },
        {
          'value': 'wellness_spa',
          'label': localization.translate('activity_wellness_spa'),
        },
      ]
    },
    {
      'id': 'group_size',
      'title': localization.translate('group_size_question_title'),
      'type': 'single_choice',
      'icon': Icons.group,
      'options': [
        {
          'value': 'solo',
          'label': localization.translate('group_solo'),
        },
        {
          'value': 'couple',
          'label': localization.translate('group_couple'),
        },
        {
          'value': 'family_kids',
          'label': localization.translate('group_family_kids'),
        },
        {
          'value': 'family_adults',
          'label': localization.translate('group_family_adults'),
        },
        {
          'value': 'friends_small',
          'label': localization.translate('group_friends_small'),
        },
        {
          'value': 'friends_large',
          'label': localization.translate('group_friends_large'),
        },
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _nextQuestion() {
    final questions = _buildQuestions(Provider.of<LocalizationService>(context, listen: false));
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitAnswers();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitAnswers() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    print('Answers collected: $answers');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localization.translate('preferences_saved_success')),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }

  Widget _buildSliderQuestion(Map<String, dynamic> question, double screenWidth, ColorScheme colorScheme) {
    double currentValue = answers[question['id']] ?? question['defaultValue'];
    final dimensions = _getResponsiveDimensions(screenWidth);
    return Column(
      children: [
        Icon(
          question['icon'],
          size: dimensions.iconSize,
          color: isDarkMode ? Colors.white70 : colorScheme.primary,
        ),
        SizedBox(height: dimensions.verticalSpacing),
        Container(
          constraints: BoxConstraints(
            maxWidth: dimensions.contentMaxWidth,
          ),
          child: Text(
            question['title'],
            style: TextStyle(
              fontSize: dimensions.titleFontSize,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: dimensions.verticalSpacing * 1.5),
        Container(
          width: dimensions.sliderContainerWidth,
          padding: EdgeInsets.all(dimensions.containerPadding),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentValue.round()} ${question['unit']}',
                  style: TextStyle(
                    fontSize: dimensions.valueFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: dimensions.sliderThumbRadius),
                  trackHeight: dimensions.sliderTrackHeight,
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                  thumbColor: colorScheme.primary,
                  activeTrackColor: colorScheme.primary,
                  inactiveTrackColor: colorScheme.outline,
                  overlayColor: Colors.transparent,
                ),
                child: Slider(
                  value: currentValue,
                  min: question['minValue'],
                  max: question['maxValue'],
                  divisions: (question['maxValue'] - question['minValue']).round(),
                  onChanged: (value) {
                    setState(() {
                      answers[question['id']] = value;
                    });
                  },
                  activeColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleChoiceQuestion(Map<String, dynamic> question, double screenWidth, ColorScheme colorScheme) {
    final dimensions = _getResponsiveDimensions(screenWidth);
    return Column(
      children: [
        Icon(
          question['icon'],
          size: dimensions.iconSize,
          color: isDarkMode ? Colors.white70 : colorScheme.primary,
        ),
        SizedBox(height: dimensions.verticalSpacing),
        Container(
          constraints: BoxConstraints(
            maxWidth: dimensions.contentMaxWidth,
          ),
          child: Text(
            question['title'],
            style: TextStyle(
              fontSize: dimensions.titleFontSize,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: dimensions.verticalSpacing * 1.5),
        Container(
          width: dimensions.optionsContainerWidth,
          child: Column(
            children: question['options'].map<Widget>((option) {
              bool isSelected = answers[question['id']] == option['value'];
              return Container(
                margin: EdgeInsets.only(bottom: dimensions.optionMargin),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      answers[question['id']] = option['value'];
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(dimensions.optionPadding),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : colorScheme.outline,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Radio(
                          value: option['value'],
                          groupValue: answers[question['id']],
                          onChanged: (value) {
                            setState(() {
                              answers[question['id']] = value;
                            });
                          },
                          activeColor: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: dimensions.optionFontSize,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceQuestion(Map<String, dynamic> question, double screenWidth, ColorScheme colorScheme, LocalizationService localization) {
    List<String> selectedOptions = answers[question['id']] ?? [];
    final dimensions = _getResponsiveDimensions(screenWidth);
    return Column(
      children: [
        Icon(
          question['icon'],
          size: dimensions.iconSize,
          color: isDarkMode ? Colors.white70 : colorScheme.primary,
        ),
        SizedBox(height: dimensions.verticalSpacing),
        Container(
          constraints: BoxConstraints(
            maxWidth: dimensions.contentMaxWidth,
          ),
          child: Text(
            question['title'],
            style: TextStyle(
              fontSize: dimensions.titleFontSize,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: dimensions.verticalSpacing * 0.5),
        Container(
          constraints: BoxConstraints(
            maxWidth: dimensions.contentMaxWidth,
          ),
          child: Text(
            localization.translate('multiple_choice_instruction'),
            style: TextStyle(
              fontSize: dimensions.instructionFontSize,
              color: colorScheme.onSurface.withOpacity(0.6),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: dimensions.verticalSpacing * 1.2),
        Container(
          width: dimensions.optionsContainerWidth,
          child: Column(
            children: question['options'].map<Widget>((option) {
              bool isSelected = selectedOptions.contains(option['value']);
              return Container(
                margin: EdgeInsets.only(bottom: dimensions.optionMargin),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      List<String> currentSelections = List<String>.from(selectedOptions);
                      if (isSelected) {
                        currentSelections.remove(option['value']);
                      } else {
                        currentSelections.add(option['value']);
                      }
                      answers[question['id']] = currentSelections;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(dimensions.optionPadding),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : colorScheme.outline,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              List<String> currentSelections = List<String>.from(selectedOptions);
                              if (value == true) {
                                currentSelections.add(option['value']);
                              } else {
                                currentSelections.remove(option['value']);
                              }
                              answers[question['id']] = currentSelections;
                            });
                          },
                          activeColor: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: dimensions.optionFontSize,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionContent(Map<String, dynamic> question, double screenWidth, ColorScheme colorScheme, LocalizationService localization) {
    switch (question['type']) {
      case 'slider':
        return _buildSliderQuestion(question, screenWidth, colorScheme);
      case 'single_choice':
        return _buildSingleChoiceQuestion(question, screenWidth, colorScheme);
      case 'multiple_choice':
        return _buildMultipleChoiceQuestion(question, screenWidth, colorScheme, localization);
      default:
        return Container();
    }
  }

  bool _canProceed(List<Map<String, dynamic>> questions) {
    String questionId = questions[currentQuestionIndex]['id'];
    if (questions[currentQuestionIndex]['type'] == 'slider') {
      return answers.containsKey(questionId) && answers[questionId] != null;
    } else {
      return answers.containsKey(questionId) && answers[questionId] != null && answers[questionId].isNotEmpty;
    }
  }

  _ResponsiveDimensions _getResponsiveDimensions(double screenWidth) {
    final scale = screenWidth / 375;
    return _ResponsiveDimensions(
      iconSize: (36 * scale).clamp(28.0, 56.0),
      titleFontSize: (20 * scale).clamp(16.0, 28.0),
      valueFontSize: (16 * scale).clamp(14.0, 20.0),
      optionFontSize: (14 * scale).clamp(12.0, 18.0),
      instructionFontSize: (12 * scale).clamp(10.0, 15.0),
      containerPadding: (16 * scale).clamp(12.0, 24.0),
      optionPadding: (14 * scale).clamp(10.0, 20.0),
      optionMargin: (10 * scale).clamp(8.0, 18.0),
      verticalSpacing: (16 * scale).clamp(12.0, 28.0),
      contentMaxWidth: (screenWidth * 0.95).clamp(300.0, 600.0),
      sliderContainerWidth: (screenWidth * 0.9).clamp(300.0, 450.0),
      optionsContainerWidth: (screenWidth * 0.95).clamp(300.0, 500.0),
      sliderThumbRadius: (10 * scale).clamp(8.0, 16.0),
      sliderTrackHeight: (4 * scale).clamp(3.0, 7.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localization, child) {
        isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final size = MediaQuery.of(context).size;
        final screenWidth = size.width;
        final dimensions = _getResponsiveDimensions(screenWidth);
        final colorScheme = Theme.of(context).colorScheme;
        final questions = _buildQuestions(localization);

        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            backgroundColor: colorScheme.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.onBackground,
                size: dimensions.iconSize * 0.6,
              ),
              onPressed: currentQuestionIndex > 0 ? _previousQuestion : () => Navigator.pop(context),
            ),
            title: Text(
              localization.translate('travel_preferences_title'),
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w600,
                fontSize: dimensions.titleFontSize * 0.8,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Progress Section
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: dimensions.containerPadding,
                    vertical: dimensions.verticalSpacing * 0.5,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${currentQuestionIndex + 1} ${localization.translate('of')} ${questions.length}',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: dimensions.instructionFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: dimensions.verticalSpacing * 0.5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (currentQuestionIndex + 1) / questions.length,
                          backgroundColor: colorScheme.outline,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          minHeight: dimensions.sliderTrackHeight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Questions Section
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentQuestionIndex = index;
                      });
                    },
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: dimensions.containerPadding,
                          vertical: dimensions.verticalSpacing,
                        ),
                        child: _buildQuestionContent(questions[index], screenWidth, colorScheme, localization),
                      );
                    },
                  ),
                ),
                // Bottom Actions Section
                Container(
                  padding: EdgeInsets.all(dimensions.containerPadding),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        if (currentQuestionIndex < questions.length - 1)
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: dimensions.verticalSpacing * 0.5,
                                ),
                              ),
                              child: Text(
                                localization.translate('skip'),
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: dimensions.optionFontSize,
                                ),
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _canProceed(questions) ? _nextQuestion : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
                              padding: EdgeInsets.symmetric(
                                vertical: dimensions.verticalSpacing * 0.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: _canProceed(questions) ? 3 : 0,
                            ),
                            child: Text(
                              currentQuestionIndex < questions.length - 1
                                  ? localization.translate('Next')
                                  : localization.translate('finish'),
                              style: TextStyle(
                                fontSize: dimensions.optionFontSize * 1.1,
                                fontWeight: FontWeight.w600,
                                color: _canProceed(questions) ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.38),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _ResponsiveDimensions {
  final double iconSize;
  final double titleFontSize;
  final double valueFontSize;
  final double optionFontSize;
  final double instructionFontSize;
  final double containerPadding;
  final double optionPadding;
  final double optionMargin;
  final double verticalSpacing;
  final double contentMaxWidth;
  final double sliderContainerWidth;
  final double optionsContainerWidth;
  final double sliderThumbRadius;
  final double sliderTrackHeight;

  _ResponsiveDimensions({
    required this.iconSize,
    required this.titleFontSize,
    required this.valueFontSize,
    required this.optionFontSize,
    required this.instructionFontSize,
    required this.containerPadding,
    required this.optionPadding,
    required this.optionMargin,
    required this.verticalSpacing,
    required this.contentMaxWidth,
    required this.sliderContainerWidth,
    required this.optionsContainerWidth,
    required this.sliderThumbRadius,
    required this.sliderTrackHeight,
  });
}