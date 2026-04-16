// ============================================================
// widgets/food_card.dart  –  Reusable Food Listing Card
// Widgets: Card, InkWell, Row, Column, ClipRRect, Container,
//          Text, Icon, Chip, SizedBox, CachedNetworkImage
// ============================================================

import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/food_item_model.dart';
import '../models/food_item_model.dart';
import '../services/api_service.dart';
import 'reviews_bottom_sheet.dart';

class FoodCard extends StatelessWidget {
  final FoodItemModel item;
  final VoidCallback onTap;

  const FoodCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Card – elevated surface with rounded corners
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      // InkWell – ripple effect on tap
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ── Food thumbnail ────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 82, height: 82,
                  child: () {
                    final url = ApiService.resolvePhotoUrl(item.photoUrl);
                    return url != null
                        ? Image.network(url, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder())
                        : _placeholder();
                  }(),
                ),
              ),

              const SizedBox(width: 14),

              // ── Content ───────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row – title + expiry badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title,
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        // Expiry badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: item.isExpired ? AppTheme.error : Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(item.timeRemaining,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                              color: item.isExpired ? AppTheme.error : AppTheme.textSecondary)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Giver name & Rating
                    Row(
                      children: [
                        Expanded(child: Text('By ${item.giverName}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (item.giverRating > 0)
                          InkWell(
                            onTap: () => ReviewsBottomSheet.show(context, item.giverId),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF39C12)),
                                  const SizedBox(width: 2),
                                  Text(item.giverRating.toStringAsFixed(1), style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Location row
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(child: Text(item.address, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ── Bottom row – category + quantity ──
                    Row(
                      children: [
                        // Category chip
                        _chip('${item.categoryIcon} ${item.category}'),
                        const SizedBox(width: 6),
                        _chip('${item.quantity} ${item.quantityUnit}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppTheme.giverPrimary.withValues(alpha: 0.12),
    child: Center(child: Text(item.categoryIcon, style: const TextStyle(fontSize: 34))),
  );

  Widget _chip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300)),
    child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
  );
}
