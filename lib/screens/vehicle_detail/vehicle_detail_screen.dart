import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/models/vehicle_enums.dart';
import 'package:wheelhub/providers/vehicle_provider.dart';
import 'package:wheelhub/screens/chat/chat_screen.dart';
import 'package:wheelhub/widgets/status_badge.dart';
import 'package:wheelhub/widgets/vehicle_image.dart';

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();
    final vehicle = provider.vehicleById(vehicleId);

    if (vehicle == null) {
      return const Scaffold(
        body: Center(child: Text('Vehicle not found')),
      );
    }

    final price = NumberFormat.simpleCurrency(decimalDigits: 0).format(
      vehicle.price,
    );
    final isFavorite = provider.isFavorite(vehicle.id);
    final isOwner = vehicle.sellerId == provider.user.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.displayName),
        actions: [
          IconButton(
            onPressed: () => provider.toggleFavorite(vehicle.id),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.redAccent : whiteColor,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 240,
              child: PageView.builder(
                itemCount: vehicle.images.length,
                itemBuilder: (_, index) => VehicleImage(
                  source: vehicle.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 240,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusBadge(status: vehicle.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _section('Description', vehicle.description),
                  const SizedBox(height: 16),
                  _section('Specifications', null),
                  _specTile('Category', vehicle.category.label),
                  _specTile('Brand', vehicle.brand),
                  _specTile('Model', vehicle.model),
                  _specTile('Variant', vehicle.variant),
                  _specTile('Year', '${vehicle.manufacturingYear}'),
                  _specTile('Registration City', vehicle.registrationCity),
                  _specTile('Condition', vehicle.condition.label),
                  _specTile('Fuel Type', vehicle.fuelType.label),
                  _specTile('Transmission', vehicle.transmission.label),
                  _specTile('Engine', vehicle.engineCapacity),
                  _specTile('Mileage', '${vehicle.mileage} km'),
                  _specTile('Color', vehicle.exteriorColor),
                  _specTile('Location', vehicle.location),
                  const SizedBox(height: 16),
                  _section('Seller Information', null),
                  _specTile('Name', vehicle.sellerName),
                  _specTile('Phone', vehicle.sellerContactNumber),
                  const SizedBox(height: 24),
                  if (!isOwner && vehicle.status == VehicleStatus.available) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          provider.simulateBuyNow(vehicle.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Purchase simulated! Vehicle marked as Reserved.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: const Text('Buy Now'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final thread = provider.startChat(vehicle);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                vehicleId: thread.vehicleId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Chat with Seller'),
                      ),
                    ),
                  ] else if (vehicle.status == VehicleStatus.sold)
                    const Text(
                      'This vehicle has been sold.',
                      style: TextStyle(color: greyColor),
                    )
                  else if (vehicle.status == VehicleStatus.reserved)
                    const Text(
                      'This vehicle is currently reserved.',
                      style: TextStyle(color: orangeColor),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String? body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        if (body != null) ...[
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: greyColor, height: 1.5)),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _specTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: greyColor)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(color: whiteColor)),
          ),
        ],
      ),
    );
  }
}
