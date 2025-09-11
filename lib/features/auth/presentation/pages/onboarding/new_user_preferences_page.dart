import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourisme_app_flutter/core/network/dio_client.dart';
import 'package:tourisme_app_flutter/config/routes/app_routes.dart';
import 'package:tourisme_app_flutter/core/services/localization_service.dart';
import 'package:tourisme_app_flutter/core/services/new_user_service.dart';
import 'package:tourisme_app_flutter/core/services/guest_mode_service.dart';

class NewUserPreferencesPage extends StatefulWidget {
  const NewUserPreferencesPage({Key? key}) : super(key: key);

  @override
  _NewUserPreferencesPageState createState() => _NewUserPreferencesPageState();
}

class _NewUserPreferencesPageState extends State<NewUserPreferencesPage> {
  bool isDarkMode = false;
  late PageController _pageController;
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};

  List<Map<String, dynamic>> _buildQuestions(LocalizationService localization) => [
    {
      'id': 'preferred_city_type',
      'title': 'Quel type de ville préférez-vous visiter ?',
      'type': 'single_choice',
      'icon': Icons.location_city,
      'options': [
        {
          'value': 'coastal',
          'label': 'Villes côtières (plages, océan)',
        },
        {
          'value': 'mountain',
          'label': 'Villes montagneuses (Atlas, nature)',
        },
        {
          'value': 'desert',
          'label': 'Villes du désert (Sahara, oasis)',
        },
        {
          'value': 'historical',
          'label': 'Villes historiques (médinas, patrimoine)',
        },
        {
          'value': 'modern',
          'label': 'Villes modernes (métropoles, business)',
        },
        {
          'value': 'cultural',
          'label': 'Villes culturelles (art, traditions)',
        },
      ]
    },
    {
      'id': 'climate_preference',
      'title': 'Quel climat préférez-vous ?',
      'type': 'single_choice',
      'icon': Icons.wb_sunny,
      'options': [
        {
          'value': 'hot_dry',
          'label': 'Chaud et sec (désert)',
        },
        {
          'value': 'hot_humid',
          'label': 'Chaud et humide (côte)',
        },
        {
          'value': 'mild',
          'label': 'Tempéré (montagne)',
        },
        {
          'value': 'cool',
          'label': 'Frais (haute altitude)',
        },
        {
          'value': 'variable',
          'label': 'Variable selon la saison',
        },
      ]
    },
    {
      'id': 'city_size',
      'title': 'Préférez-vous des villes :',
      'type': 'single_choice',
      'icon': Icons.people,
      'options': [
        {
          'value': 'small',
          'label': 'Petites villes (intimité, tranquillité)',
        },
        {
          'value': 'medium',
          'label': 'Villes moyennes (équilibre)',
        },
        {
          'value': 'large',
          'label': 'Grandes villes (animation, services)',
        },
        {
          'value': 'mega',
          'label': 'Métropoles (diversité, opportunités)',
        },
      ]
    },
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
      'icon': Icons.directions_car,
      'options': [
        {
          'value': 'plane',
          'label': localization.translate('transport_plane'),
        },
        {
          'value': 'train',
          'label': localization.translate('transport_train'),
        },
        {
          'value': 'car',
          'label': localization.translate('transport_car'),
        },
        {
          'value': 'bus',
          'label': localization.translate('transport_bus'),
        },
        {
          'value': 'boat',
          'label': localization.translate('transport_boat'),
        },
      ]
    },
    {
      'id': 'accommodation',
      'title': localization.translate('accommodation_question_title'),
      'type': 'single_choice',
      'icon': Icons.hotel,
      'options': [
        {
          'value': 'hotel',
          'label': localization.translate('accommodation_hotel'),
        },
        {
          'value': 'hostel',
          'label': localization.translate('accommodation_hostel'),
        },
        {
          'value': 'airbnb',
          'label': localization.translate('accommodation_airbnb'),
        },
        {
          'value': 'camping',
          'label': localization.translate('accommodation_camping'),
        },
        {
          'value': 'resort',
          'label': localization.translate('accommodation_resort'),
        },
      ]
    },
    {
      'id': 'interests',
      'title': localization.translate('interests_question_title'),
      'type': 'multiple_choice',
      'icon': Icons.favorite,
      'options': [
        {
          'value': 'culture',
          'label': localization.translate('interest_culture'),
        },
        {
          'value': 'nature',
          'label': localization.translate('interest_nature'),
        },
        {
          'value': 'adventure',
          'label': localization.translate('interest_adventure'),
        },
        {
          'value': 'relaxation',
          'label': localization.translate('interest_relaxation'),
        },
        {
          'value': 'food',
          'label': localization.translate('interest_food'),
        },
        {
          'value': 'nightlife',
          'label': localization.translate('interest_nightlife'),
        },
        {
          'value': 'shopping',
          'label': localization.translate('interest_shopping'),
        },
        {
          'value': 'history',
          'label': localization.translate('interest_history'),
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
    },
    {
      'id': 'special_requirements',
      'title': 'Avez-vous des exigences particulières ?',
      'type': 'multiple_choice',
      'icon': Icons.star,
      'options': [
        {
          'value': 'accessibility',
          'label': 'Accessibilité (handicap)',
        },
        {
          'value': 'halal_food',
          'label': 'Nourriture halal',
        },
        {
          'value': 'wifi',
          'label': 'WiFi fiable',
        },
        {
          'value': 'parking',
          'label': 'Parking disponible',
        },
        {
          'value': 'pet_friendly',
          'label': 'Animaux acceptés',
        },
        {
          'value': 'family_friendly',
          'label': 'Adapté aux familles',
        },
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  Future<void> _skipQuestionnaire() async {
    try {
      await NewUserService.markQuestionnaireSkipped();
      await NewUserService.setShowPersonalizedOnce();
      try { GuestModeService().disableGuestMode(); } catch (_) {}
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LocalizationService>(context, listen: false)
                  .translate('error_skipping_questionnaire'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Future<void> _submitAnswers() async {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    
    try {
      // Sauvegarder les préférences
      await NewUserService.saveUserPreferences(answers);
      
      // Marquer que l'utilisateur a complété ses préférences
      await NewUserService.markPreferencesCompleted();
      await NewUserService.setShowPersonalizedOnce();
      try { GuestModeService().disableGuestMode(); } catch (_) {}
      
      // Enregistrer également les préférences dans le profil backend (best-effort)
      try {
        final preferencesString = answers.entries
            .map((e) => '${e.key}:${e.value}')
            .join('|');
        await DioClient.instance.put(
          '/api/profile/update',
          data: {
            'preferences': preferencesString,
          },
        );
      } catch (_) {}
      
      print('Préférences sauvegardées: $answers');
      
      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localization.translate('preferences_saved_success')),
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Naviguer vers la page d'accueil
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde des préférences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LocalizationService>(context, listen: false)
                  .translate('error_saving_preferences'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildSliderQuestion(Map<String, dynamic> question, double screenWidth, ColorScheme colorScheme) {
    double currentValue = answers[question['id']] ?? question['defaultValue'];
    final dimensions = _getResponsiveDimensions(screenWidth);
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: dimensions.spacing),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(dimensions.padding),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(dimensions.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    question['icon'],
                    size: dimensions.iconSize,
                    color: colorScheme.primary,
                  ),
                  SizedBox(height: dimensions.spacing),
                  Text(
                    question['title'],
                    style: TextStyle(
                      fontSize: dimensions.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: dimensions.spacing * 2),
                  Text(
                    '${currentValue.toInt()} ${question['unit']}',
                    style: TextStyle(
                      fontSize: dimensions.valueFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: dimensions.spacing),
                  SliderTheme(
                    data: _createSliderTheme(colorScheme, dimensions),
                    child: Slider(
                      value: currentValue,
                      min: question['minValue'],
                      max: question['maxValue'],
                      divisions: (question['maxValue'] - question['minValue']).toInt(),
                      onChanged: (value) {
                        setState(() {
                          answers[question['id']] = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildNavigationButtons(colorScheme, dimensions),
      ],
    );
  }

  Widget _buildSingleChoiceQuestion(Map<String, dynamic> question, double screenWidth, ColorScheme colorScheme) {
    final dimensions = _getResponsiveDimensions(screenWidth);
    final options = List<Map<String, dynamic>>.from(question['options']);
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: dimensions.spacing),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(dimensions.padding),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(dimensions.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    question['icon'],
                    size: dimensions.iconSize,
                    color: colorScheme.primary,
                  ),
                  SizedBox(height: dimensions.spacing),
                  Text(
                    question['title'],
                    style: TextStyle(
                      fontSize: dimensions.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: dimensions.spacing * 2),
                  ...options.map((option) => _buildSingleChoiceOption(
                    option,
                    answers[question['id']] == option['value'],
                    () {
                      setState(() {
                        answers[question['id']] = option['value'];
                      });
                    },
                    colorScheme,
                    dimensions,
                  )),
                ],
              ),
            ),
          ),
        ),
        _buildNavigationButtons(colorScheme, dimensions),
      ],
    );
  }

  Widget _buildMultipleChoiceQuestion(Map<String, dynamic> question, double screenWidth, ColorScheme colorScheme) {
    final dimensions = _getResponsiveDimensions(screenWidth);
    final options = List<Map<String, dynamic>>.from(question['options']);
    List<String> selectedValues = List<String>.from(answers[question['id']] ?? []);
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: dimensions.spacing),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(dimensions.padding),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(dimensions.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    question['icon'],
                    size: dimensions.iconSize,
                    color: colorScheme.primary,
                  ),
                  SizedBox(height: dimensions.spacing),
                  Text(
                    question['title'],
                    style: TextStyle(
                      fontSize: dimensions.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: dimensions.spacing * 2),
                  ...options.map((option) => _buildMultipleChoiceOption(
                    option,
                    selectedValues.contains(option['value']),
                    (isSelected) {
                      setState(() {
                        if (isSelected) {
                          selectedValues.add(option['value']);
                        } else {
                          selectedValues.remove(option['value']);
                        }
                        answers[question['id']] = selectedValues;
                      });
                    },
                    colorScheme,
                    dimensions,
                  )),
                ],
              ),
            ),
          ),
        ),
        _buildNavigationButtons(colorScheme, dimensions),
      ],
    );
  }

  Widget _buildSingleChoiceOption(
    Map<String, dynamic> option,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
    ResponsiveDimensions dimensions,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: dimensions.spacing * 0.5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: dimensions.padding,
              vertical: dimensions.spacing,
            ),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                  size: dimensions.iconSize * 0.6,
                ),
                SizedBox(width: dimensions.spacing),
                Expanded(
                  child: Text(
                    option['label'],
                    style: TextStyle(
                      fontSize: dimensions.optionFontSize,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceOption(
    Map<String, dynamic> option,
    bool isSelected,
    Function(bool) onChanged,
    ColorScheme colorScheme,
    ResponsiveDimensions dimensions,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: dimensions.spacing * 0.5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!isSelected),
          borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: dimensions.padding,
              vertical: dimensions.spacing,
            ),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                  size: dimensions.iconSize * 0.6,
                ),
                SizedBox(width: dimensions.spacing),
                Expanded(
                  child: Text(
                    option['label'],
                    style: TextStyle(
                      fontSize: dimensions.optionFontSize,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(ColorScheme colorScheme, ResponsiveDimensions dimensions) {
    final questions = _buildQuestions(Provider.of<LocalizationService>(context, listen: false));
    final isLastQuestion = currentQuestionIndex == questions.length - 1;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentQuestionIndex > 0)
          ElevatedButton.icon(
            onPressed: _previousQuestion,
            icon: Icon(Icons.arrow_back, size: dimensions.iconSize * 0.5),
            label: Text(
              Provider.of<LocalizationService>(context, listen: false).translate('previous'),
              style: TextStyle(fontSize: dimensions.buttonFontSize),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 2,
              padding: EdgeInsets.symmetric(
                horizontal: dimensions.padding,
                vertical: dimensions.spacing,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        
        ElevatedButton.icon(
          onPressed: _nextQuestion,
          icon: Icon(
            isLastQuestion ? Icons.check : Icons.arrow_forward,
            size: dimensions.iconSize * 0.5,
          ),
          label: Text(
            isLastQuestion 
              ? Provider.of<LocalizationService>(context, listen: false).translate('finish')
              : Provider.of<LocalizationService>(context, listen: false).translate('next'),
            style: TextStyle(fontSize: dimensions.buttonFontSize),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 4,
            padding: EdgeInsets.symmetric(
              horizontal: dimensions.padding,
              vertical: dimensions.spacing,
            ),
          ),
        ),
      ],
    );
  }

  ResponsiveDimensions _getResponsiveDimensions(double screenWidth) {
    final scale = (screenWidth / 375).clamp(0.8, 1.2);
    return ResponsiveDimensions(
      padding: (16 * scale).clamp(12.0, 24.0),
      spacing: (16 * scale).clamp(12.0, 24.0),
      borderRadius: (12 * scale).clamp(8.0, 16.0),
      iconSize: (48 * scale).clamp(32.0, 64.0),
      titleFontSize: (20 * scale).clamp(16.0, 24.0),
      valueFontSize: (18 * scale).clamp(14.0, 22.0),
      optionFontSize: (16 * scale).clamp(14.0, 18.0),
      buttonFontSize: (16 * scale).clamp(14.0, 18.0),
    );
  }

  SliderThemeData _createSliderTheme(ColorScheme colorScheme, ResponsiveDimensions dimensions) {
    return SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withOpacity(0.2),
      valueIndicatorColor: colorScheme.primary,
      valueIndicatorTextStyle: TextStyle(
        color: colorScheme.onPrimary,
        fontSize: dimensions.valueFontSize * 0.8,
      ),
      trackHeight: (4 * (dimensions.iconSize / 48)).clamp(3.0, 7.0),
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
            leading: currentQuestionIndex > 0 
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onBackground,
                    size: dimensions.iconSize * 0.6,
                  ),
                  onPressed: _previousQuestion,
                )
              : null,
            title: Text(
              localization.translate('welcome_preferences_title'),
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w600,
                fontSize: dimensions.titleFontSize * 0.8,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _skipQuestionnaire,
                child: Text(
                  localization.translate('skip'),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: dimensions.optionFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Progress indicator
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: dimensions.padding,
                    vertical: dimensions.spacing,
                  ),
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    backgroundColor: colorScheme.outline.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 4,
                  ),
                ),
                
                // Question counter
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: dimensions.padding),
                  child: Text(
                    '${currentQuestionIndex + 1} / ${questions.length}',
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.7),
                      fontSize: dimensions.optionFontSize * 0.8,
                    ),
                  ),
                ),
                
                SizedBox(height: dimensions.spacing),
                
                // Question content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: dimensions.padding),
                        child: question['type'] == 'slider'
                          ? _buildSliderQuestion(question, screenWidth, colorScheme)
                          : question['type'] == 'single_choice'
                            ? _buildSingleChoiceQuestion(question, screenWidth, colorScheme)
                            : _buildMultipleChoiceQuestion(question, screenWidth, colorScheme),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ResponsiveDimensions {
  final double padding;
  final double spacing;
  final double borderRadius;
  final double iconSize;
  final double titleFontSize;
  final double valueFontSize;
  final double optionFontSize;
  final double buttonFontSize;

  ResponsiveDimensions({
    required this.padding,
    required this.spacing,
    required this.borderRadius,
    required this.iconSize,
    required this.titleFontSize,
    required this.valueFontSize,
    required this.optionFontSize,
    required this.buttonFontSize,
  });
}
