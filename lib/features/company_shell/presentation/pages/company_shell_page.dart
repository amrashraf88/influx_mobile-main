import 'package:adzmavall/features/company_shell/presentation/widgets/company_bottom_nav_widget.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompanyShellPage extends StatelessWidget {
  const CompanyShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
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
        child: CompanyBottomNavWidget(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
