import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';

/// اسکلت مشترک صفحات ورود: لوگو، عنوان، و نوار طلایی باریک.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.showLogo = true,
    this.appBar,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool showLogo;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: appBar,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            if (showLogo) ...[
              const Center(child: PoladLogo(size: 88)),
              const SizedBox(height: 16),
              const Center(child: GoldHairline()),
              const SizedBox(height: 20),
            ],
            Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(color: AppColors.muted, height: 1.8, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 28),
            child,
          ],
        ),
      ),
    );
  }
}

/// خط تأکیدی طلایی برند.
class GoldHairline extends StatelessWidget {
  const GoldHairline({super.key, this.width = 48});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// دکمهٔ اصلی ورود با وضعیت بارگذاری.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
            )
          : Text(label),
    );
  }
}

/// شش خانهٔ کد تأیید؛ رقم‌ها با صفحه کلید عددی و نمایش فارسی.
class OtpPinField extends StatefulWidget {
  const OtpPinField({
    super.key,
    required this.code,
    required this.onChanged,
    this.enabled = true,
    this.error = false,
  });

  final String code;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool error;

  @override
  State<OtpPinField> createState() => _OtpPinFieldState();
}

class _OtpPinFieldState extends State<OtpPinField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.code);
    _focus = FocusNode();
  }

  @override
  void didUpdateWidget(covariant OtpPinField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.code != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.code,
        selection: TextSelection.collapsed(offset: widget.code.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: List.generate(AppConstants.otpLength, (i) {
                final filled = i < widget.code.length;
                final ch = filled ? faNum(Validators.toEnglishDigits(widget.code[i])) : '';
                final active = widget.enabled && i == widget.code.length;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(left: i == AppConstants.otpLength - 1 ? 0 : 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: widget.error
                            ? AppColors.danger
                            : (active ? AppColors.navy : AppColors.divider),
                        width: active || widget.error ? 1.6 : 1,
                      ),
                    ),
                    child: Text(
                      ch,
                      style: const TextStyle(
                        fontFamily: 'VazirmatnFD',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned.fill(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              enabled: widget.enabled,
              autofocus: true,
              keyboardType: TextInputType.number,
              showCursor: false,
              enableInteractiveSelection: false,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(AppConstants.otpLength),
                FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹٠-٩]')),
              ],
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
