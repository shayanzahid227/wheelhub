import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/models/vehicle_enums.dart';
import 'package:wheelhub/providers/vehicle_provider.dart';
import 'package:wheelhub/screens/vehicle_detail/vehicle_detail_screen.dart';
import 'package:wheelhub/widgets/vehicle_card.dart';
import 'package:wheelhub/widgets/vehicle_filter_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();
    final vehicles = provider.filteredVehicles;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'wheelHub',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vehicles.length} vehicles available',
                  style: const TextStyle(color: greyColor),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: provider.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Search brand, model, city...',
                      prefixIcon: Icon(Icons.search, color: greyColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: provider.filter.isActive
                        ? primaryColor
                        : lightBackGroundColor,
                    foregroundColor:
                        provider.filter.isActive ? backGroundColor : whiteColor,
                  ),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: planCardColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => VehicleFilterSheet(
                      initialFilter: provider.filter,
                      onApply: provider.setFilter,
                    ),
                  ),
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: VehicleCategory.values.map((category) {
                final selected = provider.filter.category == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.label),
                    selected: selected,
                    onSelected: (_) {
                      provider.setFilter(
                        provider.filter.copyWith(
                          category: selected ? null : category,
                          clearCategory: selected,
                        ),
                      );
                    },
                    selectedColor: primaryColor.withValues(alpha: 0.25),
                    checkmarkColor: primaryColor,
                    labelStyle: TextStyle(
                      color: selected ? primaryColor : whiteColor,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: vehicles.isEmpty
                ? const Center(
                    child: Text(
                      'No vehicles match your search.',
                      style: TextStyle(color: greyColor),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
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
