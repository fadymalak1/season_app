import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:season_app/features/home/providers.dart';
import 'package:season_app/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'package:season_app/features/home/presentation/screens/home_page.dart';
import 'package:season_app/features/home/presentation/screens/card_page.dart';
import 'package:season_app/features/home/presentation/screens/group_page.dart';
import 'package:season_app/features/home/presentation/screens/bag_page.dart';
import 'package:season_app/features/profile/presentation/screens/profile_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    
    final List<Widget> pages = [
      const HomePage(),
      const CardPage(),
      const GroupPage(),
      const BagPage(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

