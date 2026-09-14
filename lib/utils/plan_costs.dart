import '../data/models.dart';
import '../data/repositories.dart';

class PlanCostBreakdown {
  const PlanCostBreakdown({
    required this.food,
    required this.place,
    required this.activity,
  });

  final double food;
  final double place;
  final double activity;

  double get total => food + place + activity;
}

Future<PlanCostBreakdown> loadPlanCosts(int groupId, OutingGroup? group) async {
  final foods = await FoodRepository().list(groupId);
  final places = await PlaceRepository().list(groupId);
  final activities = await ActivityRepository().list(groupId);
  final plan = await PlanRepository().latest(groupId);

  final foodName = plan?.foodName.isNotEmpty == true ? plan!.foodName : group?.decidedFood;
  final placeName = plan?.placeName.isNotEmpty == true ? plan!.placeName : group?.decidedPlace;
  final activityName = plan?.activityName.isNotEmpty == true ? plan!.activityName : group?.decidedActivity;

  double food = 0;
  double place = 0;
  double activity = 0;

  if (foodName != null && foodName.isNotEmpty) {
    food = foods.where((f) => f.name == foodName).firstOrNull?.estimatedPrice ?? 0;
  }
  if (placeName != null && placeName.isNotEmpty) {
    place = places.where((p) => p.name == placeName).firstOrNull?.estimatedCost ?? 0;
  }
  if (activityName != null && activityName.isNotEmpty) {
    activity = activities.where((a) => a.name == activityName).firstOrNull?.estimatedCost ?? 0;
  }

  if (plan != null && plan.estimatedExpenses > 0 && food + place + activity == 0) {
    final third = plan.estimatedExpenses / 3;
    food = third;
    place = third;
    activity = plan.estimatedExpenses - (third * 2);
  }

  return PlanCostBreakdown(food: food, place: place, activity: activity);
}
