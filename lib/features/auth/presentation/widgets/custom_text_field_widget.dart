// lib/features/presentation/widgets/custom_text_field_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../config/theme/app_theme.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextFieldWidget({
    Key? key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.enabled = true,
    this.borderRadius = 12,
    this.contentPadding,
  }) : super(key: key);

  @override
  _CustomTextFieldWidgetState createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: AppTheme.borderColor,
      end: AppTheme.primaryColor,
    ).animate(_animationController);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _buildLabel(),
          SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _borderColorAnimation,
          builder: (context, child) {
            return TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onFieldSubmitted,
              enabled: widget.enabled,
              style: TextStyle(
                fontSize: 16,
                color: widget.enabled ? AppTheme.textPrimaryColor : AppTheme.textHintColor,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: AppTheme.textHintColor,
                  fontSize: 16,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                  widget.prefixIcon,
                  color: _isFocused ? AppTheme.primaryColor : AppTheme.textHintColor,
                )
                    : null,
                suffixIcon: widget.suffixIcon,
                filled: true,
                fillColor: widget.enabled ? Color(0xFFF8F9FA) : Color(0xFFF5F5F5),
                contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(
                  horizontal: widget.prefixIcon != null ? 12 : 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: _borderColorAnimation.value ?? AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: AppTheme.errorColor,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: AppTheme.errorColor,
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: AppTheme.borderColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                counterStyle: TextStyle(
                  color: AppTheme.textHintColor,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabel() {
    return Text(
      widget.label!,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _isFocused ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
      ),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }
}

// Specialized text field widgets
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EmailTextField({
    Key? key,
    this.controller,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextFieldWidget(
      controller: controller,
      label: 'Email',
      hintText: 'Enter your email address',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: validator,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool showStrengthIndicator;

  const PasswordTextField({
    Key? key,
    this.controller,
    this.label = 'Password',
    this.hintText = 'Enter your password',
    this.validator,
    this.onChanged,
    this.showStrengthIndicator = false,
  }) : super(key: key);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFieldWidget(
          controller: widget.controller,
          label: widget.label,
          hintText: widget.hintText,
          prefixIcon: Icons.lock_outlined,
          obscureText: _obscureText,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppTheme.textHintColor,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.done,
        ),
        if (widget.showStrengthIndicator && widget.controller != null)
          _buildPasswordStrengthIndicator(),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    // This would show password strength - implement based on your needs
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text(
            'Password strength: ',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          // Add strength indicator bars here
        ],
      ),
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneTextField({
    Key? key,
    this.controller,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextFieldWidget(
      controller: controller,
      label: 'Phone Number',
      hintText: '+212 6XX XX XX XX',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: validator,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }
}

class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchTextField({
    Key? key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextFieldWidget(
      controller: controller,
      hintText: hintText,
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
        icon: Icon(Icons.clear, color: AppTheme.textHintColor),
        onPressed: () {
          controller?.clear();
          onClear?.call();
        },
      )
          : null,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}