import 'package:flutter/material.dart';
import '../widgets/wood_panel.dart';
import 'main_menu_screen.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan
          Positioned.fill(child: Image.asset('assets/images/bg_arid.png', fit: BoxFit.cover)),
          
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- LOGO ---
                  WoodPanel(
                    width: 320, height: 160,
                    color: Color(0xFF4E342E),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.agriculture, size: 50, color: Colors.greenAccent),
                        Text("MİNİK\nÇİFTLİK", textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, height: 0.9, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 80),

                  // --- BAŞLA BUTONU ---
                  _buildAnimatedButton(context, "BAŞLA", Icons.play_arrow_rounded, Colors.orange[800]!, () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainMenuScreen()));
                  }),

                  SizedBox(height: 20),

                  // --- SEÇENEKLER / HAKKINDA ---
                  _buildAnimatedButton(context, "AYARLAR", Icons.settings, Colors.brown[600]!, () {
                    // Ayarlar dialogu eklenebilir
                  }, isSmall: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(BuildContext context, String text, IconData icon, Color color, VoidCallback onTap, {bool isSmall = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0), // İlerde nefes alma efekti verilebilir
      duration: Duration(milliseconds: 500),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: WoodPanel(
            width: isSmall ? 200 : 250,
            height: isSmall ? 60 : 80,
            color: color,
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isSmall) Icon(icon, color: Colors.white, size: 40),
                if (!isSmall) SizedBox(width: 15),
                Text(text, style: TextStyle(fontSize: isSmall ? 20 : 32, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );
  }
}