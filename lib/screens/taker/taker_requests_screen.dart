// ============================================================
// screens/taker/taker_requests_screen.dart
// Widgets: Scaffold, AppBar, DefaultTabController, TabBar, TabBarView,
//          ListView, Card, Row, Column, Text, Chip, OutlinedButton,
//          CircularProgressIndicator, RatingBar, RefreshIndicator
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/request_model.dart';
import '../../services/api_service.dart';

class TakerRequestsScreen extends StatefulWidget {
  const TakerRequestsScreen({super.key});

  @override
  State<TakerRequestsScreen> createState() => _TakerRequestsScreenState();
}

class _TakerRequestsScreenState extends State<TakerRequestsScreen>
    with SingleTickerProviderStateMixin {

  // TabController – Active / Past tabs
  late TabController _tabController;
  List<RequestModel> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final reqs  = await ApiService.instance.getTakerRequests(token);
      if (mounted) setState(() { _requests = reqs; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<RequestModel> get _active => _requests.where((r) => r.status == 'pending' || r.status == 'accepted').toList();
  List<RequestModel> get _past   => _requests.where((r) => r.status == 'completed' || r.status == 'rejected').toList();

  Widget _requestCard(RequestModel req) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row – food image + name + status
          Row(
            children: [
              // ClipRRect – food thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60, height: 60,
                  color: Colors.grey.shade100,
                  child: () {
                    final url = ApiService.resolvePhotoUrl(req.foodPhotoUrl);
                    return url != null
                        ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_menu_rounded, color: AppTheme.primary, size: 28))
                        : const Icon(Icons.restaurant_menu_rounded, color: AppTheme.primary, size: 28);
                  }(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.foodTitle, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('From: ${req.giverName}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              // Status chip
              Chip(
                label: Text(req.status.toUpperCase(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                backgroundColor: Color(req.statusColor),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),

          if (req.status == 'accepted') ...[
            const SizedBox(height: 14),
            // Phone number card – shown when giver has accepted
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone_outlined, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Giver\'s Contact', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          req.giverPhone != null && req.giverPhone!.isNotEmpty
                              ? req.giverPhone!
                              : 'No phone number provided',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: req.giverPhone != null ? Colors.green.shade800 : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (req.status == 'completed') ...[
            const SizedBox(height: 14),
            // Leave review button for completed requests
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('${AppRoutes.review}?id=${req.id}&title=${Uri.encodeComponent(req.foodTitle)}&giver=${Uri.encodeComponent(req.giverName)}'),
                icon: const Icon(Icons.star_border_rounded, size: 16, color: Color(0xFFF39C12)),
                label: const Text('Leave a Review', style: TextStyle(color: Color(0xFFF39C12))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF39C12)), textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Scaffold – page root
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () { if (context.canPop()) { context.pop(); } else { context.go(AppRoutes.takerDashboard); } }),
        title: const Text('My Requests'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        // TabBar – Active / Past
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: 'Active (${_active.length})'),
            Tab(text: 'Past (${_past.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.primary,
              // TabBarView – two tab content views
              child: TabBarView(
                controller: _tabController,
                children: [
                  _active.isEmpty
                      ? const Center(child: Text('No active requests', style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)))
                      : ListView.builder(itemCount: _active.length, itemBuilder: (_, i) => _requestCard(_active[i])),
                  _past.isEmpty
                      ? const Center(child: Text('No past requests', style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)))
                      : ListView.builder(itemCount: _past.length, itemBuilder: (_, i) => _requestCard(_past[i])),
                ],
              ),
            ),
    );
  }
}
