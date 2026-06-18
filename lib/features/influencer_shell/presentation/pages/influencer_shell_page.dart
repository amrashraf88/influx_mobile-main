import 'package:adzmavall/features/home/presentation/widgets/home_bottom_nav_widget.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InfluencerShellPage extends StatelessWidget {
  const InfluencerShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const Map<int, int> _branchIndexByNavIndex = <int, int>{
    0: 0,
    1: 1,
    3: 2,
    4: 3,
  };

  static const Map<int, int> _navIndexByBranchIndex = <int, int>{
    0: 0,
    1: 1,
    2: 3,
    3: 4,
  };

  void _onTap(int navIndex) {
    final int? branchIndex = _branchIndexByNavIndex[navIndex];
    if (branchIndex == null) {
      return;
    }

    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: navigationShell,
      bottomNavigationBar: Material(
        color: Colors.transparent,
        elevation: 0,
        child: HomeBottomNavWidget(
          currentIndex:
              _navIndexByBranchIndex[navigationShell.currentIndex] ?? 1,
          firstItemLabelKey: 'influencer_nav_profile',
          firstItemIcon: Icons.person_outline_rounded,
          centerItemEnabled: false,
          onTap: _onTap,
        ),
      ),
    );
  }
}
