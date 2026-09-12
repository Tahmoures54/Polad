import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';

/// اسکلت بارگذاری داشبورد عضو.
class MemberDashboardShimmer extends StatelessWidget {
  const MemberDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.mutedSurface,
      highlightColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: List.generate(
              3,
              (_) => Expanded(
                child: Container(
                  height: 92,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 18, width: 120, color: Colors.white),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Container(
              height: 76,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
