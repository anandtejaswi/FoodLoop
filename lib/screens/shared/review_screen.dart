// ============================================================
// screens/shared/review_screen.dart
// Widgets: Scaffold, AppBar, SingleChildScrollView, Column,
//          Row, GestureDetector, Icon, Text, TextField,
//          ElevatedButton, SizedBox, Container, Card
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/request_model.dart';

class ReviewScreen extends StatefulWidget {
  final String? requestId;
  final String? foodTitle;
  final String? giverName;
  const ReviewScreen({super.key, this.requestId, this.foodTitle, this.giverName});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // TextEditingController – review text input
  final _commentCtrl = TextEditingController();

  int _rating   = 0;   // Star rating 1–5
  bool _saving  = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating.'), backgroundColor: AppTheme.error),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final reqId = widget.requestId ?? '';
      if (reqId.isEmpty) {
        throw Exception('Request ID is missing.');
      }

      await ApiService.instance.postReview(reqId, _rating, _commentCtrl.text.trim(), token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted! Thank you 🙏'), backgroundColor: AppTheme.success),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
    }
  }

  // ── Animated star row ─────────────────────────────────────
  Widget _starRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (i) {
      final filled = i < _rating;
      // GestureDetector – tap each star to set rating
      return GestureDetector(
        onTap: () => setState(() => _rating = i + 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: 44,
            color: filled ? const Color(0xFFF39C12) : Colors.grey.shade300,
          ),
        ),
      );
    }),
  );

  String get _ratingLabel {
    switch (_rating) {
      case 1: return 'Poor 😞';
      case 2: return 'Fair 😐';
      case 3: return 'Good 🙂';
      case 4: return 'Great 😊';
      case 5: return 'Excellent 🤩';
      default: return 'Tap to rate';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold – review page container
    return Scaffold(
      // AppBar – back + title
      appBar: AppBar(
        title: const Text('Leave a Review'),
        leading: BackButton(onPressed: () { if (context.canPop()) { context.pop(); } else { context.go(AppRoutes.roleSelection); } }),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Transaction summary card ────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.restaurant_menu_rounded, color: AppTheme.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.foodTitle ?? 'Food Item', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('From ${widget.giverName ?? 'Giver'}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Rating label ────────────────────────────
            const Text('How was your experience?', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(_ratingLabel, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppTheme.textSecondary)),

            const SizedBox(height: 20),

            // ── Star rating ─────────────────────────────
            _starRow(),

            const SizedBox(height: 32),

            // ── Comment box ─────────────────────────────
            const Align(alignment: Alignment.centerLeft, child: Text('Your Comment (optional)', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600))),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Share details about the food quality, pickup experience…',
                hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppTheme.primary, width: 2)),
              ),
            ),

            const SizedBox(height: 28),

            // ── Submit button ───────────────────────────
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: Text(_saving ? 'Submitting…' : 'Submit Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
