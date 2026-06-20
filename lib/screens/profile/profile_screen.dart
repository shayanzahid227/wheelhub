import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/auth/screens/login/login_screen.dart';
import 'package:wheelhub/auth/viewmodels/auth_viewmodel.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/providers/vehicle_provider.dart';
import 'package:wheelhub/screens/chat/chat_list_screen.dart';
import 'package:wheelhub/screens/my_vehicles/my_vehicles_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: planCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    (user?.fullName.isNotEmpty == true
                            ? user!.fullName.characters.first
                            : 'W')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'WheelHub User',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (user?.email != null)
                        Text(
                          user!.email,
                          style: const TextStyle(color: greyColor),
                        ),
                      if (user?.phoneNumber != null)
                        Text(
                          user!.phoneNumber,
                          style: const TextStyle(color: greyColor),
                        ),
                      if (user?.bio != null)
                        Text(
                          user!.bio!,
                          style: const TextStyle(color: lightGreyColor),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _tile(
            icon: Icons.directions_car_outlined,
            title: 'My Vehicles',
            subtitle: '${vehicleProvider.myVehicles.length} listings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyVehiclesScreen()),
            ),
          ),
          _tile(
            icon: Icons.chat_bubble_outline,
            title: 'Messages',
            subtitle: '${vehicleProvider.chatThreads.length} conversations',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            ),
          ),
          _tile(
            icon: Icons.favorite_border,
            title: 'Saved Vehicles',
            subtitle: '${vehicleProvider.favoriteVehicles.length} favorites',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Every wheelHub user can buy and sell vehicles from one account.',
            style: TextStyle(color: lightGreyColor, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: lightBackGroundColor,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(color: greyColor)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
