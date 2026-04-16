// ============================================================
// screens/taker/food_list_screen.dart
// Widgets: Scaffold, AppBar, TextField, SingleChildScrollView,
//          Wrap, FilterChip, ListView, FoodCard, RefreshIndicator,
//          CircularProgressIndicator, SizedBox, Column, Row
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/food_item_model.dart';
import '../../services/api_service.dart';
import '../../widgets/food_card.dart';
import '../../widgets/loading_shimmer.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  // TextEditingController – search box
  final _searchCtrl = TextEditingController();

  List<FoodItemModel> _all    = [];
  List<FoodItemModel> _filtered = [];
  bool _loading  = true;
  String? _selectedCategory;

  static const List<String> _categories = ['All', 'meals', 'produce', 'bakery', 'dairy', 'other'];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final items = await ApiService.instance.getFoodItems(token: token, status: 'available');
      if (mounted) setState(() { _all = items; _filtered = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _all.where((item) {
        final matchesSearch = item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.giverName.toLowerCase().contains(query);
        final matchesCat = _selectedCategory == null || _selectedCategory == 'All' || item.category == _selectedCategory;
        return matchesSearch && matchesCat;
      }).toList();
    });
  }

  void _onCategoryTap(String cat) {
    setState(() => _selectedCategory = cat == 'All' ? null : cat);
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold – page wrapper
    return Scaffold(
      // AppBar – page title
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.takerDashboard)),
        title: const Text('Browse Food'),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),

      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────
          Container(
            color: AppTheme.background,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              // TextField – search input with white background
              decoration: InputDecoration(
                hintText: 'Search food, giver name…',
                hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _searchCtrl.clear(); _applyFilter(); })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),

          // ── Category filter chips ──────────────────────
          Container(
            height: 52,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            // SingleChildScrollView – horizontal scrollable chips
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = (cat == 'All' && _selectedCategory == null) || cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    // FilterChip – toggleable category filter
                    child: FilterChip(
                      label: Text(cat == 'All' ? '🍽 All' : '${FoodItemModel.categoryIcons[cat]} ${cat[0].toUpperCase()}${cat.substring(1)}',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                      selected: isSelected,
                      selectedColor: Colors.grey.shade200,
                      checkmarkColor: AppTheme.primary,
                      side: BorderSide(color: isSelected ? AppTheme.primary : Colors.grey.shade300),
                      onSelected: (_) => _onCategoryTap(cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Divider(height: 1),

          // ── Results count ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text('${_filtered.length} item${_filtered.length == 1 ? '' : 's'} found',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              ],
            ),
          ),

          // ── Food list ──────────────────────────────────
          Expanded(
            child: _loading
                ? const LoadingShimmer()
                : _filtered.isEmpty
                    ? const Center(child: Text('No food available\nin this category 😔', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppTheme.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppTheme.takerPrimary,
                        // ListView – scrollable food cards
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => FoodCard(
                            item: _filtered[i],
                            onTap: () => context.go('${AppRoutes.foodDetail}?id=${_filtered[i].id}'),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
