import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nexuschat_app/core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
        title: 'Instant Messaging',
        description:
            'Connect with friends in real-time with lightning-fast messages',
        icon: Icons.chat_bubble_outline),
    OnboardingContent(
        title: 'Secure & Private',
        description: 'Your conversations are encrypted and safe with us',
        icon: Icons.security),
    OnboardingContent(
        title: 'Express Yourself',
        description: 'Send photos, videos, and voice messages seamlessly',
        icon: Icons.emoji_emotions_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF12121A),
            ],
          ),
        ),
        child: Column(
          children: [
            // Illustration Area (Top 60%)
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                   // Abstract Glow
                   Positioned(
                     top: MediaQuery.of(context).size.height * 0.25,
                     left: MediaQuery.of(context).size.width * 0.2,
                     child: Container(
                       width: 300,
                       height: 300,
                       decoration: BoxDecoration(
                         color: AppColors.primary.withValues(alpha: 0.2),
                         shape: BoxShape.circle,
                       ),
                     ).animate(onPlay: (c) => c.repeat(reverse: true))
                      .blurXY(begin: 0, end: 50, duration: 4.seconds)
                      .scale(begin: const Offset(1,1), end: const Offset(1.2,1.2), duration: 4.seconds),
                   ),
                   
                   // Content placeholder for 3D bubble composition
                   // Using simple Icons/shapes for now to represent the "Glass Bubble" reference
                   Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                            // Main Bubble
                            _GlassBubble(
                              width: 200, 
                              height: 140,
                              delay: 0.ms,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _TypingDot(delay: 0.ms),
                                  const SizedBox(width: 8),
                                  _TypingDot(delay: 200.ms),
                                  const SizedBox(width: 8),
                                  _TypingDot(delay: 400.ms),
                                ],
                              ),
                            ),
                            // Floating Elements
                            Positioned(
                              top: -40,
                              right: -20,
                              child: _GlassBubble(
                                width: 64,
                                height: 64,
                                borderRadius: 32,
                                color: Colors.cyan.withValues(alpha: 0.2),
                                delay: 1000.ms,
                                child: const Icon(Icons.favorite, color: Colors.white, size: 32),
                              ).animate(onPlay: (c) => c.repeat(reverse: true))
                               .moveY(begin: 0, end: -15, duration: 3.seconds),
                            ),
                             Positioned(
                              bottom: -30,
                              left: -30,
                              child: _GlassBubble(
                                width: 56,
                                height: 56,
                                borderRadius: 28,
                                color: AppColors.primary.withValues(alpha: 0.2),
                                delay: 1500.ms,
                                child: const Icon(Icons.send, color: Colors.white, size: 28),
                              ).animate(onPlay: (c) => c.repeat(reverse: true))
                               .moveY(begin: 0, end: -10, duration: 4.seconds),
                            ),
                        ],
                      ),
                   ),
                ],
              ),
            ),

            // Content Area (Bottom 40%)
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF161122).withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                       // PageView for Text Content
                       Expanded(
                         child: PageView.builder(
                           controller: _pageController,
                           onPageChanged: (value) => setState(() => _currentPage = value),
                           itemCount: _contents.length,
                           itemBuilder: (context, index) {
                             return Column(
                               children: [
                                  // Pagination Dots
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      _contents.length, 
                                      (dotIndex) => _buildDot(dotIndex),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    _contents[index].title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ).animate().fadeIn().moveY(begin: 20, end: 0),
                                  const SizedBox(height: 16),
                                  Text(
                                    _contents[index].description,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                               ],
                             );
                           },
                         ),
                       ),
                       
                       // Next Button
                       SizedBox(
                         width: double.infinity,
                         height: 56,
                         child: ElevatedButton(
                           style: ElevatedButton.styleFrom(
                             backgroundColor: const Color(0xFF895bf5),
                             foregroundColor: Colors.white,
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(12),
                             ),
                             elevation: 8,
                             shadowColor: const Color(0xFF895bf5).withValues(alpha: 0.4),
                           ),
                           onPressed: () {
                             if (_currentPage < _contents.length - 1) {
                               _pageController.nextPage(
                                 duration: const Duration(milliseconds: 300),
                                 curve: Curves.easeInOut,
                               );
                             } else {
                               context.go('/login');
                             }
                           },
                           child: Text(
                             _currentPage == _contents.length - 1 ? 'Get Started' : 'Next',
                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                           ),
                         ),
                       ),
                       const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: isActive ? null : Border.all(color: const Color(0xFF3f3f4e)),
        boxShadow: isActive ? [
           BoxShadow(
             color: AppColors.primary.withValues(alpha: 0.5),
             blurRadius: 10,
             spreadRadius: 1,
           )
        ] : null,
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;

  OnboardingContent(
      {required this.title, required this.description, required this.icon});
}

class _GlassBubble extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final double borderRadius;
  final Color? color;
  final Duration delay;

  const _GlassBubble({
    required this.width,
    required this.height,
    required this.child,
    this.borderRadius = 24,
    this.color,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
             (color ?? Colors.white).withValues(alpha: 0.1),
             (color ?? Colors.white).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child, // Blur effect logic would go here ideally with BackdropFilter
    ).animate().fadeIn(delay: delay).scale();
  }
}

class _TypingDot extends StatelessWidget {
  final Duration delay;
  const _TypingDot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), delay: delay, duration: 600.ms)
     .fade(begin: 0.5, end: 1.0);
  }
}
