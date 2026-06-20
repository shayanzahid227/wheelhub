import 'package:flutter/material.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/models/vehicle_enums.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final VehicleStatus status;

  Color get _color {
    switch (status) {
      case VehicleStatus.available:
        return primaryColor;
      case VehicleStatus.reserved:
        return orangeColor;
      case VehicleStatus.sold:
        return greyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
