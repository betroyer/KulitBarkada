import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'brand_logo.dart';

class KulitAppHeader extends StatelessWidget implements PreferredSizeWidget {
  const KulitAppHeader({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const KulitLogo(size: 46, showBorder: false),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Kulit Barkada',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: AppColors.softShadow,
                ),
                child: const Icon(Icons.person_outline, size: 22, color: AppColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WireframeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WireframeAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink, fontSize: 20),
      ),
      centerTitle: false,
      actions: actions,
    );
  }
}

class WireframePill extends StatelessWidget {
  const WireframePill({super.key, required this.label, this.onTap, this.icon});

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppColors.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.ink,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 6),
                  Icon(icon, size: 16, color: AppColors.ink),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WireframeOutlineButton extends StatelessWidget {
  const WireframeOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
    this.filled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Text(label);
    final Widget btn = filled
        ? FilledButton(
            onPressed: onPressed,
            child: child,
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: child,
          );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class WireframeTotalBox extends StatelessWidget {
  const WireframeTotalBox({super.key, required this.total, this.label = 'TOTAL'});

  final String total;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(999),
          boxShadow: AppColors.softShadow,
        ),
        child: Text(
          '$label $total',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class WireframeGroupCard extends StatelessWidget {
  const WireframeGroupCard({
    super.key,
    required this.name,
    required this.date,
    required this.memberCount,
    required this.onTap,
  });

  final String name;
  final String date;
  final int memberCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$memberCount members',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_outward, size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WireframeLineItem extends StatelessWidget {
  const WireframeLineItem({super.key, required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink),
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
        ],
      ),
    );
  }
}

class WireframeSectionLabel extends StatelessWidget {
  const WireframeSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: AppColors.ink,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class WireframeCreateFab extends StatelessWidget {
  const WireframeCreateFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(999),
              boxShadow: AppColors.softShadow,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Create',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
