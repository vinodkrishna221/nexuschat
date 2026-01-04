import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexuschat_app/core/ui/widgets/scale_button.dart';

class SocialButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;
  final bool isSvg;

  const SocialButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
    this.isSvg = true,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2d2839)),
        ),
        child: Center(
          // Since we might not have actual assets yet, we'll placeholder
          // or expect SVG strings if we pass content, but typically paths.
          // For now, let's use a Icon as fallback if no path or handle svgs later.
          // EDIT: Design shows Google/Apple/FB icons. I will put placeholders icons for now.
          child: Icon(Icons.code, color: Colors.white.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
