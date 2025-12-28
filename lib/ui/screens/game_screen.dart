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
              child: GridView.builder(
                key: gridKey,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 49,
                // 🔥 DÜZELTME: Boşluklar arttırıldı (1 -> 3)
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemBuilder: (context, i) {
                  int x = i ~/ 7, y = i % 7;
                  var cell = g.grid[x][y];
                  bool prev = g.previewCells.contains("$x,$y");
                  String img = 'assets/images/cell_empty_dry1.png'; //
                  if (cell.isFilled) {
                    if (cell.readyToHarvest)
                      img = 'assets/images/cell_crop_ready1.png'; //
                    else if (cell.isGrowing)
                      img = 'assets/images/cell_crop_growing1.png'; //
                    else
                      img =
                          'assets/images/cell_filled_dry1.png'; // İsim düzeltildi
                  } else if (cell.isBurnedGap)
                    img = 'assets/images/cell_water1.png'; //
                  return Opacity(
                    opacity: prev ? 0.6 : 1,
                    child: Image.asset(img, fit: BoxFit.cover),
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
      height: 130,
      child: Consumer<GameProvider>(
        builder: (c, g, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (i) => DragTarget<BlockModel>(
              onAccept: (_) => g.cancelDrag(),
              builder: (c, _, __) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/ui_panel_slot1.png'),
                  ),
                ), //
                child: g.hand[i] != null
                    ? Draggable<BlockModel>(
                        data: g.hand[i],
                        onDragStarted: () => g.startDrag(i),
                        onDragEnd: (_) => g.clearPreview(),
                        feedback: _block(g.hand[i]!, 30),
                        child: g.draggingIndex == i
                            ? SizedBox()
                            : _block(g.hand[i]!, 20),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _block(BlockModel b, double s) => Container(
    width: b.width * s,
    height: b.height * s,
    child: Stack(
      children: b.shape
          .map(
            (p) => Positioned(
              left: p[1] * s,
              top: p[0] * s,
              child: Image.asset(
                'assets/images/cell_filled_dry1.png',
                width: s,
                height: s,
                fit: BoxFit.cover,
              ),
            ),
          )
          .toList(),
    ),
  );

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
