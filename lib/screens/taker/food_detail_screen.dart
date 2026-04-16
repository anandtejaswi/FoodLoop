// ============================================================
// screens/taker/food_detail_screen.dart
// Widgets: Scaffold, SliverAppBar, SliverList, CustomScrollView,
//          Container, Column, Row, Text, Chip, ElevatedButton,
//          CircleAvatar, Icon, Divider, SizedBox, Card
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/food_item_model.dart';
import '../../services/api_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;
  const FoodDetailScreen({super.key, required this.foodId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  FoodItemModel? _item;
  bool _loading    = true;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final item  = await ApiService.instance.getFoodItem(widget.foodId, token: token);
      if (mounted) setState(() { _item = item; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestFood() async {
    if (_item == null) return;
    setState(() => _requesting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      await ApiService.instance.createRequest(_item!.id, token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent! 🎉 The giver will respond shortly.'), backgroundColor: Colors.green),
      );
      // Wait a moment for snackbar to be visible, then navigate
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      context.go(AppRoutes.takerRequests);
    } catch (e) {
      setState(() => _requesting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppTheme.error),
      );
    }
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.takerPrimary),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary)),
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ],
        )),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.takerPrimary)));
    }
    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Food Detail')),
        body: const Center(child: Text('Food item not found', style: TextStyle(fontFamily: 'Poppins'))),
      );
    }

    final item = _item!;

    // CustomScrollView – SliverAppBar with photo hero + body content
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar – collapsible hero image header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => context.go(AppRoutes.foodList),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white), onPressed: () {}),
            ],
            // FlexibleSpaceBar – handles the parallax image
            flexibleSpace: FlexibleSpaceBar(
              background: ApiService.resolvePhotoUrl(item.photoUrl) != null
                  ? Image.network(ApiService.resolvePhotoUrl(item.photoUrl)!, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                      ),
                      child: Center(child: Text(item.categoryIcon, style: const TextStyle(fontSize: 80))),
                    ),
            ),
          ),

          // SliverList – scrollable content body
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title + expiry chip ──────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                        const SizedBox(width: 10),
                        Chip(
                          label: Text(item.timeRemaining, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: item.isExpired ? AppTheme.error : AppTheme.textSecondary)),
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: item.isExpired ? AppTheme.error : Colors.grey.shade300),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── Category + quantity chips ────────────
                    Wrap(
                      spacing: 8,
                      children: [
                        _tagChip('${item.categoryIcon} ${item.category}'),
                        _tagChip('${item.quantity} ${item.quantityUnit}'),
                      ],
                    ),

                    const Divider(height: 28),

                    // ── Giver info card ──────────────────────
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: item.giverAvatar != null ? NetworkImage(item.giverAvatar!) : null,
                              child: item.giverAvatar == null ? const Icon(Icons.person, color: AppTheme.textSecondary) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Posted by', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary)),
                                  Text(item.giverName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Description ──────────────────────────
                    const Text('Description', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(item.description.isEmpty ? 'No description provided.' : item.description,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),

                    const Divider(height: 28),

                    // ── Details list ─────────────────────────
                    _infoRow(Icons.place_outlined,     'Pickup Location', item.address),
                    _infoRow(Icons.access_time_rounded,'Available Until',  item.timeRemaining),
                    _infoRow(Icons.category_outlined,  'Category',         item.category),
                    _infoRow(Icons.people_outline,     'Serves',           '${item.quantity} ${item.quantityUnit}'),

                    const SizedBox(height: 28),

                    // ── Request button ───────────────────────
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton.icon(
                        onPressed: (item.isExpired || item.status != 'available' || _requesting) ? null : _requestFood,
                        icon: _requesting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.shopping_bag_outlined),
                        label: Text(
                          item.isExpired ? 'Expired' : item.status != 'available' ? 'Already Claimed' : _requesting ? 'Requesting…' : 'Request This Food',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300)),
    child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
  );
}
