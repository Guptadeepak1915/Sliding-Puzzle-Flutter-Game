class GameSettings {
  const GameSettings({
    this.boardSize = 4,
    this.soundEnabled = true,
    this.masterVolume = 0.65,
    this.hapticsEnabled = true,
    this.animationsEnabled = true,
  });

  final int boardSize;
  final bool soundEnabled;
  final double masterVolume;
  final bool hapticsEnabled;
  final bool animationsEnabled;

  GameSettings copyWith({
    int? boardSize,
    bool? soundEnabled,
    double? masterVolume,
    bool? hapticsEnabled,
    bool? animationsEnabled,
  }) {
    return GameSettings(
      boardSize: boardSize ?? this.boardSize,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      masterVolume: masterVolume ?? this.masterVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }
}
