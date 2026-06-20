import 'package:flutter/material.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/models/vehicle.dart';
import 'package:wheelhub/models/vehicle_enums.dart';

class VehicleFilterSheet extends StatefulWidget {
  const VehicleFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  final VehicleFilter initialFilter;
  final ValueChanged<VehicleFilter> onApply;

  @override
  State<VehicleFilterSheet> createState() => _VehicleFilterSheetState();
}

class _VehicleFilterSheetState extends State<VehicleFilterSheet> {
  late VehicleCategory? _category;
  late FuelType? _fuelType;
  late TransmissionType? _transmission;
  late TextEditingController _minPrice;
  late TextEditingController _maxPrice;
  late TextEditingController _minYear;
  late TextEditingController _maxYear;

  @override
  void initState() {
    super.initState();
    _category = widget.initialFilter.category;
    _fuelType = widget.initialFilter.fuelType;
    _transmission = widget.initialFilter.transmission;
    _minPrice = TextEditingController(
      text: widget.initialFilter.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPrice = TextEditingController(
      text: widget.initialFilter.maxPrice?.toStringAsFixed(0) ?? '',
    );
    _minYear = TextEditingController(
      text: widget.initialFilter.minYear?.toString() ?? '',
    );
    _maxYear = TextEditingController(
      text: widget.initialFilter.maxYear?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minPrice.dispose();
    _maxPrice.dispose();
    _minYear.dispose();
    _maxYear.dispose();
    super.dispose();
  }

  double? _parseDouble(String value) =>
      value.trim().isEmpty ? null : double.tryParse(value.trim());

  int? _parseInt(String value) =>
      value.trim().isEmpty ? null : int.tryParse(value.trim());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                color: whiteColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _label('Category'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: VehicleCategory.values.map((category) {
                final selected = _category == category;
                return ChoiceChip(
                  label: Text(category.label),
                  selected: selected,
                  onSelected: (_) => setState(
                    () => _category = selected ? null : category,
                  ),
                  selectedColor: primaryColor.withValues(alpha: 0.25),
                  labelStyle: TextStyle(
                    color: selected ? primaryColor : whiteColor,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Price Range'),
            Row(
              children: [
                Expanded(child: _field(_minPrice, 'Min Price')),
                const SizedBox(width: 10),
                Expanded(child: _field(_maxPrice, 'Max Price')),
              ],
            ),
            const SizedBox(height: 16),
            _label('Year Range'),
            Row(
              children: [
                Expanded(child: _field(_minYear, 'Min Year')),
                const SizedBox(width: 10),
                Expanded(child: _field(_maxYear, 'Max Year')),
              ],
            ),
            const SizedBox(height: 16),
            _label('Fuel Type'),
            Wrap(
              spacing: 8,
              children: FuelType.values.map((fuel) {
                final selected = _fuelType == fuel;
                return ChoiceChip(
                  label: Text(fuel.label),
                  selected: selected,
                  onSelected: (_) => setState(
                    () => _fuelType = selected ? null : fuel,
                  ),
                  selectedColor: primaryColor.withValues(alpha: 0.25),
                  labelStyle: TextStyle(
                    color: selected ? primaryColor : whiteColor,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Transmission'),
            Wrap(
              spacing: 8,
              children: TransmissionType.values.map((transmission) {
                final selected = _transmission == transmission;
                return ChoiceChip(
                  label: Text(transmission.label),
                  selected: selected,
                  onSelected: (_) => setState(
                    () => _transmission = selected ? null : transmission,
                  ),
                  selectedColor: primaryColor.withValues(alpha: 0.25),
                  labelStyle: TextStyle(
                    color: selected ? primaryColor : whiteColor,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _category = null;
                        _fuelType = null;
                        _transmission = null;
                        _minPrice.clear();
                        _maxPrice.clear();
                        _minYear.clear();
                        _maxYear.clear();
                      });
                      widget.onApply(VehicleFilter.empty);
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(
                        VehicleFilter(
                          category: _category,
                          minPrice: _parseDouble(_minPrice.text),
                          maxPrice: _parseDouble(_maxPrice.text),
                          minYear: _parseInt(_minYear.text),
                          maxYear: _parseInt(_maxYear.text),
                          fuelType: _fuelType,
                          transmission: _transmission,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: greyColor)),
      );

  Widget _field(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: whiteColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: greyColor),
        filled: true,
        fillColor: lightBackGroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
