import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

const _wheelColors = [
  Color(0xFFE11D48),
  Color(0xFFEA580C),
  Color(0xFFEAB308),
  Color(0xFF16A34A),
  Color(0xFF0D9488),
  Color(0xFF2563EB),
  Color(0xFF7C3AED),
  Color(0xFFDB2777),
];

class RouletteCategory {
  const RouletteCategory({
    required this.id,
    required this.title,
    required this.emoji,
    required this.options,
    required this.color,
  });

  final String id;
  final String title;
  final String emoji;
  final List<String> options;
  final Color color;
}

List<String> _slicesFor(List<String> options) {
  if (options.length >= 3) return List<String>.from(options);
  if (options.length == 2) return [...options, ...options];
  return List<String>.filled(6, options.first);
}

class FortuneRoulette extends StatefulWidget {
  const FortuneRoulette({
    super.key,
    required this.options,
    required this.emoji,
    this.size = 300,
    this.autoSpin = false,
    this.onSettled,
  });

  final List<String> options;
  final String emoji;
  final double size;
  final bool autoSpin;
  final ValueChanged<String>? onSettled;

  @override
  State<FortuneRoulette> createState() => FortuneRouletteState();
}

class FortuneRouletteState extends State<FortuneRoulette> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rotation;
  final _random = Random();
  bool _spinning = false;
  String? _winner;

  List<String> get _slices => _slicesFor(widget.options);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));
    _rotation = const AlwaysStoppedAnimation(0);
    if (widget.autoSpin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) spin();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> spin() async {
    if (_spinning || widget.options.isEmpty) {
      return _winner ?? widget.options.first;
    }

    final slices = _slices;
    final uniqueWinner = widget.options[_random.nextInt(widget.options.length)];
    final matching = <int>[];
    for (var i = 0; i < slices.length; i++) {
      if (slices[i] == uniqueWinner) matching.add(i);
    }
    final winnerIndex = matching[_random.nextInt(matching.length)];
    final sweep = 2 * pi / slices.length;
    final extra = (2 * pi) - ((winnerIndex + 0.5) * sweep);
    final target = (2 * pi * (6 + _random.nextInt(3))) + extra;

    setState(() {
      _spinning = true;
      _winner = null;
      _rotation = Tween<double>(begin: 0, end: target).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
    });

    _controller.reset();
    HapticFeedback.mediumImpact();
    await _controller.forward();
    HapticFeedback.heavyImpact();

    if (!mounted) return uniqueWinner;
    setState(() {
      _spinning = false;
      _winner = uniqueWinner;
    });
    widget.onSettled?.call(uniqueWinner);
    return uniqueWinner;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size + 28,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _rotation,
                    builder: (context, child) => Transform.rotate(
                      angle: _rotation.value,
                      child: child,
                    ),
                    child: CustomPaint(
                      size: Size.square(size),
                      painter: _WheelPainter(slices: _slices),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8),
                    ],
                  ),
                  child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const Positioned(
                top: 0,
                child: Icon(Icons.arrow_drop_down, size: 54, color: Color(0xFFB45309)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _spinning
                ? 'Spinning...'
                : (_winner == null ? 'Tap spin to choose' : _winner!),
            key: ValueKey('$_spinning-$_winner'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _winner == null ? 16 : 24,
              fontWeight: FontWeight.w900,
              color: _winner == null ? AppColors.muted : AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.slices});

  final List<String> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final n = slices.length;
    final sweep = 2 * pi / n;
    final fontSize = n > 10 ? 9.0 : n > 6 ? 11.0 : 13.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    for (var i = 0; i < n; i++) {
      final start = -pi / 2 + i * sweep;
      final path = Path()
        ..moveTo(0, 0)
        ..arcTo(Rect.fromCircle(center: Offset.zero, radius: radius), start, sweep, false)
        ..close();

      canvas.drawPath(path, Paint()..color = _wheelColors[i % _wheelColors.length]);
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      canvas.save();
      canvas.rotate(start + sweep / 2);
      final label = slices[i].length > 14 ? '${slices[i].substring(0, 13)}…' : slices[i];
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: radius * 0.58);
      painter.paint(canvas, Offset(radius * 0.28, -painter.height / 2));
      canvas.restore();
    }

    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => oldDelegate.slices != slices;
}

Future<String?> showRouletteDialog(
  BuildContext context, {
  required String title,
  required String emoji,
  required List<String> options,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _RouletteDialog(title: title, emoji: emoji, options: options),
  );
}

class _RouletteDialog extends StatefulWidget {
  const _RouletteDialog({
    required this.title,
    required this.emoji,
    required this.options,
  });

  final String title;
  final String emoji;
  final List<String> options;

  @override
  State<_RouletteDialog> createState() => _RouletteDialogState();
}

class _RouletteDialogState extends State<_RouletteDialog> {
  String? _winner;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      title: Text('🎡 ${widget.title}', textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: FortuneRoulette(
          options: widget.options,
          emoji: widget.emoji,
          size: 260,
          autoSpin: true,
          onSettled: (value) => setState(() => _winner = value),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (_winner != null)
          FilledButton(
            onPressed: () => Navigator.pop(context, _winner),
            child: const Text('Use this pick'),
          ),
      ],
    );
  }
}

Future<Map<String, String>?> showPlanRoulette(
  BuildContext context, {
  required List<RouletteCategory> categories,
}) {
  return Navigator.of(context).push<Map<String, String>>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PlanRoulettePage(categories: categories),
    ),
  );
}

class PlanRoulettePage extends StatefulWidget {
  const PlanRoulettePage({super.key, required this.categories});

  final List<RouletteCategory> categories;

  @override
  State<PlanRoulettePage> createState() => _PlanRoulettePageState();
}

class _PlanRoulettePageState extends State<PlanRoulettePage> {
  final _results = <String, String>{};
  var _round = 0;
  var _done = false;

  RouletteCategory get _current => widget.categories[_round];

  void _onSettled(String winner) {
    _results[_current.id] = winner;
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_round < widget.categories.length - 1) {
        setState(() => _round += 1);
      } else {
        setState(() => _done = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1917),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1917),
        foregroundColor: Colors.white,
        title: const Text('Plan roulette'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: _done ? _resultsView() : _spinView(),
      ),
    );
  }

  Widget _spinView() {
    final category = _current;
    return Column(
      children: [
        Text(
          'Round ${_round + 1} of ${widget.categories.length}',
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Choosing ${category.title}...',
          style: TextStyle(color: category.color, fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        FortuneRoulette(
          key: ValueKey('round-$_round'),
          options: category.options,
          emoji: category.emoji,
          autoSpin: true,
          onSettled: _onSettled,
        ),
        const Spacer(),
        const Text(
          'The wheel picks the plan. No take-backs until it stops.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _resultsView() {
    return Column(
      children: [
        const Text('🎉', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        const Text(
          'YOUR GROUP PLAN',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 20),
        for (final category in widget.categories)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(category.title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                ),
                Text(
                  _results[category.id] ?? '—',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
          ),
        const Spacer(),
        FilledButton(
          onPressed: () => Navigator.pop(context, Map<String, String>.from(_results)),
          child: const Text('Use this plan'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Spin again later', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
