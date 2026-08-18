class AppUser {
  const AppUser({
    this.id,
    required this.fullName,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  final int? id;
  final String fullName;
  final String username;
  final String passwordHash;
  final String salt;
  final String createdAt;

  AppUser copyWith({
    int? id,
    String? fullName,
    String? username,
    String? passwordHash,
    String? salt,
    String? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'full_name': fullName,
        'username': username,
        'password_hash': passwordHash,
        'salt': salt,
        'created_at': createdAt,
      };

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
        id: map['id'] as int?,
        fullName: map['full_name'] as String,
        username: map['username'] as String,
        passwordHash: map['password_hash'] as String,
        salt: map['salt'] as String,
        createdAt: map['created_at'] as String,
      );
}

class OutingGroup {
  const OutingGroup({
    this.id,
    required this.userId,
    required this.name,
    required this.date,
    this.description = '',
    this.budget = 0,
    this.decidedFood,
    this.decidedPlace,
    this.decidedActivity,
    this.memberCount = 0,
    this.totalExpenses = 0,
  });

  final int? id;
  final int userId;
  final String name;
  final String date;
  final String description;
  final double budget;
  final String? decidedFood;
  final String? decidedPlace;
  final String? decidedActivity;
  final int memberCount;
  final double totalExpenses;

  double get remaining => budget - totalExpenses;

  OutingGroup copyWith({
    int? id,
    int? userId,
    String? name,
    String? date,
    String? description,
    double? budget,
    String? decidedFood,
    String? decidedPlace,
    String? decidedActivity,
    int? memberCount,
    double? totalExpenses,
  }) {
    return OutingGroup(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      date: date ?? this.date,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      decidedFood: decidedFood ?? this.decidedFood,
      decidedPlace: decidedPlace ?? this.decidedPlace,
      decidedActivity: decidedActivity ?? this.decidedActivity,
      memberCount: memberCount ?? this.memberCount,
      totalExpenses: totalExpenses ?? this.totalExpenses,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'date': date,
        'description': description,
        'budget': budget,
        'decided_food': decidedFood,
        'decided_place': decidedPlace,
        'decided_activity': decidedActivity,
      };

  factory OutingGroup.fromMap(Map<String, Object?> map) => OutingGroup(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        name: map['name'] as String,
        date: map['date'] as String,
        description: (map['description'] as String?) ?? '',
        budget: (map['budget'] as num?)?.toDouble() ?? 0,
        decidedFood: map['decided_food'] as String?,
        decidedPlace: map['decided_place'] as String?,
        decidedActivity: map['decided_activity'] as String?,
        memberCount: (map['member_count'] as num?)?.toInt() ?? 0,
        totalExpenses: (map['total_expenses'] as num?)?.toDouble() ?? 0,
      );
}

class GroupMember {
  const GroupMember({
    this.id,
    required this.groupId,
    required this.name,
    this.contact = '',
    this.role = 'Member',
  });

  final int? id;
  final int groupId;
  final String name;
  final String contact;
  final String role;

  Map<String, Object?> toMap() => {
        'id': id,
        'group_id': groupId,
        'name': name,
        'contact': contact,
        'role': role,
      };

  factory GroupMember.fromMap(Map<String, Object?> map) => GroupMember(
        id: map['id'] as int?,
        groupId: map['group_id'] as int,
        name: map['name'] as String,
        contact: (map['contact'] as String?) ?? '',
        role: (map['role'] as String?) ?? 'Member',
      );
}

class FoodItem {
  const FoodItem({
    this.id,
    required this.groupId,
    required this.name,
    this.category = '',
    this.estimatedPrice = 0,
    this.description = '',
  });

  final int? id;
  final int groupId;
  final String name;
  final String category;
  final double estimatedPrice;
  final String description;

  Map<String, Object?> toMap() => {
        'id': id,
        'group_id': groupId,
        'name': name,
        'category': category,
        'estimated_price': estimatedPrice,
        'description': description,
      };

  factory FoodItem.fromMap(Map<String, Object?> map) => FoodItem(
        id: map['id'] as int?,
        groupId: map['group_id'] as int,
        name: map['name'] as String,
        category: (map['category'] as String?) ?? '',
        estimatedPrice: (map['estimated_price'] as num?)?.toDouble() ?? 0,
        description: (map['description'] as String?) ?? '',
      );
}

class PlaceItem {
  const PlaceItem({
    this.id,
    required this.groupId,
    required this.name,
    this.location = '',
    this.estimatedCost = 0,
    this.description = '',
  });

  final int? id;
  final int groupId;
  final String name;
  final String location;
  final double estimatedCost;
  final String description;

  Map<String, Object?> toMap() => {
        'id': id,
        'group_id': groupId,
        'name': name,
        'location': location,
        'estimated_cost': estimatedCost,
        'description': description,
      };

  factory PlaceItem.fromMap(Map<String, Object?> map) => PlaceItem(
        id: map['id'] as int?,
        groupId: map['group_id'] as int,
        name: map['name'] as String,
        location: (map['location'] as String?) ?? '',
        estimatedCost: (map['estimated_cost'] as num?)?.toDouble() ?? 0,
        description: (map['description'] as String?) ?? '',
      );
}

class ActivityItem {
  const ActivityItem({
    this.id,
    required this.groupId,
    required this.name,
    this.category = '',
    this.estimatedCost = 0,
    this.description = '',
  });

  final int? id;
  final int groupId;
  final String name;
  final String category;
  final double estimatedCost;
  final String description;

  Map<String, Object?> toMap() => {
        'id': id,
        'group_id': groupId,
        'name': name,
        'category': category,
        'estimated_cost': estimatedCost,
        'description': description,
      };

  factory ActivityItem.fromMap(Map<String, Object?> map) => ActivityItem(
        id: map['id'] as int?,
        groupId: map['group_id'] as int,
        name: map['name'] as String,
        category: (map['category'] as String?) ?? '',
        estimatedCost: (map['estimated_cost'] as num?)?.toDouble() ?? 0,
        description: (map['description'] as String?) ?? '',
      );
}

class ExpenseItem {
  const ExpenseItem({
    this.id,
    required this.groupId,
    required this.name,
    required this.amount,
    required this.paidByMemberId,
    required this.date,
    this.paidByName = '',
    this.participantIds = const [],
    this.participantNames = const [],
  });

  final int? id;
  final int groupId;
  final String name;
  final double amount;
  final int paidByMemberId;
  final String date;
  final String paidByName;
  final List<int> participantIds;
  final List<String> participantNames;

  Map<String, Object?> toMap() => {
        'id': id,
        'group_id': groupId,
        'name': name,
        'amount': amount,
        'paid_by_member_id': paidByMemberId,
        'date': date,
      };

  factory ExpenseItem.fromMap(Map<String, Object?> map) => ExpenseItem(
        id: map['id'] as int?,
        groupId: map['group_id'] as int,
        name: map['name'] as String,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        paidByMemberId: map['paid_by_member_id'] as int,
        date: map['date'] as String,
        paidByName: (map['paid_by_name'] as String?) ?? '',
      );
}

class ExpenseSplit {
  const ExpenseSplit({
    this.id,
    required this.groupId,
    required this.memberId,
    required this.splitType,
    required this.amount,
    this.percentage,
    this.memberName = '',
  });

  final int? id;
  final int groupId;
  final int memberId;
  final String splitType;
  final double amount;
  final double? percentage;
  final String memberName;

  Map<String, Object?> toMap() => {
        'id': id,
        'group_id': groupId,
        'member_id': memberId,
        'split_type': splitType,
        'amount': amount,
        'percentage': percentage,
      };

  factory ExpenseSplit.fromMap(Map<String, Object?> map) => ExpenseSplit(
        id: map['id'] as int?,
        groupId: map['group_id'] as int,
        memberId: map['member_id'] as int,
        splitType: map['split_type'] as String,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        percentage: (map['percentage'] as num?)?.toDouble(),
        memberName: (map['member_name'] as String?) ?? '',
      );
}

class GroupPlan {
  const GroupPlan({
    this.id,
    required this.groupId,
    required this.title,
    required this.date,
    this.placeName = '',
    this.foodName = '',
    this.activityName = '',
    this.memberCount = 0,
    this.budget = 0,
    this.estimatedExpenses = 0,
    this.notes = '',
  });

  final int? id;
  final int groupId;
  final String title;
  final String date;
  final String placeName;
  final String foodName;
  final String activityName;
  final int memberCount;
  final double budget;
  final double estimatedExpenses;
  final String notes;

  double get perPerson =>
      memberCount == 0 ? 0 : estimatedExpenses / memberCount;

  Map<String, Object?> toMap() => {
        'id': id,
        'group_id': groupId,
        'title': title,
        'date': date,
        'place_name': placeName,
        'food_name': foodName,
        'activity_name': activityName,
        'member_count': memberCount,
        'budget': budget,
        'estimated_expenses': estimatedExpenses,
        'notes': notes,
      };

  factory GroupPlan.fromMap(Map<String, Object?> map) => GroupPlan(
        id: map['id'] as int?,
        groupId: map['group_id'] as int,
        title: map['title'] as String,
        date: map['date'] as String,
        placeName: (map['place_name'] as String?) ?? '',
        foodName: (map['food_name'] as String?) ?? '',
        activityName: (map['activity_name'] as String?) ?? '',
        memberCount: (map['member_count'] as num?)?.toInt() ?? 0,
        budget: (map['budget'] as num?)?.toDouble() ?? 0,
        estimatedExpenses: (map['estimated_expenses'] as num?)?.toDouble() ?? 0,
        notes: (map['notes'] as String?) ?? '',
      );
}

class Settlement {
  const Settlement({
    required this.fromName,
    required this.toName,
    required this.amount,
  });

  final String fromName;
  final String toName;
  final double amount;
}
