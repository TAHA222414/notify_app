// lib/pages/home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Update these to your actual asset file names
  final List<String> _images = const [
    'assets/images/image111.png',
    'assets/images/image222.png',
    'assets/images/image333.png',
    'assets/images/image444.png',
    'assets/images/image555.png',
  ];

  int _current = 0;
  Timer? _timer;
  late final Future<String?> _usernameFuture;

  @override
  void initState() {
    super.initState();
    _usernameFuture = _getUsername();

    // change slide every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _current = (_current + 1) % _images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<String?> _getUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) return (doc.data() ?? {})['username'] as String?;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // responsive banner height (~35% of screen). Tweak if you want taller/shorter.
    final double bannerHeight = MediaQuery.of(context).size.height * 0.35;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _usernameFuture,
        builder: (context, snap) {
          final username = snap.data ?? 'User';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // ======= Top carousel (edge-to-edge, no empty space) =======
              SizedBox(
                height: bannerHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // fading image
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: Image.asset(
                        _images[_current],
                        key: ValueKey(_images[_current]),
                        fit: BoxFit.cover, // fills entire banner
                        alignment: Alignment.center,
                      ),
                    ),

                    // welcome overlay INSIDE image (at the very top)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Welcome, $username 👋',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black54,
                                  offset: Offset(1.5, 1.5),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // dots indicator
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_images.length, (i) {
                          final active = i == _current;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: active ? 20 : 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ======= rest of your page content =======
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Your content below the carousel...',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 400), // demo filler
            ],
          );
        },
      ),
    );
  }
}
