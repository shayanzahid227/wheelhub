import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/providers/vehicle_provider.dart';
import 'package:wheelhub/screens/add_vehicle/add_vehicle_screen.dart';
import 'package:wheelhub/screens/home/home_screen.dart';
import 'package:wheelhub/screens/profile/profile_screen.dart';
import 'package:wheelhub/screens/saved/saved_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    SavedScreen(),
    AddVehicleScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: NavigationBar(
          backgroundColor: planCardColor,
          indicatorColor: primaryColor.withValues(alpha: 0.2),
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: provider.favoriteVehicles.isNotEmpty,
                label: Text('${provider.favoriteVehicles.length}'),
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: const Icon(Icons.favorite),
              label: 'Saved',
            ),
            const NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Post Ad',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
