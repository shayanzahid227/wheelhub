import 'package:wheelhub/models/vehicle_enums.dart';

/// Local vehicle image paths under [dynamicAssets].
class VehicleAssets {
  VehicleAssets._();

  static const basePath = 'images/dynamic_assets';

  static const carCount = 7;
  static const bikeCount = 8;
  static const busCount = 7;
  static const suvCount = 9;
  static const sevenSeaterCount = 7;
  static const evCount = 7;

  static String pathFor({
    required VehicleCategory category,
    required int indexInCategory,
    bool isSevenSeater = false,
  }) {
    if (isSevenSeater || category == VehicleCategory.sevenSeaters) {
      return _asset('7seater', indexInCategory, sevenSeaterCount);
    }

    return switch (category) {
      VehicleCategory.cars => _asset('car', indexInCategory, carCount),
      VehicleCategory.bikes => _asset('bike', indexInCategory, bikeCount),
      VehicleCategory.buses => _asset('bus', indexInCategory, busCount),
      VehicleCategory.suvs => _asset('suv', indexInCategory, suvCount),
      VehicleCategory.sevenSeaters =>
        _asset('7seater', indexInCategory, sevenSeaterCount),
      VehicleCategory.electricVehicles =>
        _asset('ev', indexInCategory, evCount),
    };
  }

  static String _asset(String prefix, int indexInCategory, int total) {
    final number = (indexInCategory % total) + 1;
    return '$basePath/$prefix$number.png';
  }
}
