import 'package:flutter/material.dart';

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
      'title': 'How long do you plan to travel ?',
      'type': 'slider',
      'icon': Icons.calendar_today,
      'minValue': 1.0,
      'maxValue': 7.0,
      'defaultValue': 1.0,
      'unit': 'days'
    },
    {
      'id': 'budget',
      'title': 'What is your approximate budget ?',
      'type': 'single_choice',
      'icon': Icons.attach_money,
      'options': [
        {'value': 'budget', 'label': 'Economic (< 500 DH/day)', 'color': Colors.blue},
        {'value': 'moderate', 'label': 'Moderate (500-1500 DH/day)', 'color': Colors.blue},
        {'value': 'luxury', 'label': 'Luxurious (> 1500 DH/day)', 'color': Colors.blue},
      ]
    },
    {
      'id': 'activities',
      'title': 'What types of activities interest you ?',
      'type': 'multiple_choice',
      'icon': Icons.local_activity,
      'options': [
        {'value': 'culture', 'label': 'Culture & History', 'color': Colors.blue},
        {'value': 'nature', 'label': 'Nature & Hiking', 'color': Colors.blue},
        {'value': 'beach', 'label': 'Beach & Relaxation', 'color': Colors.blue},
        {'value': 'adventure', 'label': 'Sports & Adventure', 'color': Colors.blue},
        {'value': 'nightlife', 'label': 'Nightlife', 'color': Colors.blue},
        {'value': 'gastronomy', 'label': 'Gastronomy', 'color': Colors.blue},
      ]
    },
    {
      'id': 'accommodation',
      'title': 'What type of accommodation do you prefer ?',
      'type': 'single_choice',
      'icon': Icons.hotel,
      'options': [
        {'value': 'hotel', 'label': 'Hotel', 'color': Colors.blue},
        {'value': 'hostel', 'label': 'Youth hostel', 'color': Colors.blue},
        {'value': 'airbnb', 'label': 'Airbnb/Rental', 'color': Colors.blue},
        {'value': 'camping', 'label': 'Camping', 'color': Colors.blue},
      ]
    },
    {
      'id': 'group_size',
      'title': 'Who are you traveling with ?',
      'type': 'single_choice',
      'icon': Icons.group,
      'options': [
        {'value': 'solo', 'label': 'Alone', 'color': Colors.blue},
        {'value': 'couple', 'label': 'As a couple', 'color': Colors.blue},
        {'value': 'family', 'label': 'With family', 'color': Colors.blue},
        {'value': 'friends', 'label': 'With friends', 'color': Colors.blue},
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
    // Ici vous pouvez traiter les réponses pour générer des recommandations
    Navigator.pop(context, answers);
  }

  Widget _buildSliderQuestion(Map<String, dynamic> question) {
    double currentValue = answers[question['id']] ?? question['defaultValue'];

    return Column(
      children: [
        Icon(question['icon'], size: 48, color: Colors.blue),
        SizedBox(height: 20),
        Text(
          question['title'],
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
                'Duration: ${currentValue.round()} ${question['unit']}',
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
          question['title'],
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
                        option['label'],
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
          question['title'],
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          'Select all the options that interest you',
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
                        option['label'],
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
          'Travel Preferences',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
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

          // Question content
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

          // Bottom buttons
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                if (currentQuestionIndex < questions.length - 1)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // Skip for later functionality
                      },
                      child: Text('Skip for later', style: TextStyle(color: Colors.grey[600])),
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
                      currentQuestionIndex < questions.length - 1 ? 'Next' : 'Finish',
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