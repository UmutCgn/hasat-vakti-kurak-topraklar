import 'package:flutter/material.dart';

class WoodPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color color;

  const WoodPanel({
    required this.child,
    this.width,
    this.height,
    this.onTap,
    this.color = const Color(0xFF8D6E63), // Temel Ahşap Rengi
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(4), // Dış çerçeve kalınlığı
        decoration: BoxDecoration(
          color: Color(0xFF3E2723), // En dış koyu çerçeve
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black45, offset: Offset(0, 6), blurRadius: 4)
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.9),
                color,
                color.withOpacity(0.8), // Hafif gölge efekti
              ],
            ),
            border: Border.all(color: Color(0xFFD7CCC8).withOpacity(0.3), width: 2), // İç parlama
          ),
          child: Stack(
            children: [
              // İçerik
              Center(child: child),
              
              // Köşe Vidaları (Dekoratif)
              _buildScrew(top: 4, left: 4),
              _buildScrew(top: 4, right: 4),
              _buildScrew(bottom: 4, left: 4),
              _buildScrew(bottom: 4, right: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrew({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 6, height: 6,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(1,1), blurRadius: 1)],
        ),
      ),
    );
  }
}