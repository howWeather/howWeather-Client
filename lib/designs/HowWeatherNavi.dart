import 'package:client/designs/HowWeatherColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class HowWeatherNaviShell extends StatefulWidget {
  final Widget child;

  const HowWeatherNaviShell({super.key, required this.child});

  @override
  State<HowWeatherNaviShell> createState() => _HowWeatherNaviShellState();
}

class _HowWeatherNaviShellState extends State<HowWeatherNaviShell> {
  final List<String> _routes = [
    '/home',
    '/todaywear',
    '/home/calendar',
    '/home/mypage',
  ];

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return _routes.indexWhere((r) => location.startsWith(r));
  }

  void _onItemTapped(int index) {
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);
    return Scaffold(
      body: widget.child,
      // 기존 bottomNavigationBar 대신 커스텀 위젯 사용
      bottomNavigationBar: _buildRoundedBottomNavigationBar(selectedIndex),
      extendBody: true, // 중요: 본문이 네비바 뒤로 확장되도록 설정
    );
  }

  Widget _buildRoundedBottomNavigationBar(int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          height: 70, // 높이 지정
          color: HowWeatherColor.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'today-weather.svg', '오늘의날씨', selectedIndex),
              _buildNavItem(1, 'cardigan.svg', '오늘뭐입지?', selectedIndex),
              _buildNavItem(2, 'calendar.svg', '기록달력', selectedIndex),
              _buildNavItem(3, 'user-profile.svg', '마이페이지', selectedIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, String iconName, String label, int selectedIndex) {
    final isSelected = index == selectedIndex;
    final color = isSelected
        ? HowWeatherColor.primary[900]
        : HowWeatherColor.neutral[400];

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/$iconName',
              color: color,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
