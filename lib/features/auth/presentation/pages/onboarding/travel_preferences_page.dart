import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';
import 'package:tourisme_app_flutter/core/services/localization_service.dart';

class TravelPreferencesPage extends StatefulWidget {
  const TravelPreferencesPage({Key? key}) : super(key: key);

  @override
  _TravelPreferencesPageState createState() => _TravelPreferencesPageState();
}

class _TravelPreferencesPageState extends State<TravelPreferencesPage> {
  PageController _pageController = PageController();
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};

  final List<Map<String, dynamic>> questions = [
    {
      'id': 'duration',
      'title': 'duration_question',
      'type': 'slider',
      'icon': Icons.calendar_today,
      'minValue': 1.0,
      'maxValue': 7.0,
      'defaultValue': 1.0,
      'unit': 'duration_unit'
    },
    {
      'id': 'budget',
      'title': 'budget_question',
      'type': 'single_choice',
      'icon': Icons.attach_money,
      'options': [
        {'value': 'budget', 'label': 'budget_economic', 'color': Colors.blue},
        {'value': 'moderate', 'label': 'budget_moderate', 'color': Colors.blue},
        {'value': 'luxury', 'label': 'budget_luxury', 'color': Colors.blue},
      ]
    },
    {
      'id': 'activities',
      'title': 'activities_question',
      'type': 'multiple_choice',
      'icon': Icons.local_activity,
      'options': [
        {'value': 'culture', 'label': 'activity_culture', 'color': Colors.blue},
        {'value': 'nature', 'label': 'activity_nature', 'color': Colors.blue},
        {'value': 'beach', 'label': 'activity_beach', 'color': Colors.blue},
        {'value': 'adventure', 'label': 'activity_adventure', 'color': Colors.blue},
        {'value': 'nightlife', 'label': 'activity_nightlife', 'color': Colors.blue},
        {'value': 'gastronomy', 'label': 'activity_gastronomy', 'color': Colors.blue},
      ]
    },
    {
      'id': 'accommodation',
      'title': 'accommodation_question',
      'type': 'single_choice',
      'icon': Icons.hotel,
      'options': [
        {'value': 'hotel', 'label': 'accommodation_hotel', 'color': Colors.blue},
        {'value': 'hostel', 'label': 'accommodation_hostel', 'color': Colors.blue},
        {'value': 'airbnb', 'label': 'accommodation_airbnb', 'color': Colors.blue},
        {'value': 'camping', 'label': 'accommodation_camping', 'color': Colors.blue},
      ]
    },
    {
      'id': 'group_size',
      'title': 'group_size_question',
      'type': 'single_choice',
      'icon': Icons.group,
      'options': [
        {'value': 'solo', 'label': 'group_solo', 'color': Colors.blue},
        {'value': 'couple', 'label': 'group_couple', 'color': Colors.blue},
        {'value': 'family', 'label': 'group_family', 'color': Colors.blue},
        {'value': 'friends', 'label': 'group_friends', 'color': Colors.blue},
      ]
    }
  ];

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
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
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitAnswers() {
    print('Answers collected: $answers');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationService().translate('preferences_saved')),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    AppRoutes.navigateToHome(context);
  }

  Widget _buildSliderQuestion(Map<String, dynamic> question) {
    double currentValue = answers[question['id']] ?? question['defaultValue'];

    return Column(
      children: [
        Icon(question['icon'], size: 48, color: Colors.blue),
        SizedBox(height: 20),
        Text(
          LocalizationService().translate(question['title']),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Text(
                '${LocalizationService().translate('duration_unit')} ${currentValue.round()}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue),
              ),
              SizedBox(height: 20),
              Slider(
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleChoiceQuestion(Map<String, dynamic> question) {
    return Column(
      children: [
        Icon(question['icon'], size: 48, color: Colors.blue),
        SizedBox(height: 20),
        Text(
          LocalizationService().translate(question['title']),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        ...question['options'].map<Widget>((option) {
          bool isSelected = answers[question['id']] == option['value'];
          return Container(
            margin: EdgeInsets.only(bottom: 15),
            child: InkWell(
              onTap: () {
                setState(() {
                  answers[question['id']] = option['value'];
                });
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? option['color'].withOpacity(0.2) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? option['color'] : Colors.transparent,
                    width: 2,
                  ),
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
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        LocalizationService().translate(option['label']),
                        style: TextStyle(
                          fontSize: 16,
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
      ],
    );
  }

  Widget _buildMultipleChoiceQuestion(Map<String, dynamic> question) {
    List<String> selectedOptions = answers[question['id']] ?? [];

    return Column(
      children: [
        Icon(question['icon'], size: 48, color: Colors.blue),
        SizedBox(height: 20),
        Text(
          LocalizationService().translate(question['title']),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          LocalizationService().translate('multiple_choice_instruction'),
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        ...question['options'].map<Widget>((option) {
          bool isSelected = selectedOptions.contains(option['value']);
          return Container(
            margin: EdgeInsets.only(bottom: 15),
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
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? option['color'].withOpacity(0.2) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? option['color'] : Colors.transparent,
                    width: 2,
                  ),
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
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        LocalizationService().translate(option['label']),
                        style: TextStyle(
                          fontSize: 16,
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
      ],
    );
  }

  Widget _buildQuestionContent(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'slider':
        return _buildSliderQuestion(question);
      case 'single_choice':
        return _buildSingleChoiceQuestion(question);
      case 'multiple_choice':
        return _buildMultipleChoiceQuestion(question);
      default:
        return Container();
    }
  }

  bool _canProceed() {
    String questionId = questions[currentQuestionIndex]['id'];
    return answers.containsKey(questionId) && answers[questionId] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: currentQuestionIndex > 0 ? _previousQuestion : () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationService().translate('travel_preferences_title'),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${currentQuestionIndex + 1} of ${questions.length}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
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
                  padding: EdgeInsets.all(20),
                  child: _buildQuestionContent(questions[index]),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                if (currentQuestionIndex < questions.length - 1)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        AppRoutes.navigateToHome(context);
                      },
                      child: Text(LocalizationService().translate('skip_button'), style: TextStyle(color: Colors.grey[600])),
                    ),
                  )
                else
                  Spacer(),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      currentQuestionIndex < questions.length - 1
                          ? LocalizationService().translate('next_button')
                          : LocalizationService().translate('finish_button'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}