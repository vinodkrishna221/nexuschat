import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexuschat_app/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to next screen after animation
    Future.delayed(const Duration(seconds: 4), () {
      // For now, staying on splash or navigating to a placeholder auth/home
      // context.go('/auth'); 
      // Since we haven't implemented auth yet, we'll just log or stay here.
      debugPrint('Navigate to Auth/Home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarker,
      body: Stack(
        children: [
          // Background Ambient Effects
          const _BackgroundEffects(),
          
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Logo Container
                const _LogoDisplay(),
                
                const SizedBox(height: 32),
                
                // Headline
                Text(
                  'NexusChat',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    foreground: Paint()..shader = const LinearGradient(
                      colors: AppColors.textGradient,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 8),
                
                // Meta Text
                Text(
                  'COMMUNICATION REIMAGINED',
                  style: Theme.of(context).textTheme.bodyLarge,
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
                
                const Spacer(),
                
                // Bottom Loader
                const _BottomLoader(),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundEffects extends StatelessWidget {
  const _BackgroundEffects();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Central Glow
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        
        // Floating Particles
        Positioned(
          top: MediaQuery.of(context).size.height * 0.15,
          left: MediaQuery.of(context).size.width * 0.10,
          child: Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds)
           .move(begin: const Offset(0, 0), end: const Offset(20, 20), duration: 5.seconds),
        ),
        
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.20,
          right: MediaQuery.of(context).size.width * 0.05,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 5.seconds)
           .move(begin: const Offset(0, 0), end: const Offset(-20, -10), duration: 6.seconds),
        ),
        
        // Geometric Shapes
        Positioned(
          top: MediaQuery.of(context).size.height * 0.10,
          left: MediaQuery.of(context).size.width * 0.50,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoDisplay extends StatelessWidget {
  const _LogoDisplay();

  @override
  Widget build(BuildContext context) {
    final logoSvg = '''
<svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="logoGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#8B5CF6;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#D946EF;stop-opacity:1" />
    </linearGradient>
  </defs>
  <path d="M28 20 L28 80 L38 80 L38 40 L62 80 L72 80 L72 20 L62 20 L62 60 L38 20 Z" fill="url(#logoGradient)"/>
</svg>
''';

    return Stack(
      alignment: Alignment.center,
      children: [
        // Back Glow
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.4),
                AppColors.accent.withValues(alpha: 0.4),
              ],
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .blur(begin: const Offset(40, 40), end: const Offset(60, 60), duration: 2.seconds)
         .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds),
         
        // Logo
        SizedBox(
          width: 100,
          height: 100,
          child: SvgPicture.string(logoSvg),
        ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
      ],
    );
  }
}

class _BottomLoader extends StatelessWidget {
  const _BottomLoader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(1.0).animate(onPlay: (c) => c.repeat()).fade(duration: 1.seconds),
            const SizedBox(width: 12),
            _dot(0.6).animate(delay: 200.ms, onPlay: (c) => c.repeat()).fade(duration: 1.seconds),
            const SizedBox(width: 12),
            _dot(0.3).animate(delay: 400.ms, onPlay: (c) => c.repeat()).fade(duration: 1.seconds),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'v1.0.0',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _dot(double opacity) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: opacity),
        shape: BoxShape.circle,
        boxShadow: opacity == 1.0 ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.8),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ] : null,
      ),
    );
  }
}
