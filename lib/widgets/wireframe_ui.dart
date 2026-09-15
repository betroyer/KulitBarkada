import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'brand_logo.dart';

/// Shared wireframe-style UI matching the Kulit Barkada sketches.
class KulitAppHeader extends StatelessWidget implements PreferredSizeWidget {
  const KulitAppHeader({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const KulitLogo(size: 44, showBorder: true),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'KULIT BARKADA',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ),
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                child: const Icon(Icons.person_outline, size: 22),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.ink, width: 2),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
              if (icon != null) ...[const SizedBox(width: 6), Icon(icon, size: 16)],
            ],
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
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.ink, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
      ),
      child: Text(label.toUpperCase()),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$label $total',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
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
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                      ),
                    ),
                    Text(date, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                WireframePill(label: '$memberCount MEMBERS'),
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
              label.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.4),
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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
        label.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8),
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
      padding: const EdgeInsets.only(right: 20, bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Text('+ CREATE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
          ),
        ),
      ),
    );
  }
}
