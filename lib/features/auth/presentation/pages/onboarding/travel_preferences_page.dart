import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';
import 'package:tourisme_app_flutter/core/services/localization_service.dart';

class TravelPreferencesPage extends StatefulWidget {
  const TravelPreferencesPage({Key? key}) : super(key: key);

  @override
  _TravelPreferencesPageState createState() => _TravelPreferencesPageState();
}

class _TravelPreferencesPageState extends State<TravelPreferencesPage> {
  late PageController _pageController;
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};
  final LocalizationService _localization = LocalizationService();

  List<Map<String, dynamic>> get questions => [
    {
      'id': 'duration',
      'title': _localization.translate('duration_question_title'),
      'type': 'slider',
      'icon': Icons.calendar_today,
      'minValue': 1.0,
      'maxValue': 7.0,
      'defaultValue': 3.0,
      'unit': _localization.translate('duration_unit')
    },
    {
      'id': 'budget',
      'title': _localization.translate('budget_question_title'),
      'type': 'single_choice',
      'icon': Icons.attach_money,
      'options': [
        {
          'value': 'budget',
          'label': _localization.translate('budget_friendly'),
          'color': Colors.blue
        },
        {
          'value': 'moderate',
          'label': _localization.translate('budget_moderate'),
          'color': Colors.blue
        },
        {
          'value': 'luxury',
          'label': _localization.translate('budget_luxury'),
          'color': Colors.blue
        },
      ]
    },
    {
      'id': 'transportation',
      'title': _localization.translate('transportation_question_title'),
      'type': 'multiple_choice',
      'icon': Icons.directions,
      'options': [
        {
          'value': 'flight',
          'label': _localization.translate('transportation_flight'),
          'color': Colors.blue
        },
        {
          'value': 'car_rental',
          'label': _localization.translate('transportation_car_rental'),
          'color': Colors.blue
        },
        {
          'value': 'private_driver',
          'label': _localization.translate('transportation_private_driver'),
          'color': Colors.blue
        },
        {
          'value': 'public_transport',
          'label': _localization.translate('transportation_public_transport'),
          'color': Colors.blue
        },
        {
          'value': 'train',
          'label': _localization.translate('transportation_train'),
          'color': Colors.blue
        },
        {
          'value': 'taxi_ride_share',
          'label': _localization.translate('transportation_taxi_ride_share'),
          'color': Colors.blue
        },
        {
          'value': 'bicycle',
          'label': _localization.translate('transportation_bicycle'),
          'color': Colors.blue
        },
        {
          'value': 'walking',
          'label': _localization.translate('transportation_walking'),
          'color': Colors.blue
        },
      ]
    },
    {
      'id': 'accommodation_type',
      'title': _localization.translate('accommodation_question_title'),
      'type': 'multiple_choice',
      'icon': Icons.hotel,
      'options': [
        {
          'value': 'luxury_hotel',
          'label': _localization.translate('accommodation_luxury_hotel'),
          'color': Colors.blue
        },
        {
          'value': 'boutique_hotel',
          'label': _localization.translate('accommodation_boutique_hotel'),
          'color': Colors.blue
        },
        {
          'value': 'business_hotel',
          'label': _localization.translate('accommodation_business_hotel'),
          'color': Colors.blue
        },
        {
          'value': 'budget_hotel',
          'label': _localization.translate('accommodation_budget_hotel'),
          'color': Colors.blue
        },
        {
          'value': 'resort',
          'label': _localization.translate('accommodation_resort'),
          'color': Colors.blue
        },
        {
          'value': 'riad',
          'label': _localization.translate('accommodation_riad'),
          'color': Colors.blue
        },
        {
          'value': 'guesthouse',
          'label': _localization.translate('accommodation_guesthouse'),
          'color': Colors.blue
        },
        {
          'value': 'airbnb',
          'label': _localization.translate('accommodation_airbnb'),
          'color': Colors.blue
        },
        {
          'value': 'hostel',
          'label': _localization.translate('accommodation_hostel'),
          'color': Colors.blue
        },
        {
          'value': 'camping',
          'label': _localization.translate('accommodation_camping'),
          'color': Colors.blue
        },
        {
          'value': 'apartment',
          'label': _localization.translate('accommodation_apartment'),
          'color': Colors.blue
        },
        {
          'value': 'villa',
          'label': _localization.translate('accommodation_villa'),
          'color': Colors.blue
        },
      ]
    },
    {
      'id': 'activities',
      'title': _localization.translate('activities_question_title'),
      'type': 'multiple_choice',
      'icon': Icons.local_activity,
      'options': [
        {
          'value': 'culture_history',
          'label': _localization.translate('activity_culture_history'),
          'color': Colors.blue
        },
        {
          'value': 'nature_wildlife',
          'label': _localization.translate('activity_nature_wildlife'),
          'color': Colors.blue
        },
        {
          'value': 'beach_water',
          'label': _localization.translate('activity_beach_water'),
          'color': Colors.blue
        },
        {
          'value': 'adventure_sports',
          'label': _localization.translate('activity_adventure_sports'),
          'color': Colors.blue
        },
        {
          'value': 'nightlife_entertainment',
          'label': _localization.translate('activity_nightlife_entertainment'),
          'color': Colors.blue
        },
        {
          'value': 'food_gastronomy',
          'label': _localization.translate('activity_food_gastronomy'),
          'color': Colors.blue
        },
        {
          'value': 'shopping',
          'label': _localization.translate('activity_shopping'),
          'color': Colors.blue
        },
        {
          'value': 'wellness_spa',
          'label': _localization.translate('activity_wellness_spa'),
          'color': Colors.blue
        },
      ]
    },
    {
      'id': 'group_size',
      'title': _localization.translate('group_size_question_title'),
      'type': 'single_choice',
      'icon': Icons.group,
      'options': [
        {
          'value': 'solo',
          'label': _localization.translate('group_solo'),
          'color': Colors.blue
        },
        {
          'value': 'couple',
          'label': _localization.translate('group_couple'),
          'color': Colors.blue
        },
        {
          'value': 'family_kids',
          'label': _localization.translate('group_family_kids'),
          'color': Colors.blue
        },
        {
          'value': 'family_adults',
          'label': _localization.translate('group_family_adults'),
          'color': Colors.blue
        },
        {
          'value': 'friends_small',
          'label': _localization.translate('group_friends_small'),
          'color': Colors.blue
        },
        {
          'value': 'friends_large',
          'label': _localization.translate('group_friends_large'),
          'color': Colors.blue
        },
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _localization.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    setState(() {
      // Reconstructire la page avec les nouvelles traductions
    });
  }

  void _nextQuestion() {
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
    print('Answers collected: $answers');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_localization.translate('preferences_saved_success')),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }

  Widget _buildSliderQuestion(Map<String, dynamic> question, double screenWidth) {
    double currentValue = answers[question['id']] ?? question['defaultValue'];
    final dimensions = _getResponsiveDimensions(screenWidth);
    return Column(
      children: [
        Icon(question['icon'], size: dimensions.iconSize, color: Colors.blue),
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
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: dimensions.verticalSpacing * 1.5),
        Container(
          width: dimensions.sliderContainerWidth,
          padding: EdgeInsets.all(dimensions.containerPadding),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentValue.round()} ${question['unit']}',
                  style: TextStyle(
                    fontSize: dimensions.valueFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: dimensions.sliderThumbRadius),
                  trackHeight: dimensions.sliderTrackHeight,
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                  thumbColor: Colors.blue,
                  activeTrackColor: Colors.blue,
                  inactiveTrackColor: Colors.grey[300],
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
                  activeColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleChoiceQuestion(Map<String, dynamic> question, double screenWidth) {
    final dimensions = _getResponsiveDimensions(screenWidth);
    return Column(
      children: [
        Icon(question['icon'], size: dimensions.iconSize, color: Colors.blue),
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
                      color: isSelected ? option['color'].withOpacity(0.2) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? option['color'] : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: option['color'].withOpacity(0.2),
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
                          activeColor: option['color'],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: dimensions.optionFontSize,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildMultipleChoiceQuestion(Map<String, dynamic> question, double screenWidth) {
    List<String> selectedOptions = answers[question['id']] ?? [];
    final dimensions = _getResponsiveDimensions(screenWidth);
    return Column(
      children: [
        Icon(question['icon'], size: dimensions.iconSize, color: Colors.blue),
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
            _localization.translate('multiple_choice_instruction'),
            style: TextStyle(
              fontSize: dimensions.instructionFontSize,
              color: Colors.grey[600],
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
                      color: isSelected ? option['color'].withOpacity(0.2) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? option['color'] : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: option['color'].withOpacity(0.2),
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
                          activeColor: option['color'],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: dimensions.optionFontSize,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildQuestionContent(Map<String, dynamic> question, double screenWidth) {
    switch (question['type']) {
      case 'slider':
        return _buildSliderQuestion(question, screenWidth);
      case 'single_choice':
        return _buildSingleChoiceQuestion(question, screenWidth);
      case 'multiple_choice':
        return _buildMultipleChoiceQuestion(question, screenWidth);
      default:
        return Container();
    }
  }

  bool _canProceed() {
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
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final dimensions = _getResponsiveDimensions(screenWidth);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: dimensions.iconSize * 0.6,
          ),
          onPressed: currentQuestionIndex > 0 ? _previousQuestion : () => Navigator.pop(context),
        ),
        title: Text(
          _localization.translate('travel_preferences_title'),
          style: TextStyle(
            color: Colors.black,
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
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentQuestionIndex + 1} ${_localization.translate('of')} ${questions.length}',
                          style: TextStyle(
                            color: Colors.blue[700],
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
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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
                    child: _buildQuestionContent(questions[index], screenWidth),
                  );
                },
              ),
            ),
            // Bottom Actions Section
            Container(
              padding: EdgeInsets.all(dimensions.containerPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                            _localization.translate('skip'),
                            style: TextStyle(
                              color: Colors.grey[600],
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
                        onPressed: _canProceed() ? _nextQuestion : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.grey[300],
                          padding: EdgeInsets.symmetric(
                            vertical: dimensions.verticalSpacing * 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _canProceed() ? 3 : 0,
                        ),
                        child: Text(
                          currentQuestionIndex < questions.length - 1
                              ? _localization.translate('Next')
                              : _localization.translate('finish'),
                          style: TextStyle(
                            fontSize: dimensions.optionFontSize * 1.1,
                            fontWeight: FontWeight.w600,
                            color: _canProceed() ? Colors.white : Colors.grey[600],
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
  }

  @override
  void dispose() {
    _localization.removeListener(_onLanguageChanged);
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