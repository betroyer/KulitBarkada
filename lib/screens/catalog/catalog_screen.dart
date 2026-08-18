import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

enum CatalogType { food, place, activity }

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.groupId, required this.type});

  final int groupId;
  final CatalogType type;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogConfig {
  const _CatalogConfig({
    required this.title,
    required this.emoji,
    required this.color,
    required this.secondaryLabel,
    required this.costLabel,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.randomTitle,
  });

  final String title;
  final String emoji;
  final Color color;
  final String secondaryLabel;
  final String costLabel;
  final String emptyTitle;
  final String emptySubtitle;
  final String randomTitle;
}

_CatalogConfig _config(CatalogType type) {
  switch (type) {
    case CatalogType.food:
      return const _CatalogConfig(
        title: 'Food',
        emoji: '🍔',
        color: AppColors.food,
        secondaryLabel: 'Category',
        costLabel: 'Estimated price',
        emptyTitle: 'No food options yet',
        emptySubtitle: 'Add burgers, pizza, or whatever the group is craving.',
        randomTitle: "Today's Food Choice",
      );
    case CatalogType.place:
      return const _CatalogConfig(
        title: 'Places',
        emoji: '📍',
        color: AppColors.places,
        secondaryLabel: 'Location',
        costLabel: 'Estimated cost',
        emptyTitle: 'No places yet',
        emptySubtitle: 'Save beaches, malls, cafés, and other destinations.',
        randomTitle: "Today's Place",
      );
    case CatalogType.activity:
      return const _CatalogConfig(
        title: 'Activities',
        emoji: '🎯',
        color: AppColors.activities,
        secondaryLabel: 'Category',
        costLabel: 'Estimated cost',
        emptyTitle: 'No activities yet',
        emptySubtitle: 'Add karaoke, bowling, swimming, or a movie night.',
        randomTitle: "Today's Activity",
      );
  }
}

class _CatalogRow {
  const _CatalogRow({
    required this.id,
    required this.name,
    required this.secondary,
    required this.cost,
    required this.description,
  });

  final int id;
  final String name;
  final String secondary;
  final double cost;
  final String description;
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<_CatalogRow> _items = [];

  _CatalogConfig get cfg => _config(widget.type);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final groupId = widget.groupId;
    late final List<_CatalogRow> rows;
    switch (widget.type) {
      case CatalogType.food:
        rows = (await FoodRepository().list(groupId))
            .map((e) => _CatalogRow(
                  id: e.id!,
                  name: e.name,
                  secondary: e.category,
                  cost: e.estimatedPrice,
                  description: e.description,
                ))
            .toList();
      case CatalogType.place:
        rows = (await PlaceRepository().list(groupId))
            .map((e) => _CatalogRow(
                  id: e.id!,
                  name: e.name,
                  secondary: e.location,
                  cost: e.estimatedCost,
                  description: e.description,
                ))
            .toList();
      case CatalogType.activity:
        rows = (await ActivityRepository().list(groupId))
            .map((e) => _CatalogRow(
                  id: e.id!,
                  name: e.name,
                  secondary: e.category,
                  cost: e.estimatedCost,
                  description: e.description,
                ))
            .toList();
    }
    if (!mounted) return;
    setState(() => _items = rows);
  }

  Future<void> _openForm({_CatalogRow? item}) async {
    final saved = await pushPage<bool>(
      context,
      _CatalogFormScreen(groupId: widget.groupId, type: widget.type, item: item),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(_CatalogRow item) async {
    final ok = await confirmAction(context, title: 'Remove ${item.name}?', message: 'This cannot be undone.');
    if (!ok) return;
    switch (widget.type) {
      case CatalogType.food:
        await FoodRepository().delete(item.id);
      case CatalogType.place:
        await PlaceRepository().delete(item.id);
      case CatalogType.activity:
        await ActivityRepository().delete(item.id);
    }
    _reload();
  }

  Future<void> _random() async {
    if (_items.isEmpty) {
      showSnack(context, 'Add at least one option first.', error: true);
      return;
    }
    final pick = _items[Random().nextInt(_items.length)];
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎲 ${cfg.randomTitle}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cfg.emoji, style: const TextStyle(fontSize: 42)),
            const SizedBox(height: 8),
            Text(pick.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            if (pick.secondary.isNotEmpty)
              Text(pick.secondary, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${cfg.emoji} ${cfg.title}'),
        actions: [
          IconButton(
            tooltip: 'Random pick',
            onPressed: _random,
            icon: const Icon(Icons.casino_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text('Add ${cfg.title.toLowerCase()}'),
      ),
      body: _items.isEmpty
          ? EmptyState(emoji: cfg.emoji, title: cfg.emptyTitle, subtitle: cfg.emptySubtitle)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _items[index];
                return SectionCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                      [
                        if (item.secondary.isNotEmpty) item.secondary,
                        formatPeso(item.cost),
                        if (item.description.isNotEmpty) item.description,
                      ].join('\n'),
                    ),
                    isThreeLine: item.description.isNotEmpty,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _openForm(item: item);
                        if (value == 'delete') _delete(item);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _CatalogFormScreen extends StatefulWidget {
  const _CatalogFormScreen({
    required this.groupId,
    required this.type,
    this.item,
  });

  final int groupId;
  final CatalogType type;
  final _CatalogRow? item;

  @override
  State<_CatalogFormScreen> createState() => _CatalogFormScreenState();
}

class _CatalogFormScreenState extends State<_CatalogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _secondary;
  late final TextEditingController _cost;
  late final TextEditingController _description;

  _CatalogConfig get cfg => _config(widget.type);

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
    _secondary = TextEditingController(text: widget.item?.secondary ?? '');
    _cost = TextEditingController(
      text: widget.item == null || widget.item!.cost == 0 ? '' : widget.item!.cost.toStringAsFixed(0),
    );
    _description = TextEditingController(text: widget.item?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _secondary.dispose();
    _cost.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _name.text.trim();
    final secondary = _secondary.text.trim();
    final cost = parseAmount(_cost.text);
    final description = _description.text.trim();

    switch (widget.type) {
      case CatalogType.food:
        final item = FoodItem(
          id: widget.item?.id,
          groupId: widget.groupId,
          name: name,
          category: secondary,
          estimatedPrice: cost,
          description: description,
        );
        widget.item == null ? await FoodRepository().insert(item) : await FoodRepository().update(item);
      case CatalogType.place:
        final item = PlaceItem(
          id: widget.item?.id,
          groupId: widget.groupId,
          name: name,
          location: secondary,
          estimatedCost: cost,
          description: description,
        );
        widget.item == null ? await PlaceRepository().insert(item) : await PlaceRepository().update(item);
      case CatalogType.activity:
        final item = ActivityItem(
          id: widget.item?.id,
          groupId: widget.groupId,
          name: name,
          category: secondary,
          estimatedCost: cost,
          description: description,
        );
        widget.item == null ? await ActivityRepository().insert(item) : await ActivityRepository().update(item);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item == null ? 'Add ${cfg.title}' : 'Edit ${cfg.title}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: '${cfg.title} name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _secondary,
                  decoration: InputDecoration(labelText: cfg.secondaryLabel),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _cost,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: cfg.costLabel, prefixText: '₱ '),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
