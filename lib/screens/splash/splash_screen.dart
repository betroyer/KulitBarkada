import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_logo.dart';

/// Pre-load splash: bounce + wobble the brand emoji while auth restores.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.child});

  final Widget child;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _bounce;
  late final AnimationController _wobble;
  late final AnimationController _exit;
  late final Animation<double> _scale;
  late final Animation<double> _tilt;
  late final Animation<double> _fadeOut;
  late final Animation<double> _slideUp;

  var _showApp = false;
  var _minTimeDone = false;
  Timer? _minTimer;

  @override
  void initState() {
    super.initState();

    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _wobble = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _exit = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.08), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.96), weight: 50),
    ]).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));

    _tilt = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _wobble, curve: Curves.easeInOut),
    );

    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exit, curve: Curves.easeOutCubic),
    );
    _slideUp = Tween<double>(begin: 0, end: -28).animate(
      CurvedAnimation(parent: _exit, curve: Curves.easeOutCubic),
    );

    final reduceMotion = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    final minMs = reduceMotion ? 400 : 1800;
    _minTimer = Timer(Duration(milliseconds: minMs), () {
      _minTimeDone = true;
      _tryFinish();
    });
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _bounce.dispose();
    _wobble.dispose();
    _exit.dispose();
    super.dispose();
  }

  void _tryFinish() {
    final auth = context.read<AuthState>();
    if (!_minTimeDone || !auth.ready || _showApp || _exit.isAnimating) return;
    _finish();
  }

  Future<void> _finish() async {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      if (!mounted) return;
      setState(() => _showApp = true);
      return;
    }
    _bounce.stop();
    _wobble.stop();
    await _exit.forward();
    if (!mounted) return;
    setState(() => _showApp = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (auth.ready && _minTimeDone && !_showApp && !_exit.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryFinish());
    }

    if (_showApp) return widget.child;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: AnimatedBuilder(
        animation: Listenable.merge([_bounce, _wobble, _exit]),
        builder: (context, child) {
          final scale = reduceMotion ? 1.0 : _scale.value;
          final tilt = reduceMotion ? 0.0 : _tilt.value;
          return Opacity(
            opacity: _fadeOut.value,
            child: Transform.translate(
              offset: Offset(0, _slideUp.value),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: tilt * math.pi,
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'KULIT BARKADA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      auth.ready ? 'Almost there…' : 'Warming up the barkada…',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.gold,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: const KulitLogo(size: 148),
      ),
    );
  }
}
