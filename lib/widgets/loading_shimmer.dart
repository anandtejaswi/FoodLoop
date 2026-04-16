// ============================================================
// widgets/loading_shimmer.dart  –  Shimmer Loading Skeleton
// Widgets: ListView, Container, Row, Column, Shimmer
// ============================================================

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final int itemCount;
  const LoadingShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    // ListView – stacked shimmer placeholders
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: itemCount,
      itemBuilder: (_, __) => Shimmer.fromColors(
        // Shimmer – animated silver-to-white placeholder
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              // Thumbnail skeleton
              Container(width: 82, height: 82, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 10),
                    Row(children: [
                      Container(height: 22, width: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                      const SizedBox(width: 8),
                      Container(height: 22, width: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
