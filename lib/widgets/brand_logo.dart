import 'package:flutter/material.dart';

/// Kulit Barkada brand mark — the 3D zany emoji.
class BrandAssets {
  static const emoji = 'assets/brand/kulit_emoji.png';
}

class KulitLogo extends StatelessWidget {
  const KulitLogo({
    super.key,
    this.size = 48,
    this.showBorder = false,
  });

  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final image = ClipOval(
      child: ColoredBox(
        color: Colors.black,
        child: Image.asset(
          BrandAssets.emoji,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );

    if (!showBorder) return image;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1C1917), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: image,
    );
  }
}
