import 'package:client/designs/how_weather_color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MyPageSkeleton extends StatelessWidget {
  const MyPageSkeleton({super.key});

  Widget _buildShimmerBox(
      {double height = 20, double width = double.infinity}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        interval: const Duration(seconds: 1),
        color: HowWeatherColor.neutral[200]!,
        colorOpacity: 0.5,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: HowWeatherColor.neutral[100],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 닉네임 & 화살표
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerBox(height: 45, width: 120),
              _buildShimmerBox(height: 30, width: 24),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(
              color: HowWeatherColor.primary[900],
              height: 1,
            ),
          ),

          // "나의 옷장" 헤더
          _buildShimmerBox(height: 24, width: 100),
          const SizedBox(height: 8),

          // 옷장 관련 항목 3개
          _buildShimmerBox(height: 40),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: HowWeatherColor.neutral[200],
              height: 1,
            ),
          ),
          _buildShimmerBox(height: 40),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: HowWeatherColor.neutral[200],
              height: 1,
            ),
          ),
          _buildShimmerBox(height: 40),

          SizedBox(
            height: 10,
          ),

          Container(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(
              color: HowWeatherColor.primary[900],
              height: 1,
            ),
          ),

          // "설정" 헤더
          _buildShimmerBox(height: 24, width: 60),
          const SizedBox(height: 8),

          // 설정 관련 항목 4개
          _buildShimmerBox(height: 40),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: HowWeatherColor.neutral[200],
              height: 1,
            ),
          ),
          _buildShimmerBox(height: 40),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: HowWeatherColor.neutral[200],
              height: 1,
            ),
          ),
          _buildShimmerBox(height: 40),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Divider(
              color: HowWeatherColor.neutral[200],
              height: 1,
            ),
          ),
          _buildShimmerBox(height: 40),
        ],
      ),
    );
  }
}
