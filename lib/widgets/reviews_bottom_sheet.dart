import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';

class ReviewsBottomSheet extends StatefulWidget {
  final String giverId;
  const ReviewsBottomSheet({super.key, required this.giverId});

  static void show(BuildContext context, String giverId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReviewsBottomSheet(giverId: giverId),
    );
  }

  @override
  State<ReviewsBottomSheet> createState() => _ReviewsBottomSheetState();
}

class _ReviewsBottomSheetState extends State<ReviewsBottomSheet> {
  List<dynamic> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reviews = await ApiService.instance.getGiverReviews(widget.giverId);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Giver Reviews', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const Divider(),

          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _reviews.isEmpty
                  ? const Center(child: Text('No reviews yet', style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _reviews.length,
                      separatorBuilder: (_, __) => const Divider(height: 32),
                      itemBuilder: (ctx, i) {
                        final r = _reviews[i];
                        final rating = (r['rating'] as num?)?.toInt() ?? 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                  child: Text((r['reviewer_name'] as String? ?? 'U')[0].toUpperCase(), style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(r['reviewer_name'] as String? ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                Row(
                                  children: List.generate(5, (index) => Icon(
                                    index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                                    size: 14, color: const Color(0xFFF39C12),
                                  )),
                                )
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (r['food_title'] != null)
                              Text('Requested: ${r['food_title']}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            if (r['comment'] != null && r['comment'].toString().trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('"${r['comment']}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: AppTheme.textPrimary)),
                            ]
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
