import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../logic/game_provider.dart';
import '../../models/block_model.dart';
import 'main_menu_screen.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey gridKey = GlobalKey();
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_arid.png', fit: BoxFit.cover),
          ), //
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Consumer<GameProvider>(
                        builder: (context, game, child) => ShakeWidget(
                          isShaking: game.isShaking,
                          child: child!,
                        ),
                        child: DragTarget<BlockModel>(
                          onMove: (d) => _handleDrag(
                            context,
                            d.offset,
                            context.read<GameProvider>(),
                          ),
                          onLeave: (d) =>
                              context.read<GameProvider>().clearPreview(),
                          onAcceptWithDetails: (d) {
                            final g = context.read<GameProvider>();
                            // 🔥 KRİTİK DÜZELTME: Artık bırakılan koordinat doğru hesaplanıyor
                            final coords = _calculateGridCoords(
                              context,
                              d.offset,
                              g,
                            );
                            if (coords != null)
                              g.placeBlock(
                                coords.dx.toInt(),
                                coords.dy.toInt(),
                              );
                          },
                          builder: (context, _, __) => Column(
                            children: [
                              _buildScoreBoard(),
                              _buildMissionText(),
                              _buildGridArea(),
                              _buildHandPanel(),
                            ],
                          ),
                        ),
                      ),
                      _buildTractor(),
                      _buildPopupText(),
                      _buildGameOverOverlay(),
                      _buildFoundAnimalOverlay(),
                    ],
                  ),
                ),
                if (_isAdLoaded)
                  Container(height: 50, child: AdWidget(ad: _bannerAd!)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoundAnimalOverlay() {
    return Consumer<GameProvider>(
      builder: (context, g, _) {
        if (!g.showFoundAnim || g.foundAnimalAsset == null) return SizedBox();
        return Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
            builder: (context, val, child) {
              return Transform.scale(
                scale: val,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/particle_leaf1.png',
                      width: 100,
                    ), //
                    Image.asset(g.foundAnimalAsset!, width: 250),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 40),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainMenuScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Consumer<GameProvider>(
      builder: (c, g, _) => Container(
        width: 360,
        height: 90, // 🔥 DÜZELTME: Genişlik arttırıldı (200 -> 280)
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ui_panel_score1.png'),
            fit: BoxFit.fill,
          ),
        ), // 🔥 DÜZELTME: BoxFit.fill yapıldı
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 8),
        child: Text(
          "HASAT: ${g.score}",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.brown[900],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionText() {
    return Consumer<GameProvider>(
      builder: (c, g, _) => Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          g.missionText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 3)],
          ),
        ),
      ),
    );
  }

  Widget _buildGridArea() {
    return Expanded(
      child: Center(
        child: Consumer<GameProvider>(
          builder: (c, g, _) => AspectRatio(
            aspectRatio: 1,
            child: Container(
              margin: EdgeInsets.all(10),
              // Arka plana hafif bir panel ekleyelim ki grid havada durmasın
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.brown[300]!.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: GridView.builder(
                key: gridKey,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 49,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemBuilder: (context, i) {
                  int x = i ~/ 7, y = i % 7;
                  var cell = g.grid[x][y];
                  bool prev = g.previewCells.contains("$x,$y");

                  String img = 'assets/images/cell_empty_dry1.png';
                  if (cell.isFilled) {
                    if (cell.readyToHarvest)
                      img = 'assets/images/cell_crop_ready1.png';
                    else if (cell.isGrowing)
                      img = 'assets/images/cell_crop_growing1.png';
                    else
                      img = 'assets/images/cell_filled_dry1.png';
                  } else if (cell.isBurnedGap) {
                    img = 'assets/images/cell_water1.png';
                  }

                  return Container(
                    decoration: BoxDecoration(
                      // 🔥 ÖNİZLEME: Eğer buraya blok gelecekse yeşil çerçeve yak!
                      border: prev
                          ? Border.all(color: Colors.greenAccent, width: 3)
                          : null,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Opacity(
                      // Önizleme ise hafif şeffaf olsun ama çerçeve net kalsın
                      opacity: prev ? 0.7 : 1,
                      child: Image.asset(img, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandPanel() {
    return Container(
      height: 140, // Yükseklik biraz arttı rahat sığsın
      padding: EdgeInsets.only(bottom: 10),
      child: Consumer<GameProvider>(
        builder: (c, g, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) {
            bool isActive = g.draggingIndex == i; // Bu slot mu sürükleniyor?
            return DragTarget<BlockModel>(
              onAccept: (_) => g.cancelDrag(),
              builder: (c, _, __) => AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: isActive ? 110 : 100, // Aktifse büyür
                height: isActive ? 110 : 100,
                transform: isActive
                    ? Matrix4.diagonal3Values(1.1, 1.1, 1)
                    : Matrix4.identity(),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/ui_panel_slot1.png'),
                    fit: BoxFit.fill,
                  ),
                  // 🔥 EFEKT: Aktifse sarı ışık saç (Glow)
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.amberAccent.withOpacity(0.8),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  // 🔥 HİZALAMA: Bloğu tam ortaya koyar
                  child: g.hand[i] != null
                      ? Draggable<BlockModel>(
                          data: g.hand[i],
                          onDragStarted: () => g.startDrag(i),
                          onDragEnd: (_) => g.clearPreview(),
                          // 🔥 GÖRÜNTÜ: Sürüklerken sınırları belirgin (border: true)
                          feedback: Material(
                            color: Colors.transparent,
                            child: _block(
                              g.hand[i]!,
                              35,
                              border: true,
                              isFeedback: true,
                            ),
                          ),
                          // Slotun içindeki duruş (Daha toplu durması için scale ayarlı)
                          child: g.draggingIndex == i
                              ? SizedBox() // Sürüklenirken slot boş kalsın (veya silik görünsün)
                              : FittedBox(
                                  fit: BoxFit.contain,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: _block(g.hand[i]!, 25),
                                  ),
                                ),
                        )
                      : null,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // 🔥 GÜNCELLEME: Sınırları belirginleştiren parametreler eklendi
  Widget _block(
    BlockModel b,
    double s, {
    bool border = false,
    bool isFeedback = false,
  }) {
    // Toplam genişlik/yükseklik hesapla ki ortalayabilelim
    double w = b.width * s;
    double h = b.height * s;

    return Container(
      width: w,
      height: h,
      child: Stack(
        children: b.shape.map((p) {
          return Positioned(
            left: p[1] * s,
            top: p[0] * s,
            child: Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/cell_filled_dry1.png'),
                  fit: BoxFit.cover,
                  // Feedback ise biraz şeffaflaştır
                  colorFilter: isFeedback
                      ? ColorFilter.mode(
                          Colors.white.withOpacity(0.9),
                          BlendMode.modulate,
                        )
                      : null,
                ),
                // 🔥 SINIRLAR: Eğer border true ise her karenin etrafına çizgi çek
                border: border
                    ? Border.all(color: Colors.white, width: 2)
                    : Border.all(
                        color: Colors.black12,
                        width: 0.5,
                      ), // Hafif kontür
                boxShadow: isFeedback
                    ? [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ]
                    : [],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTractor() {
    return Consumer<GameProvider>(
      builder: (c, g, _) => AnimatedPositioned(
        duration: Duration(seconds: 2),
        left: g.isHarvesting ? 500 : -300,
        top: 300,
        child: Image.asset('assets/images/icon_tractor1.png', width: 200),
      ),
    );
  } //

  Widget _buildPopupText() {
    return Consumer<GameProvider>(
      builder: (c, g, _) => g.showPopup
          ? Center(
              child: Text(
                g.popupText ?? "",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10)],
                ),
              ),
            )
          : SizedBox(),
    );
  }

  Widget _buildGameOverOverlay() {
    return Consumer<GameProvider>(
      builder: (c, g, _) => g.isGameOver
          ? Container(
              color: Colors.black87,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => g.restartGame(),
                  child: Text("TEKRAR"),
                ),
              ),
            )
          : SizedBox(),
    );
  }

  // --- SÜRÜKLEME VE BIRAKMA HESAPLAMALARI ---
  void _handleDrag(BuildContext c, Offset p, GameProvider g) {
    var box = gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    var lp = box.globalToLocal(p);
    double s = box.size.width / 7;
    int y = (lp.dx / s).floor(), x = (lp.dy / s).floor();
    if (x >= 0 && x < 7 && y >= 0 && y < 7) g.setPreview(x, y);
  }

  // 🔥 KRİTİK DÜZELTME: Bırakma koordinatlarını hesaplayan fonksiyon geri geldi
  Offset? _calculateGridCoords(BuildContext c, Offset p, GameProvider g) {
    final RenderBox? box =
        gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final localPos = box.globalToLocal(p);
    double cellSize = box.size.width / 7;
    int y = (localPos.dx / cellSize).floor();
    int x = (localPos.dy / cellSize).floor();
    if (x >= 0 && x < 7 && y >= 0 && y < 7) {
      // Bırakılan yer geçerli mi diye son bir kez kontrol et (isteğe bağlı ama güvenli)
      if (g.canPlaceAt(x, y)) {
        return Offset(x.toDouble(), y.toDouble());
      }
    }
    return null;
  }
}

class ShakeWidget extends StatelessWidget {
  final bool isShaking;
  final Widget child;
  const ShakeWidget({required this.isShaking, required this.child});
  @override
  Widget build(BuildContext c) => isShaking
      ? Transform.translate(
          offset: Offset(sin(DateTime.now().millisecondsSinceEpoch) * 5, 0),
          child: child,
        )
      : child;
}
