import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Reklam Kütüphanesi
import 'logic/game_provider.dart';
import 'ui/screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // 🔥 REKLAMLARI BAŞLAT

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiny Farm',
      // Temayı Çiftlik renklerine çekiyoruz (Yeşil/Kahverengi)
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFE8F5E9), // Açık Yeşil Arka Plan
        fontFamily: 'Roboto', // Varsa tatlı bir font eklersin sonra
      ),
      home: MainMenuScreen(), 
    );
  }
}