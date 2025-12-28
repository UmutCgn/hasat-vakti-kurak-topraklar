import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/block_model.dart';
import '../localization.dart';

enum MissionType { gap3, gap4, gap5, gap6 }

class GameProvider extends ChangeNotifier {
  // --- TEMEL ---
  static const int gridSize = 7;
  List<List<Cell>> grid = [];
  List<BlockModel?> hand = [null, null, null];
  int? draggingIndex;
  List<String> previewCells = [];
  bool isGameOver = false;
  int score = 0;

  // --- TYCOON & İLERLEME ---
  int totalMoney = 1000;
  int farmLevel = 1;
  int harvestCount = 0; // Garantili hayvan takibi için

  // Envanter & Yapılar
  Map<String, int> inventory = {
    'cow': 0, 'chicken': 0,
    'egg': 0, 'milk': 0, 'bread': 0,
    'barn_capacity': 50,
    'bakery': 0, 'silo': 0, // Yapılar (0: Yok, 1: Var)
  };

  // --- ANİMASYON ---
  bool showFoundAnim = false;
  String? foundAnimalAsset;
  Timer? _productionTimer;

  // --- OYUN İÇİ ---
  String languageCode = 'tr';
  bool isShaking = false;
  String? popupText;
  bool showPopup = false;
  bool isHarvesting = false;
  MissionType currentMission = MissionType.gap3;
  int missionTarget = 1;
  int missionProgress = 0;
  double gapBarProgress = 0.0;

  GameProvider() {
    _initializeGrid();
    _generateNewMission();
    _refillHand();
    _startProductionCycle();
  }

  // 🔥 1. ÜRETİM DÖNGÜSÜ (FIRIN DAHİL)
  void _startProductionCycle() {
    _productionTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      bool updated = false;
      int cap = inventory['barn_capacity']!;

      // Tavuk -> Yumurta
      if (inventory['chicken']! > 0 && Random().nextBool()) {
        if (inventory['egg']! < cap) {
          inventory['egg'] = inventory['egg']! + inventory['chicken']!;
          updated = true;
        }
      }
      // İnek -> Süt
      if (inventory['cow']! > 0 && Random().nextBool()) {
        if (inventory['milk']! < cap) {
          inventory['milk'] = inventory['milk']! + inventory['cow']!;
          updated = true;
        }
      }
      // Fırın -> Ekmek
      if (inventory['bakery']! > 0 && inventory['bread']! < cap) {
        if (Random().nextDouble() < 0.4) {
          // %40 şansla ekmek çıkar
          inventory['bread'] = inventory['bread']! + 1;
          updated = true;
        }
      }
      if (updated) notifyListeners();
    });
  }

  // --- 2. HASAT VE GARANTİLİ HAYVAN ---
  void _triggerHarvestTractor() {
    isHarvesting = true;
    score += 500;
    harvestCount++;

    // 🔥 GARANTİLİ HAYVAN MANTIĞI
    if (harvestCount == 1) {
      inventory['chicken'] = inventory['chicken']! + 1;
      _showAnimalFoundAnimation('assets/images/anim_chicken.png', "İLK TAVUK!");
    } else if (harvestCount == 2) {
      inventory['cow'] = inventory['cow']! + 1;
      _showAnimalFoundAnimation('assets/images/anim_cow.png', "İLK İNEK!");
    } else {
      // Nadir şans (%10)
      if (Random().nextInt(100) < 10) {
        bool isCow = Random().nextBool();
        String img = isCow
            ? 'assets/images/anim_cow.png'
            : 'assets/images/anim_chicken.png';
        inventory[isCow ? 'cow' : 'chicken'] =
            inventory[isCow ? 'cow' : 'chicken']! + 1;
        _showAnimalFoundAnimation(img, "YENİ HAYVAN!");
      } else {
        _triggerJuiceEffects("HASAT ZAMANI!");
      }
    }

    Timer(const Duration(milliseconds: 1000), () {
      for (var row in grid)
        for (var cell in row)
          if (cell.readyToHarvest) {
            cell.isFilled = false;
            cell.isGrowing = false;
            cell.readyToHarvest = false;
            cell.growthTimer = 0;
          }
      isHarvesting = false;
      _processFarmLogic();
      notifyListeners();
    });
  }

  void _showAnimalFoundAnimation(String image, String text) {
    foundAnimalAsset = image;
    showFoundAnim = true;
    _triggerJuiceEffects(text);
    notifyListeners();
    Timer(Duration(seconds: 3), () {
      showFoundAnim = false;
      foundAnimalAsset = null;
      notifyListeners();
    });
  }

  // --- 3. MARKET VE SATIŞ ---
  bool buyBuilding(String type, int cost) {
    if (totalMoney >= cost) {
      totalMoney -= cost;
      if (type == 'bakery')
        inventory['bakery'] = 1;
      else if (type == 'silo')
        inventory['silo'] = 1;
      else if (type == 'barn_upgrade')
        inventory['barn_capacity'] = inventory['barn_capacity']! + 50;
      notifyListeners();
      return true;
    }
    return false;
  }

  int sellAllProduce() {
    int earnings =
        (inventory['egg']! * 5) +
        (inventory['milk']! * 15) +
        (inventory['bread']! * 50);
    inventory['egg'] = 0;
    inventory['milk'] = 0;
    inventory['bread'] = 0;
    totalMoney += earnings;
    notifyListeners();
    return earnings;
  }

  // --- STANDART FONKSİYONLAR (Kısaltılmadı, tam çalışması için gerekli) ---
  String t(String key) => AppStrings.dictionary[languageCode]?[key] ?? key;
  void setLanguage(String code) {
    languageCode = code;
    notifyListeners();
  }

  String get missionText {
    switch (currentMission) {
      case MissionType.gap3:
        return "3 Karelik Havuz";
      case MissionType.gap4:
        return "4 Karelik Havuz";
      case MissionType.gap5:
        return "5 Karelik Havuz";
      case MissionType.gap6:
        return "6 Karelik Havuz";
    }
  }

  void _initializeGrid() {
    grid = List.generate(
      gridSize,
      (x) => List.generate(gridSize, (y) => Cell(x: x, y: y)),
    );
  }

  void restartGame() {
    isGameOver = false;
    gapBarProgress = 0.0;
    score = 0;
    popupText = null;
    showPopup = false;
    isHarvesting = false;
    showFoundAnim = false;
    _initializeGrid();
    _generateNewMission();
    _refillHand();
    notifyListeners();
  }

  void _refillHand() {
    for (int i = 0; i < 3; i++) hand[i] = _generateDifficultyBasedBlock();
    _checkGameOver();
    notifyListeners();
  }

  BlockModel _generateDifficultyBasedBlock() {
    final all = BlockModel.getAllBlocks();
    int empty = 0;
    for (var r in grid) for (var c in r) if (!c.isFilled) empty++;
    return empty < 12
        ? all.where((b) => b.difficulty == 1).toList()[Random().nextInt(3)]
        : all[Random().nextInt(all.length)];
  }

  void _checkGameOver() {
    bool can = false;
    for (var b in hand) if (b != null && _canPlace(b)) can = true;
    if (!can) {
      isGameOver = true;
      notifyListeners();
    }
  }

  void startDrag(int i) {
    draggingIndex = i;
    notifyListeners();
  }

  void cancelDrag() {
    draggingIndex = null;
    clearPreview();
    notifyListeners();
  }

  bool canPlaceAt(int r, int c) =>
      draggingIndex != null &&
      hand[draggingIndex!] != null &&
      _checkFit(r, c, hand[draggingIndex!]!);
  bool _canPlace(BlockModel b) {
    for (int x = 0; x < 7; x++)
      for (int y = 0; y < 7; y++) if (_checkFit(x, y, b)) return true;
    return false;
  }

  bool _checkFit(int x, int y, BlockModel b) {
    for (var p in b.shape) {
      int tx = x + p[0], ty = y + p[1];
      if (tx < 0 || tx >= 7 || ty < 0 || ty >= 7 || grid[tx][ty].isFilled)
        return false;
    }
    return true;
  }

  void setPreview(int x, int y) {
    if (draggingIndex == null) return;
    List<String> t = [];
    bool ok = true;
    for (var p in hand[draggingIndex!]!.shape) {
      int tx = x + p[0], ty = y + p[1];
      if (tx < 0 || tx >= 7 || ty < 0 || ty >= 7 || grid[tx][ty].isFilled) {
        ok = false;
        break;
      }
      t.add("$tx,$ty");
    }
    previewCells = ok ? t : [];
    notifyListeners();
  }

  void clearPreview() {
    previewCells.clear();
    notifyListeners();
  }

  bool placeBlock(int r, int c) {
    if (previewCells.isEmpty) return false;
    for (var p in previewCells) {
      var s = p.split(',');
      grid[int.parse(s[0])][int.parse(s[1])].isFilled = true;
      grid[int.parse(s[0])][int.parse(s[1])].growthTimer = 0;
    }
    hand[draggingIndex!] = null;
    draggingIndex = null;
    clearPreview();
    _processFarmLogic();
    if (hand.every((e) => e == null))
      _refillHand();
    else
      _checkGameOver();
    return true;
  }

  void _processFarmLogic() {
    for (var r in grid) for (var c in r) c.isBurnedGap = false;
    Set<String> vis = {};
    List<Cell> water = [];
    bool ready = false;
    for (int x = 0; x < 7; x++)
      for (int y = 0; y < 7; y++)
        if (!grid[x][y].isFilled && !vis.contains("$x,$y")) {
          List<Cell> g = [];
          Queue<Cell> q = Queue();
          q.add(grid[x][y]);
          vis.add("$x,$y");
          while (q.isNotEmpty) {
            Cell c = q.removeFirst();
            g.add(c);
            for (var d in [
              [0, 1],
              [0, -1],
              [1, 0],
              [-1, 0],
            ]) {
              int nx = c.x + d[0], ny = c.y + d[1];
              if (nx >= 0 &&
                  nx < 7 &&
                  ny >= 0 &&
                  ny < 7 &&
                  !grid[nx][ny].isFilled &&
                  !vis.contains("$nx,$ny")) {
                vis.add("$nx,$ny");
                q.add(grid[nx][ny]);
              }
            }
          }
          if (g.length >= 2 && g.length <= 6) {
            for (var c in g) {
              c.isBurnedGap = true;
              water.add(c);
            }
            _checkMissions(g.length);
          }
        }
    for (var w in water)
      for (var d in [
        [0, 1],
        [0, -1],
        [1, 0],
        [-1, 0],
      ]) {
        int nx = w.x + d[0], ny = w.y + d[1];
        if (nx >= 0 && nx < 7 && ny >= 0 && ny < 7 && grid[nx][ny].isFilled) {
          if (!grid[nx][ny].isGrowing)
            grid[nx][ny].isGrowing = true;
          else if (!grid[nx][ny].readyToHarvest) {
            grid[nx][ny].growthTimer++;
            if (grid[nx][ny].growthTimer >= 2) {
              grid[nx][ny].readyToHarvest = true;
              ready = true;
            }
          }
        }
      }
    if (ready) _triggerHarvestTractor();
    notifyListeners();
  }

  void _checkMissions(int s) {
    bool m = false;
    if (currentMission == MissionType.gap3 && s == 3) m = true;
    if (currentMission == MissionType.gap4 && s == 4) m = true;
    if (currentMission == MissionType.gap5 && s == 5) m = true;
    if (currentMission == MissionType.gap6 && s == 6) m = true;
    if (m) {
      missionProgress++;
      if (missionProgress >= missionTarget) {
        _generateNewMission();
        score += 1000;
        _triggerJuiceEffects("GÖREV TAMAM!");
      }
    }
  }

  void _triggerJuiceEffects(String t) {
    popupText = t;
    showPopup = true;
    notifyListeners();
    Timer(Duration(seconds: 2), () => showPopup = false);
  }

  void _generateNewMission() {
    currentMission = MissionType.values[Random().nextInt(4)];
    missionProgress = 0;
  }
  @override
  void dispose() {
    _productionTimer?.cancel(); // Zamanlayıcıyı temizle
    super.dispose();
  }
}
