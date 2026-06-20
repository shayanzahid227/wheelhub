import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/models/vehicle.dart';
import 'package:wheelhub/providers/vehicle_provider.dart';
import 'package:wheelhub/widgets/status_badge.dart';
import 'package:wheelhub/widgets/vehicle_image.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();
    final isFavorite = provider.isFavorite(vehicle.id);
    final price = NumberFormat.simpleCurrency(decimalDigits: 0).format(
      vehicle.price,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: planCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: VehicleImage(
                    source: vehicle.images.first,
                    height: 170,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: StatusBadge(status: vehicle.status),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    onPressed: () => provider.toggleFavorite(vehicle.id),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : whiteColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$price • ${vehicle.manufacturingYear}',
                    style: const TextStyle(color: primaryColor, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: greyColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vehicle.location,
                          style: const TextStyle(color: greyColor, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        vehicle.category.label,
                        style: const TextStyle(
                          color: lightGreyColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
