class BlockModel {
  final List<List<int>> shape; 
  final String id;
  final int difficulty; // 1: Kolay, 2: Orta, 3: Zor

  BlockModel({
    required this.shape, 
    required this.id, 
    this.difficulty = 1
  });

  int get width {
    int maxY = shape.map((p) => p[1]).reduce((a, b) => a > b ? a : b);
    return maxY + 1;
  }

  int get height {
    int maxX = shape.map((p) => p[0]).reduce((a, b) => a > b ? a : b);
    return maxX + 1;
  }

  static List<BlockModel> getAllBlocks() {
    return [
      // --- KOLAY (Kurtarıcılar) ---
      BlockModel(id: "dot", shape: [[0, 0]], difficulty: 1),
      BlockModel(id: "mini_h", shape: [[0, 0], [0, 1]], difficulty: 1),
      BlockModel(id: "mini_v", shape: [[0, 0], [1, 0]], difficulty: 1),
      BlockModel(id: "corner_small", shape: [[0, 0], [0, 1], [1, 0]], difficulty: 1), // Küçük Köşe

      // --- ORTA (Klasikler ve Döndürülmüş Halleri) ---
      // Kare
      BlockModel(id: "square", shape: [[0, 0], [0, 1], [1, 0], [1, 1]], difficulty: 2),
      
      // Çubuklar
      BlockModel(id: "line_3h", shape: [[0, 0], [0, 1], [0, 2]], difficulty: 2),
      BlockModel(id: "line_3v", shape: [[0, 0], [1, 0], [2, 0]], difficulty: 2),

      // L Şekli ve Döndürülmüşleri
      BlockModel(id: "L_norm", shape: [[0, 0], [1, 0], [2, 0], [2, 1]], difficulty: 2), // Normal L
      BlockModel(id: "L_rot90", shape: [[0, 0], [0, 1], [0, 2], [1, 0]], difficulty: 2), // Yatık L
      BlockModel(id: "L_rot180", shape: [[0, 0], [0, 1], [1, 1], [2, 1]], difficulty: 2), // Ters L
      BlockModel(id: "L_rot270", shape: [[1, 0], [1, 1], [1, 2], [0, 2]], difficulty: 2), // Ters Yatık L

      // J Şekli (L'nin aynası)
      BlockModel(id: "J_norm", shape: [[0, 1], [1, 1], [2, 1], [2, 0]], difficulty: 2),

      // T Şekli ve Döndürülmüşleri
      BlockModel(id: "T_norm", shape: [[0, 1], [1, 0], [1, 1], [1, 2]], difficulty: 2),
      BlockModel(id: "T_rot90", shape: [[0, 0], [1, 0], [2, 0], [1, 1]], difficulty: 2),
      BlockModel(id: "T_rot180", shape: [[0, 0], [0, 1], [0, 2], [1, 1]], difficulty: 2),
      BlockModel(id: "T_rot270", shape: [[1, 0], [0, 1], [1, 1], [2, 1]], difficulty: 2),

      // --- ZOR (Karmaşık Şekiller) ---
      BlockModel(id: "line_4h", shape: [[0, 0], [0, 1], [0, 2], [0, 3]], difficulty: 3),
      BlockModel(id: "Z_norm", shape: [[0, 0], [0, 1], [1, 1], [1, 2]], difficulty: 3),
      BlockModel(id: "S_norm", shape: [[0, 1], [0, 2], [1, 0], [1, 1]], difficulty: 3),
      BlockModel(id: "U_shape", shape: [[0, 0], [0, 2], [1, 0], [1, 1], [1, 2]], difficulty: 3),
      BlockModel(id: "Plus", shape: [[0, 1], [1, 0], [1, 1], [1, 2], [2, 1]], difficulty: 3), // Artı Şekli
    ];
  }
}