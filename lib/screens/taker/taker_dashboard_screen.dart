// ============================================================
// screens/taker/taker_dashboard_screen.dart  –  OSM Map View
// Widgets: Scaffold, AppBar, Stack, FlutterMap, TileLayer,
//          MarkerLayer, Marker, FloatingActionButton,
//          DraggableScrollableSheet, ListView, CircularProgressIndicator
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/food_item_model.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';


class TakerDashboardScreen extends StatefulWidget {
  const TakerDashboardScreen({super.key});

  @override
  State<TakerDashboardScreen> createState() => _TakerDashboardScreenState();
}

class _TakerDashboardScreenState extends State<TakerDashboardScreen> {
  // MapController – programmatic map control
  final MapController _mapController = MapController();

  LatLng _center = const LatLng(20.5937, 78.9629); // Default: India centre
  List<FoodItemModel> _foodItems = [];
  bool _loading = true;
  FoodItemModel? _selected;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final pos = await LocationService.instance.getCurrentPosition();
    if (pos != null) {
      setState(() => _center = LatLng(pos.latitude, pos.longitude));
      _mapController.move(_center, 14);
    }
    _loadFood();
  }

  Future<void> _loadFood() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final items = await ApiService.instance.getFoodItems(
        token: token,
        lat: _center.latitude,
        lng: _center.longitude,
        radiusKm: 10,
        status: 'available',
      );
      if (mounted) setState(() { _foodItems = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build map markers from food items ─────────────────────
  List<Marker> _buildMarkers() => _foodItems.map((item) {
    final isSelected = _selected?.id == item.id;
    return Marker(
      point: LatLng(item.lat, item.lng),
      width: isSelected ? 48 : 40,
      height: isSelected ? 48 : 40,
      child: GestureDetector(
        onTap: () => setState(() => _selected = item),
        // Container – circular map pin
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.secondary,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))],
            border: Border.all(color: Colors.white, width: 2.5),
          ),
          child: Center(
            child: Text(item.categoryIcon, style: TextStyle(fontSize: isSelected ? 22 : 18)),
          ),
        ),
      ),
    );
  }).toList();

  @override
  Widget build(BuildContext context) {
    // Scaffold – page root
    return Scaffold(
      // AppBar – search bar + filter button overlay
      appBar: AppBar(
        leading: BackButton(onPressed: () { if (context.canPop()) { context.pop(); } else { context.go(AppRoutes.roleSelection); } }),
        title: const Text('Food Near You'),
        backgroundColor: AppTheme.background,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () => context.go(AppRoutes.foodList)),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),

      // Stack – layers map + bottom sheet + FAB
      body: Stack(
        children: [
          // ── FlutterMap (OpenStreetMap) ────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              onTap: (_, __) => setState(() => _selected = null),
            ),
            children: [
              // TileLayer – OSM tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.foodloop.app',
                maxZoom: 19,
              ),
              // MarkerLayer – food item pins
              MarkerLayer(markers: _buildMarkers()),
              // Current user location marker
              MarkerLayer(markers: [
                Marker(
                  point: _center,
                  width: 36, height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 10)],
                    ),
                  ),
                ),
              ]),
            ],
          ),

          // ── Loading overlay ───────────────────────────────
          if (_loading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator(color: AppTheme.takerPrimary)),
            ),

          // ── Selected item preview card ────────────────────
          if (_selected != null)
            Positioned(
              bottom: 20, left: 16, right: 16,
              child: Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      // ClipRRect – food thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 72, height: 72,
                          color: Colors.grey.shade100,
                          child: _selected!.photoUrl != null
                              ? Image.network(_selected!.photoUrl!, fit: BoxFit.cover)
                              : Center(child: Text(_selected!.categoryIcon, style: const TextStyle(fontSize: 30))),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selected!.title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(_selected!.address, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            // Row – expiry + distance chips
                            Row(
                              children: [
                                _chip(Icons.access_time_rounded, _selected!.timeRemaining, AppTheme.textSecondary),
                                const SizedBox(width: 6),
                                _chip(Icons.people_outline, '${_selected!.quantity} ${_selected!.quantityUnit}', AppTheme.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow button – go to detail
                      IconButton(
                        onPressed: () => context.go('${AppRoutes.foodDetail}?id=${_selected!.id}'),
                        icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primary, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // FloatingActionButton – recenter map on user
      floatingActionButton: FloatingActionButton(
        onPressed: _initLocation,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.my_location_rounded, color: Colors.white),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
    child: Row(children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    ]),
  );
}
