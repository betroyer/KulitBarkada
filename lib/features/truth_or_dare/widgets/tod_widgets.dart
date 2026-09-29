import 'package:flutter/material.dart';

import '../core/tod_theme.dart';

class TodScaffold extends StatelessWidget {
  const TodScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: TodTheme.dark,
      child: Scaffold(
        backgroundColor: TodColors.bg,
        appBar: title == null
            ? null
            : AppBar(
                title: Text(title!, style: const TextStyle(fontWeight: FontWeight.w800)),
                actions: actions,
              ),
        floatingActionButton: floatingActionButton,
        body: Container(
          decoration: const BoxDecoration(gradient: TodColors.gradient),
          child: SafeArea(child: child),
        ),
      ),
    );
  }
}

class TodCard extends StatelessWidget {
  const TodCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.color});

  final Widget child;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? TodColors.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TodColors.purple.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: TodColors.pink.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class TodGradientButton extends StatelessWidget {
  const TodGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              gradient: TodColors.buttonGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: TodColors.pink.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodOutlineButton extends StatelessWidget {
  const TodOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = TodColors.purple,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: TodColors.ink,
        side: BorderSide(color: color.withValues(alpha: 0.7), width: 1.5),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class TodMenuTile extends StatelessWidget {
  const TodMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = TodColors.purple,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return TodCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.2),
          child: Icon(icon, color: accent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: TodColors.ink)),
        subtitle: Text(subtitle, style: const TextStyle(color: TodColors.muted, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: TodColors.muted),
      ),
    );
  }
}

class TodPlayerAvatar extends StatelessWidget {
  const TodPlayerAvatar({super.key, required this.name, this.size = 48, this.highlight = false});

  final String name;
  final double size;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: highlight ? TodColors.buttonGradient : null,
        color: highlight ? null : TodColors.purple.withValues(alpha: 0.35),
        border: Border.all(color: highlight ? TodColors.pink : TodColors.purple, width: highlight ? 3 : 1),
      ),
      child: Text(
        initial,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: size * 0.4, color: TodColors.ink),
      ),
    );
  }
}

String todCategoryLabel(String key) {
  switch (key) {
    case 'classic':
      return 'Classic';
    case 'funny':
      return 'Funny';
    case 'friendship':
      return 'Friendship';
    case 'couples':
      return 'Couples';
    case 'party':
      return 'Party';
    case 'extreme':
      return 'Extreme';
    default:
      return key;
  }
}

String todModeLabel(String key) {
  switch (key) {
    case 'classic':
      return 'Classic Mode';
    case 'random':
      return 'Random Mode';
    case 'couples':
      return 'Couples Mode';
    case 'party':
      return 'Party Mode';
    case 'custom':
      return 'Custom Mode';
    default:
      return key;
  }
}
