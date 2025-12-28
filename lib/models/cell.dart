class Cell {
  final int x;
  final int y;
  bool isFilled;
  bool isBurnedGap; // Suyun dolduğu yer
  bool isGrowing;   // Suya komşu olup yeşeren
  bool readyToHarvest; // Hasat vakti gelmiş buğday
  int growthTimer;  // 🔥 Büyümeyi sayan sayaç

  Cell({
    required this.x,
    required this.y,
    this.isFilled = false,
    this.isBurnedGap = false,
    this.isGrowing = false,
    this.readyToHarvest = false,
    this.growthTimer = 0,
  });
}