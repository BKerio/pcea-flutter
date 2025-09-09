import 'dart:async';
import 'package:flutter/material.dart';
import 'get_started.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _pulseAnimation;
  late AnimationController _haloController;
  late PageController _verseController;
  int _verseIndex = 0;
  bool _showVerses = false;

  final List<String> _verses = [
    "“The Lord is my shepherd; I shall not want.” – Psalm 23:1",
    "“Let all that you do be done in love.” – 1 Corinthians 16:14",
    "“For with God nothing shall be impossible.” – Luke 1:37",
    "“I can do all things through Christ who strengthens me.” – Philippians 4:13",
  ];

  @override
  void initState() {
    super.initState();

    // Logo pulse animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Halo rotation
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Verse auto-slide
    _verseController = PageController();
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_verseIndex < _verses.length - 1) {
        _verseIndex++;
      } else {
        _verseIndex = 0;
      }
      if (_verseController.hasClients) {
        _verseController.animateToPage(
          _verseIndex,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });

    // Phase switch: first logo splash, then verses
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showVerses = true;
      });
    });

    // Navigate after full splash
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 10));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StartScreen()),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _haloController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(seconds: 2),
        child: _showVerses ? _buildVerseSplash() : _buildLogoSplash(),
      ),
    );
  }

  /// Phase 1: YouTube-style logo splash
  Widget _buildLogoSplash() {
    return Container(
      color: Colors.white,
      child: Center(
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.church, color: Colors.white, size: 70),
          ),
        ),
      ),
    );
  }

  /// Phase 2: Gradient, halo, and verse carousel
  Widget _buildVerseSplash() {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Halo Ring Animation
          Center(
            child: RotationTransition(
              turns: _haloController,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 4,
                  ),
                ),
              ),
            ),
          ),

          // Pulsating Cross
          Center(
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: const Icon(Icons.church, size: 100, color: Colors.white),
            ),
          ),

          // Verse Carousel with Beautiful Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: SizedBox(
                height: 150,
                child: PageView.builder(
                  controller: _verseController,
                  itemCount: _verses.length,
                  itemBuilder: (context, index) {
                    return AnimatedOpacity(
                      opacity: _verseIndex == index ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 25.0),
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            _verses[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
