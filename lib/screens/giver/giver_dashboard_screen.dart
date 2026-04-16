// ============================================================
// screens/giver/giver_dashboard_screen.dart
// Widgets: Scaffold, AppBar, SingleChildScrollView, Column,
//          Container, Row, Text, SizedBox, Card, GridView,
//          ElevatedButton, CircularProgressIndicator,
//          RefreshIndicator, ListView, Chip, Icon
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/food_item_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/food_card.dart';
import '../../widgets/food_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/reviews_bottom_sheet.dart';

class GiverDashboardScreen extends StatefulWidget {
  const GiverDashboardScreen({super.key});

  @override
  State<GiverDashboardScreen> createState() => _GiverDashboardScreenState();
}

class _GiverDashboardScreenState extends State<GiverDashboardScreen> with WidgetsBindingObserver {
  List<FoodItemModel> _myListings = [];
  bool _showLiveListings = true;
  int _pendingRequests = 0;
  int _previousPendingRequests = 0;
  bool _loading = true;
  String? _error;
  late Future<void> _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    // Start auto-refresh every 5 seconds
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            _load();
            _startPeriodicRefresh();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Refresh when app comes to foreground
      _load();
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      if (token.isEmpty) {
        throw Exception('No authentication token found');
      }
      
      final items = await ApiService.instance.getMyFoodItems(token);
      final requests = await ApiService.instance.getGiverRequests(token);
      final pending = requests.where((r) => r.status == 'pending').length;
      
      final reqs  = await ApiService.instance.getGiverRequests(token);
      
      if (mounted) {
        setState(() {
          _myListings = items;
          _pendingRequests = reqs.where((r) => r.status == 'pending').length;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _showListingDetails(BuildContext context, FoodItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ListingDetailSheet(
        item: item,
        onDelete: () => _deleteListing(item.id),
      ),
    );
  }

  Future<void> _deleteListing(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      await ApiService.instance.deleteFoodItem(id, token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing deleted.'), backgroundColor: AppTheme.success));
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppTheme.error));
    }
  }

  Widget _statCard(String value, String label, IconData icon, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.textPrimary, size: 26),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final active    = _myListings.where((f) => f.status == 'available').length;
    final completed = _myListings.where((f) => f.status == 'completed').length;
    final rating    = user?.rating ?? 0.0;
    
    final displayedListings = _showLiveListings 
        ? _myListings.where((f) => f.status == 'available').toList()
        : _myListings.where((f) => f.status != 'available').toList();

    // Scaffold – Material page container
    return Scaffold(
      // AppBar – top bar with greeting + notification icon
      appBar: AppBar(
        leading: BackButton(onPressed: () { if (context.canPop()) { context.pop(); } else { context.go(AppRoutes.roleSelection); } }),
        title: const Text('FoodLoop'),
        backgroundColor: AppTheme.background,
        elevation: 1,
        actions: [
          // IconButton – notification bell with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: _pendingRequests > 0 ? AppTheme.error : AppTheme.textPrimary),
                onPressed: () => context.go(AppRoutes.giverRequests),
                tooltip: _pendingRequests > 0 ? '$_pendingRequests pending request(s)' : 'No pending requests',
              ),
              if (_pendingRequests > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: IgnorePointer(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 4)],
                      ),
                      child: Center(child: Text(_pendingRequests.toString(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      // FloatingActionButton – shortcut to post food
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.postFood),
        backgroundColor: AppTheme.giverPrimary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Post Food', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600)),
      ),

      // RefreshIndicator – pull-to-refresh
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.giverPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting banner ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${user?.name.split(' ').first ?? 'Giver'}!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Thank you for reducing food waste.',
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Stats row ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _statCard(active.toString(),    'Active\nListings', Icons.restaurant_outlined),
                    const SizedBox(width: 10),
                    _statCard(completed.toString(), 'Completed',        Icons.check_circle_outline),
                    const SizedBox(width: 10),
                    _statCard(rating.toStringAsFixed(1), 'Avg Rating',   Icons.star_rounded, onTap: () {
                      if (user != null) ReviewsBottomSheet.show(context, user.id);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── My listings heading ───────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Live'),
                      selected: _showLiveListings,
                      onSelected: (_) => setState(() => _showLiveListings = true),
                      selectedColor: AppTheme.giverPrimary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: _showLiveListings ? AppTheme.giverPrimary : AppTheme.textSecondary,
                        fontWeight: _showLiveListings ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Past'),
                      selected: !_showLiveListings,
                      onSelected: (_) => setState(() => _showLiveListings = false),
                      selectedColor: AppTheme.giverPrimary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: !_showLiveListings ? AppTheme.giverPrimary : AppTheme.textSecondary,
                        fontWeight: !_showLiveListings ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    ),
                    const Spacer(),
                    TextButton(onPressed: () => context.go(AppRoutes.giverRequests), child: const Text('View Requests')),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Content ───────────────────────────────────
              if (_loading)
                const LoadingShimmer()
              else if (_error != null)
                Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(_error!, style: const TextStyle(color: AppTheme.error))))
              else if (displayedListings.isEmpty)
                // Empty state
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.restaurant_menu_outlined, size: 72, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(_showLiveListings ? 'No live listings' : 'No past listings', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      Text(_showLiveListings ? 'Tap the button below to share your first food item.' : 'Your completed and closed listings will appear here.', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              else
                // ListView – list of food cards
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: displayedListings.length,
                  itemBuilder: (_, i) => FoodCard(
                    item: displayedListings[i], 
                    onTap: () => _showListingDetails(context, displayedListings[i]),
                  ),
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingDetailSheet extends StatelessWidget {
  final FoodItemModel item;
  final VoidCallback onDelete;

  const _ListingDetailSheet({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final bool isLive = item.status == 'available';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text(item.title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(
                  isLive ? 'LIVE' : item.status.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: isLive ? Colors.green : Colors.grey,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Text('${item.quantity} ${item.quantityUnit}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(item.description.isNotEmpty ? item.description : 'No description provided.', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          
          if (isLive) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close sheet
                  onDelete(); // Trigger delete
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Listing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.error,
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
