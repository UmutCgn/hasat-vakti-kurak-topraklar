import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/game_provider.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan (Sadece bunu resim olarak tutuyoruz, atmosfer için)
          Positioned.fill(
            child: Image.asset('assets/images/bg_arid.png', fit: BoxFit.cover),
          ),

          // Hafif bir karartma atalım ki UI parlasın
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10),

                // 1. MODERN ÜST BAR (Level yok, Sadece Para)
                _buildModernTopBar(context),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      SizedBox(height: 30),

                      _buildGameTitle(),

                      // 2. DEVASA MODERN OYNA BUTONU
                      _buildModernPlayButton(context),

                      SizedBox(height: 40),

                      // 3. KODLA ÇİZİLMİŞ AHŞAP AMBAR PANELİ
                      _buildModernStoragePanel(context),

                      SizedBox(height: 30),

                      // 4. MARKET PANELİ
                      _buildMarketSection(context),

                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 1. MODERN ÜST BAR (Resim yok, Kodla çizim)
  Widget _buildModernTopBar(BuildContext context) {
    var game = context.watch<GameProvider>();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Yarı saydam beyaz arka plan
        borderRadius: BorderRadius.circular(30), // Yuvarlak köşeler
        border: Border.all(color: Color(0xFF5D4037), width: 3), // Koyu kahve çerçeve
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Ortala
        children: [
          // Para İkonu (Flutter ikonu)
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber[400],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber[800]!, width: 2),
            ),
            child: Icon(Icons.monetization_on, color: Colors.white, size: 30),
          ),
          SizedBox(width: 15),
          
          // Para Yazısı
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${game.totalMoney}",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3E2723),
                  fontFamily: 'Roboto', // Varsa özel fontunu buraya ekle
                ),
              ),
              Text(
                "TOPLAM ALTIN",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[400],
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔥 2. DEVASA MODERN OYNA BUTONU (Resimsiz)
  Widget _buildModernPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GameScreen()),
      ),
      child: Container(
        height: 140, // Yükseklik
        decoration: BoxDecoration(
          // Yeşil Gradyan (Yukarıdan aşağıya)
          gradient: LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)], 
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Color(0xFF1B5E20), width: 4), // Koyu yeşil çerçeve
          boxShadow: [
            // Butonun altındaki 3D efekti (Gölge)
            BoxShadow(
              color: Color(0xFF1B5E20),
              offset: Offset(0, 8), // Aşağı doğru sert gölge
              blurRadius: 0, // Bulanıklık yok, sert çizgi (Cartoon effect)
            ),
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 15),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Traktör İkonu
            Icon(Icons.agriculture, color: Colors.white, size: 60),
            SizedBox(width: 20),
            Text(
              "TARLAYA GİT",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 3. MODERN DEPO PANELİ (Ahşap Görünümü Kodla)
  Widget _buildModernStoragePanel(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) => Container(
        // Ahşap rengi zemin
        decoration: BoxDecoration(
          color: Color(0xFF8D6E63), // Ahşap kahverengisi
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF5D4037), width: 4),
          boxShadow: [
            BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Başlık
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFF5D4037), // Daha koyu kahve şerit
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "AMBAR & ÜRETİM",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Ürünler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStorageItem(
                  'assets/images/icon_egg.png', // Ürün resimleri kalmalı (özeller)
                  "${game.inventory['egg']}",
                  "Yumurta",
                ),
                _buildStorageItem(
                  'assets/images/icon_milk.png',
                  "${game.inventory['milk']}",
                  "Süt",
                ),
                _buildStorageItem(
                  'assets/images/icon_bread.png',
                  "${game.inventory['bread']}",
                  "Ekmek",
                ),
              ],
            ),
            
            SizedBox(height: 20),

            // Sat Butonu
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFB300), // Amber/Altın rengi buton
                  foregroundColor: Colors.brown[900], // Yazı rengi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  int earned = game.sellAllProduce();
                  if (earned > 0)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Kazanç: $earned Altın!"), backgroundColor: Colors.green),
                    );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sell, size: 28),
                    SizedBox(width: 10),
                    Text(
                      "TÜMÜNÜ SAT",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ürün İtemleri (Büyütüldü ve çerçeve eklendi)
  Widget _buildStorageItem(String img, String count, String label) {
    return Column(
      children: [
        // İkon Arka Planı
        Container(
          width: 80, // Büyütüldü
          height: 80, // Büyütüldü
          decoration: BoxDecoration(
            color: Colors.white38, // Arkada hafif şeffaf beyazlık
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFF5D4037), width: 2),
          ),
          padding: EdgeInsets.all(12),
          child: Image.asset(img, fit: BoxFit.contain),
        ),
        SizedBox(height: 5),
        // Adet
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26, // Yazı büyütüldü
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        // İsim
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // 🔥 4. MARKET PANELİ
  Widget _buildMarketSection(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) => Column(
        children: [
          Row(
            children: [
              Icon(Icons.storefront, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                "YAPI MARKETİ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                ),
              ),
            ],
          ),
          Divider(color: Colors.white30, thickness: 2),
          SizedBox(height: 10),

          _buildBuildingCard(
            context,
            game,
            "Taş Fırın",
            "Ekmek üretir",
            5000,
            "assets/images/building_bakery.png",
            "bakery",
          ),
          SizedBox(height: 15),
          _buildBuildingCard(
            context,
            game,
            "Büyük Silo",
            "Kapasite Artar",
            3000,
            "assets/images/building_silo.png",
            "silo",
          ),
          SizedBox(height: 15),
          _buildBuildingCard(
            context,
            game,
            "Ambar +50",
            "Daha çok stok",
            1500,
            "assets/images/building_barn.png",
            "barn_upgrade",
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingCard(
    BuildContext context,
    GameProvider g,
    String title,
    String desc,
    int price,
    String imgPath,
    String id,
  ) {
    bool owned = (id == 'bakery' || id == 'silo') && g.inventory[id]! > 0;
    bool canAfford = g.totalMoney >= price;

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Kartlar artık beyazımsı
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          // Bina Resmi
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(5),
            child: Image.asset(imgPath, fit: BoxFit.contain),
          ),
          SizedBox(width: 15),
          
          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                SizedBox(height: 5),
                Text(
                  owned ? "✅ SAHİBİSİN" : "💰 $price Altın",
                  style: TextStyle(
                    color: owned
                        ? Colors.green[700]
                        : (canAfford ? Colors.orange[800] : Colors.red[700]),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          
          // Satın Al Butonu
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: owned
                  ? Colors.grey
                  : (canAfford ? Colors.green : Colors.redAccent),
              shape: CircleBorder(),
              padding: EdgeInsets.all(12),
            ),
            onPressed: owned ? null : () => g.buyBuilding(id, price),
            child: Icon(
              owned ? Icons.check : Icons.shopping_cart,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  // 🔥 OYUN BAŞLIĞI WIDGET'I
  Widget _buildGameTitle() {
    return Column(
      children: [
        Text(
          "HASAT VAKTİ",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2.0,
            shadows: [
              Shadow( // Sert gölge (Cartoon efekt)
                offset: Offset(4, 4),
                color: Color(0xFF3E2723),
                blurRadius: 0, 
              ),
              Shadow( // Yumuşak gölge
                offset: Offset(0, 5),
                color: Colors.black45,
                blurRadius: 10, 
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          color: Color(0xFF3E2723), // Alt başlık arka planı
          child: Text(
            "KURAK TOPRAKLAR",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber[400], // Yanık turuncu/sarı
              letterSpacing: 4.0,
            ),
          ),
        ),
      ],
    );
  }
}