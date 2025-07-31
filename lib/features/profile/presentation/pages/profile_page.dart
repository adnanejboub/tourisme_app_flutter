import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;
                final isTablet = screenWidth > 600;
                final isDesktop = screenWidth > 900;
                final isLandscape = screenWidth > screenHeight;

                return Column(
                  children: [
                    _buildHeader(localizationService, screenWidth, isTablet, isDesktop),
                    Expanded(
                      child: _buildContent(localizationService, screenWidth, screenHeight, isTablet, isDesktop, isLandscape),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(LocalizationService localizationService, double screenWidth, bool isTablet, bool isDesktop) {
    final titleSize = isDesktop ? 32.0 : (isTablet ? 30.0 : 28.0);
    final iconSize = isDesktop ? 28.0 : (isTablet ? 26.0 : 24.0);
    final padding = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                localizationService.translate('nav_profile'),
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 20 : 16),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.grey[600],
              size: iconSize,
            ),
            onPressed: () {},
            padding: EdgeInsets.all(isDesktop ? 12 : 8),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      LocalizationService localizationService,
      double screenWidth,
      double screenHeight,
      bool isTablet,
      bool isDesktop,
      bool isLandscape,
      ) {
    final avatarRadius = isDesktop ? 70.0 : (isTablet ? 60.0 : 50.0);
    final avatarIconSize = isDesktop ? 80.0 : (isTablet ? 70.0 : 60.0);
    final titleSize = isDesktop ? 28.0 : (isTablet ? 26.0 : 24.0);
    final subtitleSize = isDesktop ? 18.0 : (isTablet ? 17.0 : 16.0);
    final spacing = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);
    final maxWidth = isDesktop ? 600.0 : (isTablet ? 500.0 : screenWidth * 0.85);

    if (isLandscape && !isDesktop) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: CircleAvatar(
                radius: avatarRadius * 0.8,
                backgroundColor: Color(AppConstants.primaryColor),
                child: Icon(
                  Icons.person,
                  size: avatarIconSize * 0.8,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        localizationService.translate('profile_name'),
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: spacing * 0.5),
                    Text(
                      localizationService.translate('profile_subtitle'),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: subtitleSize,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 48 : (isTablet ? 32 : 24),
          vertical: isDesktop ? 32 : (isTablet ? 24 : 16),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Color(AppConstants.primaryColor),
                child: Icon(
                  Icons.person,
                  size: avatarIconSize,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: spacing),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  localizationService.translate('profile_name'),
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: spacing * 0.5),
              Text(
                localizationService.translate('profile_subtitle'),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: subtitleSize,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}