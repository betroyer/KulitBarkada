import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';
import 'models.dart';

class AuthRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<AppUser?> findByUsername(String username) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [username.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> findById(int id) async {
    final db = await _db;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<int> insert(AppUser user) async {
    final db = await _db;
    return db.insert('users', user.toMap()..remove('id'));
  }

  Future<void> update(AppUser user) async {
    final db = await _db;
    await db.update('users', user.toMap()..remove('id'), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<bool> usernameTaken(String username, {int? exceptId}) async {
    final existing = await findByUsername(username);
    if (existing == null) return false;
    return existing.id != exceptId;
  }
}

class GroupRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<OutingGroup>> listForUser(int userId) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT g.*,
        (SELECT COUNT(*) FROM members m WHERE m.group_id = g.id) AS member_count,
        (SELECT COALESCE(SUM(amount), 0) FROM expenses e WHERE e.group_id = g.id) AS total_expenses
      FROM groups g
      WHERE g.user_id = ?
      ORDER BY g.date DESC, g.id DESC
    ''', [userId]);
    return rows.map(OutingGroup.fromMap).toList();
  }

  Future<OutingGroup?> getById(int id) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT g.*,
        (SELECT COUNT(*) FROM members m WHERE m.group_id = g.id) AS member_count,
        (SELECT COALESCE(SUM(amount), 0) FROM expenses e WHERE e.group_id = g.id) AS total_expenses
      FROM groups g
      WHERE g.id = ?
    ''', [id]);
    if (rows.isEmpty) return null;
    return OutingGroup.fromMap(rows.first);
  }

  Future<int> insert(OutingGroup group) async {
    final db = await _db;
    return db.insert('groups', group.toMap()..remove('id'));
  }

  Future<void> update(OutingGroup group) async {
    final db = await _db;
    await db.update('groups', group.toMap()..remove('id'), where: 'id = ?', whereArgs: [group.id]);
  }

  Future<void> saveDecisions(
    int groupId, {
    String? food,
    String? place,
    String? activity,
  }) async {
    final db = await _db;
    await db.update(
      'groups',
      {
        'decided_food': ?food,
        'decided_place': ?place,
        'decided_activity': ?activity,
      },
      where: 'id = ?',
      whereArgs: [groupId],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'expense_participants',
        where: 'expense_id IN (SELECT id FROM expenses WHERE group_id = ?)',
        whereArgs: [id],
      );
      await txn.delete('expenses', where: 'group_id = ?', whereArgs: [id]);
      await txn.delete('expense_splits', where: 'group_id = ?', whereArgs: [id]);
      await txn.delete('foods', where: 'group_id = ?', whereArgs: [id]);
      await txn.delete('places', where: 'group_id = ?', whereArgs: [id]);
      await txn.delete('activities', where: 'group_id = ?', whereArgs: [id]);
      await txn.delete('group_plans', where: 'group_id = ?', whereArgs: [id]);
      await txn.delete('members', where: 'group_id = ?', whereArgs: [id]);
      await txn.delete('groups', where: 'id = ?', whereArgs: [id]);
    });
  }
}

class MemberRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<GroupMember>> list(int groupId) async {
    final db = await _db;
    final rows = await db.query(
      'members',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: "CASE WHEN role = 'Organizer' THEN 0 ELSE 1 END, name COLLATE NOCASE",
    );
    return rows.map(GroupMember.fromMap).toList();
  }

  Future<int> insert(GroupMember member) async {
    final db = await _db;
    return db.insert('members', member.toMap()..remove('id'));
  }

  Future<void> update(GroupMember member) async {
    final db = await _db;
    await db.update('members', member.toMap()..remove('id'), where: 'id = ?', whereArgs: [member.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('expense_participants', where: 'member_id = ?', whereArgs: [id]);
    await db.delete('expense_splits', where: 'member_id = ?', whereArgs: [id]);
    await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }
}

class FoodRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<FoodItem>> list(int groupId) async {
    final db = await _db;
    final rows = await db.query('foods', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'name COLLATE NOCASE');
    return rows.map(FoodItem.fromMap).toList();
  }

  Future<int> insert(FoodItem item) async {
    final db = await _db;
    return db.insert('foods', item.toMap()..remove('id'));
  }

  Future<void> update(FoodItem item) async {
    final db = await _db;
    await db.update('foods', item.toMap()..remove('id'), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }
}

class PlaceRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<PlaceItem>> list(int groupId) async {
    final db = await _db;
    final rows = await db.query('places', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'name COLLATE NOCASE');
    return rows.map(PlaceItem.fromMap).toList();
  }

  Future<int> insert(PlaceItem item) async {
    final db = await _db;
    return db.insert('places', item.toMap()..remove('id'));
  }

  Future<void> update(PlaceItem item) async {
    final db = await _db;
    await db.update('places', item.toMap()..remove('id'), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('places', where: 'id = ?', whereArgs: [id]);
  }
}

class ActivityRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<ActivityItem>> list(int groupId) async {
    final db = await _db;
    final rows = await db.query('activities', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'name COLLATE NOCASE');
    return rows.map(ActivityItem.fromMap).toList();
  }

  Future<int> insert(ActivityItem item) async {
    final db = await _db;
    return db.insert('activities', item.toMap()..remove('id'));
  }

  Future<void> update(ActivityItem item) async {
    final db = await _db;
    await db.update('activities', item.toMap()..remove('id'), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }
}

class ExpenseRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<ExpenseItem>> list(int groupId) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT e.*, m.name AS paid_by_name
      FROM expenses e
      LEFT JOIN members m ON m.id = e.paid_by_member_id
      WHERE e.group_id = ?
      ORDER BY e.date DESC, e.id DESC
    ''', [groupId]);

    final expenses = <ExpenseItem>[];
    for (final row in rows) {
      final expense = ExpenseItem.fromMap(row);
      final parts = await db.rawQuery('''
        SELECT ep.member_id, m.name
        FROM expense_participants ep
        JOIN members m ON m.id = ep.member_id
        WHERE ep.expense_id = ?
        ORDER BY m.name COLLATE NOCASE
      ''', [expense.id]);
      expenses.add(ExpenseItem(
        id: expense.id,
        groupId: expense.groupId,
        name: expense.name,
        amount: expense.amount,
        paidByMemberId: expense.paidByMemberId,
        date: expense.date,
        paidByName: expense.paidByName,
        participantIds: parts.map((p) => p['member_id'] as int).toList(),
        participantNames: parts.map((p) => p['name'] as String).toList(),
      ));
    }
    return expenses;
  }

  Future<double> totalForGroup(int groupId) async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses WHERE group_id = ?',
      [groupId],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<int> insert(ExpenseItem expense) async {
    final db = await _db;
    late int id;
    await db.transaction((txn) async {
      id = await txn.insert('expenses', expense.toMap()..remove('id'));
      for (final memberId in expense.participantIds) {
        await txn.insert('expense_participants', {
          'expense_id': id,
          'member_id': memberId,
        });
      }
    });
    return id;
  }

  Future<void> update(ExpenseItem expense) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update('expenses', expense.toMap()..remove('id'), where: 'id = ?', whereArgs: [expense.id]);
      await txn.delete('expense_participants', where: 'expense_id = ?', whereArgs: [expense.id]);
      for (final memberId in expense.participantIds) {
        await txn.insert('expense_participants', {
          'expense_id': expense.id,
          'member_id': memberId,
        });
      }
    });
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('expense_participants', where: 'expense_id = ?', whereArgs: [id]);
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ExpenseSplit>> listSplits(int groupId) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT s.*, m.name AS member_name
      FROM expense_splits s
      JOIN members m ON m.id = s.member_id
      WHERE s.group_id = ?
      ORDER BY m.name COLLATE NOCASE
    ''', [groupId]);
    return rows.map(ExpenseSplit.fromMap).toList();
  }

  Future<void> saveSplits(int groupId, List<ExpenseSplit> splits) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('expense_splits', where: 'group_id = ?', whereArgs: [groupId]);
      for (final split in splits) {
        await txn.insert('expense_splits', split.toMap()..remove('id'));
      }
    });
  }

  Future<Map<int, double>> amountsPaidByMember(int groupId) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT paid_by_member_id, COALESCE(SUM(amount), 0) AS total
      FROM expenses
      WHERE group_id = ?
      GROUP BY paid_by_member_id
    ''', [groupId]);
    return {
      for (final row in rows) row['paid_by_member_id'] as int: (row['total'] as num).toDouble(),
    };
  }
}

class PlanRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<GroupPlan>> list(int groupId) async {
    final db = await _db;
    final rows = await db.query('group_plans', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'id DESC');
    return rows.map(GroupPlan.fromMap).toList();
  }

  Future<GroupPlan?> latest(int groupId) async {
    final plans = await list(groupId);
    return plans.isEmpty ? null : plans.first;
  }

  Future<int> insert(GroupPlan plan) async {
    final db = await _db;
    return db.insert('group_plans', plan.toMap()..remove('id'));
  }

  Future<void> update(GroupPlan plan) async {
    final db = await _db;
    await db.update('group_plans', plan.toMap()..remove('id'), where: 'id = ?', whereArgs: [plan.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('group_plans', where: 'id = ?', whereArgs: [id]);
  }
}

List<double> equalAmounts(double total, int count) {
  if (count <= 0) return const [];
  final base = ((total / count) * 100).floor() / 100;
  final amounts = List<double>.filled(count, base);
  final assigned = double.parse((base * (count - 1)).toStringAsFixed(2));
  amounts[count - 1] = double.parse((total - assigned).toStringAsFixed(2));
  return amounts;
}

List<Settlement> buildSettlements({
  required List<GroupMember> members,
  required Map<int, double> paidByMember,
  required Map<int, double> shareByMember,
}) {
  final nets = <({String name, double net})>[];
  for (final member in members) {
    final id = member.id;
    if (id == null) continue;
    final paid = paidByMember[id] ?? 0;
    final share = shareByMember[id] ?? 0;
    nets.add((name: member.name, net: double.parse((paid - share).toStringAsFixed(2))));
  }

  final creditors = nets.where((n) => n.net > 0.009).toList()
    ..sort((a, b) => b.net.compareTo(a.net));
  final debtors = nets.where((n) => n.net < -0.009).toList()
    ..sort((a, b) => a.net.compareTo(b.net));

  final result = <Settlement>[];
  var i = 0;
  var j = 0;
  var credit = creditors.isEmpty ? 0.0 : creditors[0].net;
  var debt = debtors.isEmpty ? 0.0 : -debtors[0].net;

  while (i < creditors.length && j < debtors.length) {
    final amount = credit < debt ? credit : debt;
    result.add(Settlement(
      fromName: debtors[j].name,
      toName: creditors[i].name,
      amount: double.parse(amount.toStringAsFixed(2)),
    ));
    credit -= amount;
    debt -= amount;
    if (credit <= 0.009) {
      i++;
      credit = i < creditors.length ? creditors[i].net : 0;
    }
    if (debt <= 0.009) {
      j++;
      debt = j < debtors.length ? -debtors[j].net : 0;
    }
  }
  return result;
}
