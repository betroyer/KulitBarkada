import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/tod_models.dart';
import '../data/tod_repository.dart';

final todRepositoryProvider = Provider<TodRepository>((ref) => TodRepository());

final todReadyProvider = FutureProvider<void>((ref) async {
  await ref.watch(todRepositoryProvider).ensureReady();
});

class TodSettingsNotifier extends Notifier<TodSettings> {
  static const _prefix = 'tod_';

  @override
  TodSettings build() {
    _load();
    return const TodSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = TodSettings(
      soundEnabled: prefs.getBool('${_prefix}sound') ?? true,
      musicEnabled: prefs.getBool('${_prefix}music') ?? false,
      vibrationEnabled: prefs.getBool('${_prefix}vibration') ?? true,
      scoringEnabled: prefs.getBool('${_prefix}scoring') ?? true,
      maxRounds: prefs.getInt('${_prefix}max_rounds') ?? 0,
      allowRepetition: prefs.getBool('${_prefix}repetition') ?? false,
      difficulty: TodDifficulty.values.firstWhere(
        (d) => d.name == (prefs.getString('${_prefix}difficulty') ?? 'medium'),
        orElse: () => TodDifficulty.medium,
      ),
    );
  }

  Future<void> update(TodSettings next) async {
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}sound', next.soundEnabled);
    await prefs.setBool('${_prefix}music', next.musicEnabled);
    await prefs.setBool('${_prefix}vibration', next.vibrationEnabled);
    await prefs.setBool('${_prefix}scoring', next.scoringEnabled);
    await prefs.setInt('${_prefix}max_rounds', next.maxRounds);
    await prefs.setBool('${_prefix}repetition', next.allowRepetition);
    await prefs.setString('${_prefix}difficulty', next.difficulty.name);
  }

  Future<void> resetProgress() async {
    await ref.read(todRepositoryProvider).clearHistory();
  }
}

final todSettingsProvider = NotifierProvider<TodSettingsNotifier, TodSettings>(
  TodSettingsNotifier.new,
);

class TodGameNotifier extends Notifier<TodGameSnapshot?> {
  final Set<int> _usedPromptIds = {};
  TodSessionConfig? _config;
  String? _lastPlayerId;

  @override
  TodGameSnapshot? build() => null;

  TodSessionConfig? get config => _config;

  void start(TodSessionConfig config) {
    _config = config;
    _usedPromptIds.clear();
    _lastPlayerId = null;
    final players = config.players.map((p) => p.copy()).toList();
    final first = _pickNextIndex(players, excludeId: null);
    _lastPlayerId = players[first].id;
    state = TodGameSnapshot(
      players: players,
      currentIndex: first,
      round: 1,
      totalTruths: 0,
      totalDares: 0,
      totalSkipped: 0,
      waitingChoice: true,
    );
  }

  int _pickNextIndex(List<TodPlayer> players, {required String? excludeId}) {
    if (players.length == 1) return 0;
    final options = <int>[];
    for (var i = 0; i < players.length; i++) {
      if (players[i].id != excludeId) options.add(i);
    }
    options.shuffle();
    return options.first;
  }

  Future<void> chooseType(TodPromptType type) async {
    final snap = state;
    final cfg = _config;
    if (snap == null || cfg == null || !snap.waitingChoice) return;

    final settings = ref.read(todSettingsProvider);
    final prompt = await ref.read(todRepositoryProvider).randomPrompt(
          type: type,
          categories: cfg.categories,
          excludeIds: _usedPromptIds,
          difficulty: cfg.difficulty,
          allowRepetition: settings.allowRepetition,
        );
    if (prompt != null) _usedPromptIds.add(prompt.id);

    state = TodGameSnapshot(
      players: snap.players,
      currentIndex: snap.currentIndex,
      round: snap.round,
      totalTruths: snap.totalTruths,
      totalDares: snap.totalDares,
      totalSkipped: snap.totalSkipped,
      currentPrompt: prompt,
      currentType: type,
      waitingChoice: false,
    );
  }

  Future<void> assignRandomType() async {
    final type = DateTime.now().millisecond.isEven ? TodPromptType.truth : TodPromptType.dare;
    await chooseType(type);
  }

  Future<void> randomizeAgain() async {
    final snap = state;
    if (snap == null || snap.currentType == null) return;
    final type = snap.currentType!;
    // Allow re-roll by temporarily not requiring waitingChoice
    state = TodGameSnapshot(
      players: snap.players,
      currentIndex: snap.currentIndex,
      round: snap.round,
      totalTruths: snap.totalTruths,
      totalDares: snap.totalDares,
      totalSkipped: snap.totalSkipped,
      waitingChoice: true,
      currentType: type,
    );
    await chooseType(type);
  }

  void complete() {
    final snap = state;
    if (snap == null || snap.waitingChoice || snap.currentType == null) return;
    final settings = ref.read(todSettingsProvider);
    final players = snap.players.map((p) => p.copy()).toList();
    final player = players[snap.currentIndex];
    var truths = snap.totalTruths;
    var dares = snap.totalDares;

    if (snap.currentType == TodPromptType.truth) {
      player.truthsCompleted++;
      truths++;
      if (settings.scoringEnabled) player.points += 1;
    } else {
      player.daresCompleted++;
      dares++;
      if (settings.scoringEnabled) player.points += 2;
    }

    _advance(players, truths: truths, dares: dares, skipped: snap.totalSkipped, round: snap.round);
  }

  void skip() {
    final snap = state;
    if (snap == null || snap.waitingChoice) return;
    final players = snap.players.map((p) => p.copy()).toList();
    players[snap.currentIndex].skipped++;
    _advance(
      players,
      truths: snap.totalTruths,
      dares: snap.totalDares,
      skipped: snap.totalSkipped + 1,
      round: snap.round,
    );
  }

  void _advance(
    List<TodPlayer> players, {
    required int truths,
    required int dares,
    required int skipped,
    required int round,
  }) {
    final nextRound = round + 1;
    final nextIndex = _pickNextIndex(players, excludeId: _lastPlayerId);
    _lastPlayerId = players[nextIndex].id;
    state = TodGameSnapshot(
      players: players,
      currentIndex: nextIndex,
      round: nextRound,
      totalTruths: truths,
      totalDares: dares,
      totalSkipped: skipped,
      waitingChoice: true,
    );
  }

  bool get shouldEnd {
    final snap = state;
    if (snap == null) return false;
    final max = ref.read(todSettingsProvider).maxRounds;
    return max > 0 && snap.round > max;
  }

  Future<void> persistHistory() async {
    final snap = state;
    final cfg = _config;
    if (snap == null || cfg == null) return;
    final scores = snap.players
        .map((p) => {
              'name': p.name,
              'points': p.points,
              'truths': p.truthsCompleted,
              'dares': p.daresCompleted,
              'skipped': p.skipped,
            })
        .toList();
    await ref.read(todRepositoryProvider).saveHistory(
          mode: cfg.mode.name,
          rounds: snap.round - 1,
          truths: snap.totalTruths,
          dares: snap.totalDares,
          skipped: snap.totalSkipped,
          scoresJson: scores.toString(),
        );
  }

  void end() {
    state = null;
    _config = null;
    _usedPromptIds.clear();
    _lastPlayerId = null;
  }

  void resetUsedPrompts() {
    _usedPromptIds.clear();
  }
}

final todGameProvider = NotifierProvider<TodGameNotifier, TodGameSnapshot?>(TodGameNotifier.new);

final todCustomPromptsProvider = FutureProvider.autoDispose<List<TodPrompt>>((ref) {
  return ref.watch(todRepositoryProvider).listPrompts(customOnly: true);
});

final todCategoryCountsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = ref.watch(todRepositoryProvider);
  final map = <String, int>{};
  for (final c in ['classic', 'funny', 'friendship', 'couples', 'party', 'extreme']) {
    final list = await repo.listPrompts(category: c);
    map[c] = list.length;
  }
  return map;
});
