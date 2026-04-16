// ============================================================
// screens/giver/giver_requests_screen.dart
// Tabs: Pending | Confirmation | History
// – Accepted requests sit in Confirmation until giver responds.
// – Yes  → food marked completed, request marked completed.
// – No   → stays in Confirmation (awaiting future confirmation).
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/request_model.dart';
import '../../services/api_service.dart';

class GiverRequestsScreen extends StatefulWidget {
  const GiverRequestsScreen({super.key});

  @override
  State<GiverRequestsScreen> createState() => _GiverRequestsScreenState();
}

class _GiverRequestsScreenState extends State<GiverRequestsScreen>
    with SingleTickerProviderStateMixin {

  // Three tabs: Pending | Confirmation | History
  late TabController _tabController;
  List<RequestModel> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _startPeriodicRefresh();
    });
  }

  void _startPeriodicRefresh() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) { _load(); _startPeriodicRefresh(); }
    });
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
      final reqs  = await ApiService.instance.getGiverRequests(token);
      if (mounted) setState(() { _requests = reqs; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Accept / Reject a pending request ─────────────────────
  Future<void> _updateStatus(RequestModel req, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      await ApiService.instance.updateRequestStatus(req.id, status, token);
      _load();

      // After accepting, jump to the Confirmation tab so giver sees it
      if (status == 'accepted' && mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          _tabController.animateTo(1);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Request accepted! Check the Confirmation tab.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  // ── Confirm food was actually collected (Yes) ──────────────
  Future<void> _confirmPickup(RequestModel req) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      // Mark food as completed → disappears from active listings
      await ApiService.instance.completeFoodItem(req.foodId, token);
      // Mark the request as completed too
      await ApiService.instance.updateRequestStatus(req.id, 'completed', token);
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "${req.foodTitle}" marked as collected by ${req.takerName}.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  // ── Filtered lists ─────────────────────────────────────────
  List<RequestModel> get _pending       => _requests.where((r) => r.status == 'pending').toList();
  List<RequestModel> get _confirmations => _requests.where((r) => r.status == 'accepted').toList();
  List<RequestModel> get _history       => _requests.where((r) => r.status == 'rejected' || r.status == 'completed').toList();

  // ── Pending request tile ───────────────────────────────────
  Widget _pendingTile(RequestModel req) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _takerRow(req),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(req, 'accepted'),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.takerPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(req, 'rejected'),
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.error),
                    label: const Text('Reject', style: TextStyle(color: AppTheme.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Confirmation tile (persistent until giver responds) ────
  Widget _confirmationTile(RequestModel req) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Subtle amber tint to draw attention
      color: const Color(0xFFFFFBF0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with bell icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active_outlined,
                      color: Colors.amber.shade800, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pickup Confirmation',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Taker + food info
            _takerRow(req),

            const SizedBox(height: 14),

            // The confirmation question
            Text(
              'Has the food been taken by ${req.takerName}?',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 14),

            // Yes / Not yet buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmPickup(req),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Yes, collected'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // "No" – food not yet collected.
                      // Stays in this tab until giver confirms pickup.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Got it. This will stay here until pickup is confirmed.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Not yet',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── History tile ───────────────────────────────────────────
  Widget _historyTile(RequestModel req) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _takerRow(req),
      ),
    );
  }

  // ── Shared taker info row ──────────────────────────────────
  Widget _takerRow(RequestModel req) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.giverPrimary.withValues(alpha: 0.15),
          backgroundImage: req.takerAvatar != null ? NetworkImage(req.takerAvatar!) : null,
          child: req.takerAvatar == null
              ? const Icon(Icons.person, color: AppTheme.giverPrimary)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(req.takerName,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              Text('Food: ${req.foodTitle}',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Chip(
          label: Text(req.status.toUpperCase(),
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          backgroundColor: Color(req.statusColor),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  // ── Empty state helper ────────────────────────────────────
  Widget _empty(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(message,
          style: const TextStyle(
              fontFamily: 'Poppins', color: AppTheme.textSecondary)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          if (context.canPop()) context.pop();
          else context.go(AppRoutes.giverDashboard);
        }),
        title: const Text('Requests'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: 'Pending (${_pending.length})'),
            // Show a dot badge on Confirmation if there are items waiting
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Confirmation'),
                  if (_confirmations.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_confirmations.length}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: 'History (${_history.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.giverPrimary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.giverPrimary,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Pending tab ──────────────────────────
                  _pending.isEmpty
                      ? _empty('No pending requests')
                      : ListView.builder(
                          itemCount: _pending.length,
                          itemBuilder: (_, i) => _pendingTile(_pending[i])),

                  // ── Confirmation tab ─────────────────────
                  _confirmations.isEmpty
                      ? _empty('No confirmations awaiting your response')
                      : ListView.builder(
                          itemCount: _confirmations.length,
                          itemBuilder: (_, i) => _confirmationTile(_confirmations[i])),

                  // ── History tab ──────────────────────────
                  _history.isEmpty
                      ? _empty('No past requests')
                      : ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (_, i) => _historyTile(_history[i])),
                ],
              ),
            ),
    );
  }
}
