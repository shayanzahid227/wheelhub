import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/models/vehicle.dart';
import 'package:wheelhub/models/vehicle_enums.dart';
import 'package:wheelhub/providers/vehicle_provider.dart';
import 'package:wheelhub/widgets/vehicle_image.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key, this.existing});

  final Vehicle? existing;

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _variant = TextEditingController();
  final _year = TextEditingController();
  final _registrationCity = TextEditingController();
  final _engineCapacity = TextEditingController();
  final _mileage = TextEditingController();
  final _color = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _sellerPhone = TextEditingController();
  final _sellerName = TextEditingController();
  final _location = TextEditingController();

  VehicleCategory _category = VehicleCategory.cars;
  VehicleCondition _condition = VehicleCondition.used;
  FuelType _fuelType = FuelType.petrol;
  TransmissionType _transmission = TransmissionType.automatic;
  final List<String> _imagePaths = [];
  bool _isSevenSeater = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.existing;
    if (vehicle != null) {
      _category = vehicle.category;
      _brand.text = vehicle.brand;
      _model.text = vehicle.model;
      _variant.text = vehicle.variant;
      _year.text = '${vehicle.manufacturingYear}';
      _registrationCity.text = vehicle.registrationCity;
      _condition = vehicle.condition;
      _fuelType = vehicle.fuelType;
      _transmission = vehicle.transmission;
      _engineCapacity.text = vehicle.engineCapacity;
      _mileage.text = '${vehicle.mileage}';
      _color.text = vehicle.exteriorColor;
      _price.text = vehicle.price.toStringAsFixed(0);
      _description.text = vehicle.description;
      _sellerPhone.text = vehicle.sellerContactNumber;
      _sellerName.text = vehicle.sellerName;
      _location.text = vehicle.location;
      _isSevenSeater = vehicle.isSevenSeater;
      _imagePaths.addAll(vehicle.images);
    } else {
      final user = context.read<VehicleProvider>().user;
      _sellerName.text = user.name;
      _sellerPhone.text = user.phone;
      _location.text = user.city;
      _registrationCity.text = user.city;
    }
  }

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _variant.dispose();
    _year.dispose();
    _registrationCity.dispose();
    _engineCapacity.dispose();
    _mileage.dispose();
    _color.dispose();
    _price.dispose();
    _description.dispose();
    _sellerPhone.dispose();
    _sellerName.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;
    setState(() => _imagePaths.addAll(files.map((f) => f.path)));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image.')),
      );
      return;
    }

    final provider = context.read<VehicleProvider>();
    final images = List<String>.from(_imagePaths);

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        category: _category,
        brand: _brand.text.trim(),
        model: _model.text.trim(),
        variant: _variant.text.trim(),
        manufacturingYear: int.parse(_year.text.trim()),
        registrationCity: _registrationCity.text.trim(),
        condition: _condition,
        fuelType: _fuelType,
        transmission: _transmission,
        engineCapacity: _engineCapacity.text.trim(),
        mileage: int.parse(_mileage.text.trim()),
        exteriorColor: _color.text.trim(),
        price: double.parse(_price.text.trim()),
        description: _description.text.trim(),
        sellerContactNumber: _sellerPhone.text.trim(),
        sellerName: _sellerName.text.trim(),
        location: _location.text.trim(),
        images: images,
        isSevenSeater: _isSevenSeater,
      );
      provider.updateVehicle(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated successfully.')),
      );
      return;
    }

    final vehicle = Vehicle(
      id: provider.nextVehicleId(),
      category: _category,
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      variant: _variant.text.trim(),
      manufacturingYear: int.parse(_year.text.trim()),
      registrationCity: _registrationCity.text.trim(),
      condition: _condition,
      fuelType: _fuelType,
      transmission: _transmission,
      engineCapacity: _engineCapacity.text.trim(),
      mileage: int.parse(_mileage.text.trim()),
      exteriorColor: _color.text.trim(),
      price: double.parse(_price.text.trim()),
      description: _description.text.trim(),
      sellerContactNumber: _sellerPhone.text.trim(),
      sellerName: _sellerName.text.trim(),
      location: _location.text.trim(),
      images: images,
      sellerId: provider.user.id,
      status: VehicleStatus.available,
      isSevenSeater: _isSevenSeater,
      createdAt: DateTime.now(),
    );

    provider.addVehicle(vehicle);
    _formKey.currentState!.reset();
    setState(() {
      _imagePaths.clear();
      _category = VehicleCategory.cars;
      _condition = VehicleCondition.used;
      _fuelType = FuelType.petrol;
      _transmission = TransmissionType.automatic;
      _isSevenSeater = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ad posted! Your vehicle is now live on Home.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              _isEditing ? 'Edit Listing' : 'Post Vehicle Ad',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _dropdown(
              label: 'Vehicle Category',
              value: _category,
              items: VehicleCategory.values,
              itemLabel: (v) => v.label,
              onChanged: (v) => setState(() => _category = v!),
            ),
            _field(_brand, 'Brand', required: true),
            _field(_model, 'Model', required: true),
            _field(_variant, 'Variant', required: true),
            _field(_year, 'Manufacturing Year',
                required: true, keyboard: TextInputType.number),
            _field(_registrationCity, 'Registration City', required: true),
            _dropdown(
              label: 'Condition',
              value: _condition,
              items: VehicleCondition.values,
              itemLabel: (v) => v.label,
              onChanged: (v) => setState(() => _condition = v!),
            ),
            _dropdown(
              label: 'Fuel Type',
              value: _fuelType,
              items: FuelType.values,
              itemLabel: (v) => v.label,
              onChanged: (v) => setState(() => _fuelType = v!),
            ),
            _dropdown(
              label: 'Transmission',
              value: _transmission,
              items: TransmissionType.values,
              itemLabel: (v) => v.label,
              onChanged: (v) => setState(() => _transmission = v!),
            ),
            _field(_engineCapacity, 'Engine Capacity', required: true),
            _field(_mileage, 'Mileage (km)',
                required: true, keyboard: TextInputType.number),
            _field(_color, 'Exterior Color', required: true),
            _field(_price, 'Price',
                required: true, keyboard: TextInputType.number),
            _field(_description, 'Description',
                required: true, maxLines: 4),
            _field(_sellerName, 'Seller Name', required: true),
            _field(_sellerPhone, 'Seller Contact Number', required: true),
            _field(_location, 'Vehicle Location', required: true),
            SwitchListTile(
              value: _isSevenSeater,
              onChanged: (v) => setState(() => _isSevenSeater = v),
              title: const Text('7 Seater'),
              subtitle: const Text('Show in 7 Seaters filter'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                _imagePaths.isEmpty
                    ? 'Upload Images'
                    : '${_imagePaths.length} image(s) selected',
              ),
            ),
            if (_imagePaths.isNotEmpty)
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final path = _imagePaths[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 90,
                            height: 90,
                            child: VehicleImage(source: path),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _imagePaths.removeAt(index)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, size: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isEditing ? 'Save Changes' : 'Post Ad'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
            : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(labelText: label),
        dropdownColor: planCardColor,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(itemLabel(item)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
