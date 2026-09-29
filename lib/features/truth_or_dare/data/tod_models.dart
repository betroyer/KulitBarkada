enum TodPromptType { truth, dare }

enum TodDifficulty { easy, medium, hard }

enum TodGameMode { classic, random, couples, party, custom }

class TodPrompt {
  const TodPrompt({
    required this.id,
    required this.category,
    required this.type,
    required this.text,
    required this.difficulty,
    this.isCustom = false,
    this.isFavorite = false,
  });

  final int id;
  final String category;
  final TodPromptType type;
  final String text;
  final TodDifficulty difficulty;
  final bool isCustom;
  final bool isFavorite;

  TodPrompt copyWith({
    String? text,
    String? category,
    TodPromptType? type,
    TodDifficulty? difficulty,
    bool? isFavorite,
  }) {
    return TodPrompt(
      id: id,
      category: category ?? this.category,
      type: type ?? this.type,
      text: text ?? this.text,
      difficulty: difficulty ?? this.difficulty,
      isCustom: isCustom,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory TodPrompt.fromMap(Map<String, dynamic> map) {
    return TodPrompt(
      id: map['id'] as int,
      category: map['category'] as String,
      type: (map['type'] as String) == 'dare' ? TodPromptType.dare : TodPromptType.truth,
      text: map['text'] as String,
      difficulty: TodDifficulty.values.firstWhere(
        (d) => d.name == (map['difficulty'] as String? ?? 'medium'),
        orElse: () => TodDifficulty.medium,
      ),
      isCustom: (map['is_custom'] as int? ?? 0) == 1,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'category': category,
        'type': type == TodPromptType.dare ? 'dare' : 'truth',
        'text': text,
        'difficulty': difficulty.name,
        'is_custom': isCustom ? 1 : 0,
        'is_favorite': isFavorite ? 1 : 0,
      };
}

class TodPlayer {
  TodPlayer({
    required this.id,
    required this.name,
    this.points = 0,
    this.truthsCompleted = 0,
    this.daresCompleted = 0,
    this.skipped = 0,
  });

  final String id;
  String name;
  int points;
  int truthsCompleted;
  int daresCompleted;
  int skipped;

  TodPlayer copy() => TodPlayer(
        id: id,
        name: name,
        points: points,
        truthsCompleted: truthsCompleted,
        daresCompleted: daresCompleted,
        skipped: skipped,
      );
}

class TodSettings {
  const TodSettings({
    this.soundEnabled = true,
    this.musicEnabled = false,
    this.vibrationEnabled = true,
    this.scoringEnabled = true,
    this.maxRounds = 0,
    this.allowRepetition = false,
    this.difficulty = TodDifficulty.medium,
  });

  /// 0 = unlimited rounds
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final bool scoringEnabled;
  final int maxRounds;
  final bool allowRepetition;
  final TodDifficulty difficulty;

  TodSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    bool? scoringEnabled,
    int? maxRounds,
    bool? allowRepetition,
    TodDifficulty? difficulty,
  }) {
    return TodSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      scoringEnabled: scoringEnabled ?? this.scoringEnabled,
      maxRounds: maxRounds ?? this.maxRounds,
      allowRepetition: allowRepetition ?? this.allowRepetition,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

class TodSessionConfig {
  const TodSessionConfig({
    required this.mode,
    required this.players,
    required this.categories,
    this.difficulty = TodDifficulty.medium,
  });

  final TodGameMode mode;
  final List<TodPlayer> players;
  final Set<String> categories;
  final TodDifficulty difficulty;
}

class TodGameSnapshot {
  const TodGameSnapshot({
    required this.players,
    required this.currentIndex,
    required this.round,
    required this.totalTruths,
    required this.totalDares,
    required this.totalSkipped,
    this.currentPrompt,
    this.currentType,
    this.waitingChoice = true,
  });

  final List<TodPlayer> players;
  final int currentIndex;
  final int round;
  final int totalTruths;
  final int totalDares;
  final int totalSkipped;
  final TodPrompt? currentPrompt;
  final TodPromptType? currentType;
  final bool waitingChoice;

  TodPlayer get currentPlayer => players[currentIndex];
}
