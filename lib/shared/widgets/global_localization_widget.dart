import 'package:flutter/material.dart';
import '/core/services/localization_service.dart';

class LocalizedText extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;

  const LocalizedText(
      this.textKey, {
        Key? key,
        this.style,
        this.textAlign,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService(),
      builder: (context, _) {
        return Text(
          LocalizationService().translate(textKey),
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}