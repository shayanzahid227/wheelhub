import 'package:wheelhub/data/vehicle_dummy_data.dart';
import 'package:wheelhub/models/vehicle.dart';

class VehicleRepository {
  final List<Vehicle> _vehicles = VehicleDummyData.generate();

  List<Vehicle> getAll() => List.unmodifiable(_vehicles);

  Vehicle? getById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(Vehicle vehicle) => _vehicles.insert(0, vehicle);

  void update(Vehicle vehicle) {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) _vehicles[index] = vehicle;
  }

  void delete(String id) => _vehicles.removeWhere((v) => v.id == id);
}
