import 'package:flutter/material.dart';
import '../../core/services/image_service.dart';

class SmartImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallbackWidget;
  final IconData? fallbackIcon;
  final Color? fallbackIconColor;
  final double? fallbackIconSize;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const SmartImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackWidget,
    this.fallbackIcon,
    this.fallbackIconColor,
    this.fallbackIconSize = 32,
    this.borderRadius,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget imageWidget;

    if (imageUrl.isEmpty) {
      imageWidget = _buildFallbackWidget(colorScheme);
    } else if (ImageService.isLocalAsset(imageUrl)) {
      imageWidget = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackWidget(colorScheme);
        },
      );
    } else {
      imageWidget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackWidget(colorScheme);
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildFallbackWidget(ColorScheme colorScheme) {
    if (fallbackWidget != null) {
      return fallbackWidget!;
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? colorScheme.onSurface.withOpacity(0.1),
      child: Icon(
        fallbackIcon ?? Icons.image,
        color: fallbackIconColor ?? colorScheme.onSurface.withOpacity(0.6),
        size: fallbackIconSize,
      ),
    );
  }
}

/// Predefined smart image widgets for common use cases
class CityImageWidget extends StatelessWidget {
  final String cityName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CityImageWidget({
    Key? key,
    required this.cityName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartImageWidget(
      imageUrl: ImageService.getCityImage(cityName),
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      fallbackIcon: Icons.location_city,
    );
  }
}

class ActivityImageWidget extends StatelessWidget {
  final String? category;
  final String? activityName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ActivityImageWidget({
    Key? key,
    this.category,
    this.activityName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartImageWidget(
      imageUrl: ImageService.getActivityImage(category, activityName),
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      fallbackIcon: Icons.local_activity,
    );
  }
}
