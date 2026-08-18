import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../plan/plan_screen.dart';

class DecideScreen extends StatefulWidget {
  const DecideScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<DecideScreen> createState() => _DecideScreenState();
}

class _DecideScreenState extends State<DecideScreen> {
  OutingGroup? _group;
  List<FoodItem> _foods = [];
  List<PlaceItem> _places = [];
  List<ActivityItem> _activities = [];
  bool _pickFood = true;
  bool _pickPlace = true;
  bool _pickActivity = true;
  bool _rolling = false;
  String? _food;
  String? _place;
  String? _activity;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final groupId = widget.groupId;
    final group = await GroupRepository().getById(groupId);
    final foods = await FoodRepository().list(groupId);
    final places = await PlaceRepository().list(groupId);
    final activities = await ActivityRepository().list(groupId);
    if (!mounted) return;
    setState(() {
      _group = group;
      _foods = foods;
      _places = places;
      _activities = activities;
      _food = group?.decidedFood;
      _place = group?.decidedPlace;
      _activity = group?.decidedActivity;
    });
  }

  Future<void> _decide() async {
    if (!_pickFood && !_pickPlace && !_pickActivity) {
      showSnack(context, 'Select at least one category.', error: true);
      return;
    }
    if (_pickFood && _foods.isEmpty) {
      showSnack(context, 'Add food options first.', error: true);
      return;
    }
    if (_pickPlace && _places.isEmpty) {
      showSnack(context, 'Add places first.', error: true);
      return;
    }
    if (_pickActivity && _activities.isEmpty) {
      showSnack(context, 'Add activities first.', error: true);
      return;
    }

    setState(() => _rolling = true);
    final random = Random();
    var ticks = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      ticks++;
      setState(() {
        if (_pickFood) _food = _foods[random.nextInt(_foods.length)].name;
        if (_pickPlace) _place = _places[random.nextInt(_places.length)].name;
        if (_pickActivity) _activity = _activities[random.nextInt(_activities.length)].name;
      });
      if (ticks >= 14) {
        timer.cancel();
        final food = _pickFood ? _foods[random.nextInt(_foods.length)].name : _food;
        final place = _pickPlace ? _places[random.nextInt(_places.length)].name : _place;
        final activity = _pickActivity ? _activities[random.nextInt(_activities.length)].name : _activity;
        GroupRepository().saveDecisions(
          widget.groupId,
          food: _pickFood ? food : null,
          place: _pickPlace ? place : null,
          activity: _pickActivity ? activity : null,
        );
        setState(() {
          _food = food;
          _place = place;
          _activity = activity;
          _rolling = false;
        });
      }
    });
  }

  Future<void> _savePlan() async {
    final group = _group;
    if (group == null) return;
    final foodCost = _foods.where((f) => f.name == _food).firstOrNull?.estimatedPrice ?? 0;
    final placeCost = _places.where((p) => p.name == _place).firstOrNull?.estimatedCost ?? 0;
    final activityCost = _activities.where((a) => a.name == _activity).firstOrNull?.estimatedCost ?? 0;
    final plan = GroupPlan(
      groupId: widget.groupId,
      title: group.name,
      date: group.date,
      placeName: _place ?? '',
      foodName: _food ?? '',
      activityName: _activity ?? '',
      memberCount: group.memberCount,
      budget: group.budget,
      estimatedExpenses: foodCost + placeCost + activityCost,
    );
    await PlanRepository().insert(plan);
    if (!mounted) return;
    showSnack(context, 'Saved as a final plan.');
    await pushPage(context, PlanScreen(groupId: widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decide for Us')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('What should we decide?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _pickFood,
            onChanged: (v) => setState(() => _pickFood = v ?? true),
            title: Text('🍔 Food (${_foods.length})'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: AppColors.surface,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _pickPlace,
            onChanged: (v) => setState(() => _pickPlace = v ?? true),
            title: Text('📍 Place (${_places.length})'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: AppColors.surface,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _pickActivity,
            onChanged: (v) => setState(() => _pickActivity = v ?? true),
            title: Text('🎯 Activity (${_activities.length})'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: AppColors.surface,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _rolling ? null : _decide,
            child: Text(_rolling ? 'Deciding...' : '🎲 DECIDE FOR US'),
          ),
          const SizedBox(height: 24),
          SectionCard(
            child: Column(
              children: [
                const Text('🎉 GROUP DECISION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                _result('🍔 Food', _food),
                _result('📍 Place', _place),
                _result('🎯 Activity', _activity),
              ],
            ),
          ),
          if (_food != null || _place != null || _activity != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _savePlan,
              child: const Text('Save as Final Plan'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _result(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: Text(
              value == null || value.isEmpty ? '—' : value,
              key: ValueKey('$label-$value'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
