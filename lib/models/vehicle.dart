import 'package:wheelhub/models/vehicle_enums.dart';

class Vehicle {
  final String id;
  final VehicleCategory category;
  final String brand;
  final String model;
  final String variant;
  final int manufacturingYear;
  final String registrationCity;
  final VehicleCondition condition;
  final FuelType fuelType;
  final TransmissionType transmission;
  final String engineCapacity;
  final int mileage;
  final String exteriorColor;
  final double price;
  final String description;
  final String sellerContactNumber;
  final String sellerName;
  final String location;
  final List<String> images;
  final String sellerId;
  final VehicleStatus status;
  final bool isSevenSeater;
  final DateTime createdAt;

  const Vehicle({
    required this.id,
    required this.category,
    required this.brand,
    required this.model,
    required this.variant,
    required this.manufacturingYear,
    required this.registrationCity,
    required this.condition,
    required this.fuelType,
    required this.transmission,
    required this.engineCapacity,
    required this.mileage,
    required this.exteriorColor,
    required this.price,
    required this.description,
    required this.sellerContactNumber,
    required this.sellerName,
    required this.location,
    required this.images,
    required this.sellerId,
    this.status = VehicleStatus.available,
    this.isSevenSeater = false,
    required this.createdAt,
  });

  String get title => '$brand $model $variant';

  String get displayName => '$brand $model';

  Vehicle copyWith({
    VehicleCategory? category,
    String? brand,
    String? model,
    String? variant,
    int? manufacturingYear,
    String? registrationCity,
    VehicleCondition? condition,
    FuelType? fuelType,
    TransmissionType? transmission,
    String? engineCapacity,
    int? mileage,
    String? exteriorColor,
    double? price,
    String? description,
    String? sellerContactNumber,
    String? sellerName,
    String? location,
    List<String>? images,
    VehicleStatus? status,
    bool? isSevenSeater,
  }) {
    return Vehicle(
      id: id,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      variant: variant ?? this.variant,
      manufacturingYear: manufacturingYear ?? this.manufacturingYear,
      registrationCity: registrationCity ?? this.registrationCity,
      condition: condition ?? this.condition,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      engineCapacity: engineCapacity ?? this.engineCapacity,
      mileage: mileage ?? this.mileage,
      exteriorColor: exteriorColor ?? this.exteriorColor,
      price: price ?? this.price,
      description: description ?? this.description,
      sellerContactNumber: sellerContactNumber ?? this.sellerContactNumber,
      sellerName: sellerName ?? this.sellerName,
      location: location ?? this.location,
      images: images ?? this.images,
      sellerId: sellerId,
      status: status ?? this.status,
      isSevenSeater: isSevenSeater ?? this.isSevenSeater,
      createdAt: createdAt,
    );
  }
}

class VehicleFilter {
  final VehicleCategory? category;
  final double? minPrice;
  final double? maxPrice;
  final int? minYear;
  final int? maxYear;
  final FuelType? fuelType;
  final TransmissionType? transmission;

  const VehicleFilter({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.fuelType,
    this.transmission,
  });

  bool get isActive =>
      category != null ||
      minPrice != null ||
      maxPrice != null ||
      minYear != null ||
      maxYear != null ||
      fuelType != null ||
      transmission != null;

  VehicleFilter copyWith({
    VehicleCategory? category,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    FuelType? fuelType,
    TransmissionType? transmission,
    bool clearCategory = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinYear = false,
    bool clearMaxYear = false,
    bool clearFuelType = false,
    bool clearTransmission = false,
  }) {
    return VehicleFilter(
      category: clearCategory ? null : (category ?? this.category),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minYear: clearMinYear ? null : (minYear ?? this.minYear),
      maxYear: clearMaxYear ? null : (maxYear ?? this.maxYear),
      fuelType: clearFuelType ? null : (fuelType ?? this.fuelType),
      transmission:
          clearTransmission ? null : (transmission ?? this.transmission),
    );
  }

  static const empty = VehicleFilter();
}
