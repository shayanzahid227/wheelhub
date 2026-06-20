import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/models/vehicle.dart';
import 'package:wheelhub/providers/vehicle_provider.dart';
import 'package:wheelhub/screens/add_vehicle/add_vehicle_screen.dart';
import 'package:wheelhub/widgets/status_badge.dart';
import 'package:wheelhub/widgets/vehicle_image.dart';

class MyVehiclesScreen extends StatelessWidget {
  const MyVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = context.watch<VehicleProvider>().myVehicles;

    return Scaffold(
      appBar: AppBar(title: const Text('My Vehicles')),
      body: vehicles.isEmpty
          ? const Center(
              child: Text(
                'You have not posted any vehicles yet.',
                style: TextStyle(color: greyColor),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return _MyVehicleTile(vehicle: vehicle);
              },
            ),
    );
  }
}

class _MyVehicleTile extends StatelessWidget {
  const _MyVehicleTile({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<VehicleProvider>();
    final price = NumberFormat.simpleCurrency(decimalDigits: 0).format(
      vehicle.price,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: planCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VehicleImage(
                  source: vehicle.images.first,
                  width: 88,
                  height: 72,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(price, style: const TextStyle(color: primaryColor)),
                    const SizedBox(height: 6),
                    StatusBadge(status: vehicle.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddVehicleScreen(existing: vehicle),
                    ),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    provider.markAsSold(vehicle.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marked as sold.')),
                    );
                  },
                  child: const Text('Mark Sold'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete listing?'),
                      content: const Text(
                        'This will remove the vehicle from the marketplace.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    provider.deleteVehicle(vehicle.id);
                  }
                },
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
