import 'package:sqflite/sqflite.dart';

import '../../../data/database_helper.dart';
import 'tod_models.dart';
import 'tod_seed.dart';

class TodRepository {
  TodRepository({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;
  bool _seeded = false;

  Future<Database> get _db async {
    final database = await _dbHelper.database;
    await _ensureTables(database);
    if (!_seeded) {
      await _seedIfNeeded(database);
      _seeded = true;
    }
    return database;
  }

  Future<void> ensureReady() async {
    await _db;
  }

  Future<void> _ensureTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tod_prompts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        text TEXT NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'medium',
        is_custom INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tod_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        played_at TEXT NOT NULL,
        mode TEXT NOT NULL,
        rounds INTEGER NOT NULL,
        truths INTEGER NOT NULL,
        dares INTEGER NOT NULL,
        skipped INTEGER NOT NULL,
        scores_json TEXT NOT NULL DEFAULT '[]'
      )
    ''');
  }

  Future<void> _seedIfNeeded(Database db) async {
    final count = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM tod_prompts WHERE is_custom = 0',
          ),
        ) ??
        0;
    if (count > 0) return;

    final batch = db.batch();
    for (final row in TodSeed.allPrompts()) {
      batch.insert('tod_prompts', {
        'category': row['category'],
        'type': row['type'],
        'text': row['text'],
        'difficulty': row['difficulty'],
        'is_custom': 0,
        'is_favorite': 0,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<TodPrompt>> listPrompts({
    String? category,
    TodPromptType? type,
    bool favoritesOnly = false,
    bool customOnly = false,
    TodDifficulty? difficulty,
  }) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];

    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }
    if (type != null) {
      where.add('type = ?');
      args.add(type == TodPromptType.dare ? 'dare' : 'truth');
    }
    if (favoritesOnly) {
      where.add('is_favorite = 1');
    }
    if (customOnly) {
      where.add('is_custom = 1');
    }
    if (difficulty != null) {
      where.add('difficulty = ?');
      args.add(difficulty.name);
    }

    final rows = await db.query(
      'tod_prompts',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id ASC',
    );
    return rows.map(TodPrompt.fromMap).toList();
  }

  Future<TodPrompt?> randomPrompt({
    required TodPromptType type,
    required Set<String> categories,
    required Set<int> excludeIds,
    TodDifficulty? difficulty,
    bool allowRepetition = false,
  }) async {
    final db = await _db;
    if (categories.isEmpty) return null;

    final placeholders = List.filled(categories.length, '?').join(',');
    final where = <String>[
      'type = ?',
      'category IN ($placeholders)',
    ];
    final args = <Object?>[
      type == TodPromptType.dare ? 'dare' : 'truth',
      ...categories,
    ];

    if (difficulty != null) {
      where.add('difficulty = ?');
      args.add(difficulty.name);
    }

    if (!allowRepetition && excludeIds.isNotEmpty) {
      final ex = List.filled(excludeIds.length, '?').join(',');
      where.add('id NOT IN ($ex)');
      args.addAll(excludeIds);
    }

    var rows = await db.query(
      'tod_prompts',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'RANDOM()',
      limit: 1,
    );

    // Soft fallback: ignore difficulty, then ignore excludes
    if (rows.isEmpty && difficulty != null) {
      return randomPrompt(
        type: type,
        categories: categories,
        excludeIds: excludeIds,
        allowRepetition: allowRepetition,
      );
    }
    if (rows.isEmpty && excludeIds.isNotEmpty) {
      return randomPrompt(
        type: type,
        categories: categories,
        excludeIds: const {},
        difficulty: difficulty,
        allowRepetition: true,
      );
    }
    if (rows.isEmpty) return null;
    return TodPrompt.fromMap(rows.first);
  }

  Future<int> insertCustom({
    required String category,
    required TodPromptType type,
    required String text,
    TodDifficulty difficulty = TodDifficulty.medium,
  }) async {
    final db = await _db;
    return db.insert('tod_prompts', {
      'category': category,
      'type': type == TodPromptType.dare ? 'dare' : 'truth',
      'text': text.trim(),
      'difficulty': difficulty.name,
      'is_custom': 1,
      'is_favorite': 0,
    });
  }

  Future<void> updatePrompt(TodPrompt prompt) async {
    final db = await _db;
    await db.update(
      'tod_prompts',
      {
        'category': prompt.category,
        'type': prompt.type == TodPromptType.dare ? 'dare' : 'truth',
        'text': prompt.text.trim(),
        'difficulty': prompt.difficulty.name,
        'is_favorite': prompt.isFavorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [prompt.id],
    );
  }

  Future<void> deletePrompt(int id) async {
    final db = await _db;
    await db.delete('tod_prompts', where: 'id = ? AND is_custom = 1', whereArgs: [id]);
  }

  Future<void> setFavorite(int id, bool favorite) async {
    final db = await _db;
    await db.update(
      'tod_prompts',
      {'is_favorite': favorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveHistory({
    required String mode,
    required int rounds,
    required int truths,
    required int dares,
    required int skipped,
    required String scoresJson,
  }) async {
    final db = await _db;
    await db.insert('tod_history', {
      'played_at': DateTime.now().toIso8601String(),
      'mode': mode,
      'rounds': rounds,
      'truths': truths,
      'dares': dares,
      'skipped': skipped,
      'scores_json': scoresJson,
    });
  }

  Future<void> clearHistory() async {
    final db = await _db;
    await db.delete('tod_history');
  }
}
