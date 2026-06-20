import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/providers/vehicle_provider.dart';
import 'package:wheelhub/screens/vehicle_detail/vehicle_detail_screen.dart';
import 'package:wheelhub/widgets/vehicle_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<VehicleProvider>().favoriteVehicles;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Saved Vehicles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: favorites.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 56, color: greyColor),
                        SizedBox(height: 12),
                        Text(
                          'No favorites yet',
                          style: TextStyle(color: greyColor, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap the heart on any listing to save it here.',
                          style: TextStyle(color: lightGreyColor),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final vehicle = favorites[index];
                      return VehicleCard(
                        vehicle: vehicle,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VehicleDetailScreen(vehicleId: vehicle.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
