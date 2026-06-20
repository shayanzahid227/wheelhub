import 'package:wheelhub/core/constant/vehicle_assets.dart';
import 'package:wheelhub/models/app_user.dart';
import 'package:wheelhub/models/vehicle.dart';
import 'package:wheelhub/models/vehicle_enums.dart';

/// Logged-in marketplace user used across buyer/seller flows.
const currentUser = AppUser(
  id: 'user_wheelhub_001',
  name: 'Shayan',
  phone: '+1 555-0142',
  email: 'shayan@gmail.com',
  city: 'Austin',
);

class VehicleDummyData {
  static List<Vehicle> generate() {
    final vehicles = <Vehicle>[];
    var index = 0;

    void addBatch({
      required int count,
      required VehicleCategory category,
      required List<_Template> templates,
      bool electricOnly = false,
    }) {
      for (var i = 0; i < count; i++) {
        final template = templates[i % templates.length];
        final id = 'veh_${(index + 1).toString().padLeft(3, '0')}';
        final year = 2016 + (index % 9);
        final mileage = template.condition == VehicleCondition.newVehicle
            ? 0
            : 5000 + (index * 1370) % 95000;
        final price = template.basePrice + (index % 7) * 850;
        final city = _cities[index % _cities.length];
        final isSevenSeater =
            category == VehicleCategory.suvs && index % 3 == 0;

        vehicles.add(
          Vehicle(
            id: id,
            category: category,
            brand: template.brand,
            model: template.model,
            variant: template.variants[index % template.variants.length],
            manufacturingYear: year,
            registrationCity: city,
            condition: template.condition,
            fuelType: electricOnly ? FuelType.electric : template.fuelType,
            transmission: template.transmission,
            engineCapacity: electricOnly ? 'N/A' : template.engineCapacity,
            mileage: mileage,
            exteriorColor: _colors[index % _colors.length],
            price: price,
            description: template.description
                .replaceAll('{brand}', template.brand)
                .replaceAll('{model}', template.model)
                .replaceAll('{city}', city),
            sellerContactNumber: _sellerPhones[index % _sellerPhones.length],
            sellerName: _sellerNames[index % _sellerNames.length],
            location: '$city, TX',
            images: [
              VehicleAssets.pathFor(
                category: category,
                indexInCategory: i,
                isSevenSeater: isSevenSeater,
              ),
            ],
            sellerId: 'seller_${(index % 12) + 1}',
            status: index % 17 == 0
                ? VehicleStatus.sold
                : index % 11 == 0
                    ? VehicleStatus.reserved
                    : VehicleStatus.available,
            isSevenSeater: isSevenSeater,
            createdAt: DateTime.now().subtract(Duration(days: index * 2)),
          ),
        );
        index++;
      }
    }

    addBatch(
      count: 25,
      category: VehicleCategory.cars,
      templates: _carTemplates,
    );
    addBatch(
      count: 20,
      category: VehicleCategory.bikes,
      templates: _bikeTemplates,
    );
    addBatch(
      count: 10,
      category: VehicleCategory.buses,
      templates: _busTemplates,
    );
    addBatch(
      count: 15,
      category: VehicleCategory.suvs,
      templates: _suvTemplates,
    );
    addBatch(
      count: 10,
      category: VehicleCategory.electricVehicles,
      templates: _evTemplates,
      electricOnly: true,
    );

    return vehicles;
  }

  static const _cities = [
    'Austin',
    'Dallas',
    'Houston',
    'San Antonio',
    'Phoenix',
    'Denver',
    'Seattle',
    'Chicago',
    'Miami',
    'Atlanta',
  ];

  static const _colors = [
    'Pearl White',
    'Midnight Black',
    'Silver Metallic',
    'Deep Blue',
    'Crimson Red',
    'Graphite Grey',
    'Forest Green',
  ];

  static const _sellerNames = [
    'Jordan Lee',
    'Priya Shah',
    'Marcus Cole',
    'Emily Turner',
    'David Kim',
    'Sarah Nguyen',
    'Chris Patel',
    'Olivia Brooks',
    'Ryan Foster',
    'Mia Rodriguez',
    'Ethan Walker',
    'Nina Alvarez',
  ];

  static const _sellerPhones = [
    '+1 555-0101',
    '+1 555-0102',
    '+1 555-0103',
    '+1 555-0104',
    '+1 555-0105',
    '+1 555-0106',
    '+1 555-0107',
    '+1 555-0108',
    '+1 555-0109',
    '+1 555-0110',
    '+1 555-0111',
    '+1 555-0112',
  ];

  static const _carTemplates = [
    _Template(
      brand: 'Toyota',
      model: 'Corolla',
      variants: ['LE', 'SE', 'XSE'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.automatic,
      engineCapacity: '1.8L',
      basePrice: 18500,
      condition: VehicleCondition.used,
      description:
          'Well-maintained {brand} {model} with full service history. Smooth daily driver in {city}.',
    ),
    _Template(
      brand: 'Honda',
      model: 'Civic',
      variants: ['Sport', 'EX', 'Touring'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.manual,
      engineCapacity: '2.0L',
      basePrice: 19200,
      condition: VehicleCondition.used,
      description:
          'Reliable {brand} {model} with low ownership cost. Ideal for city commuting in {city}.',
    ),
    _Template(
      brand: 'Hyundai',
      model: 'Elantra',
      variants: ['SEL', 'Limited'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.automatic,
      engineCapacity: '2.0L',
      basePrice: 16800,
      condition: VehicleCondition.newVehicle,
      description:
          'Like-new {brand} {model} with modern safety tech and excellent fuel economy.',
    ),
    _Template(
      brand: 'Mazda',
      model: 'Mazda3',
      variants: ['Preferred', 'Premium'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.automatic,
      engineCapacity: '2.5L',
      basePrice: 21000,
      condition: VehicleCondition.used,
      description:
          'Premium feel {brand} {model} with sharp handling and clean interior.',
    ),
    _Template(
      brand: 'Volkswagen',
      model: 'Jetta',
      variants: ['S', 'SE', 'GLI'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.automatic,
      engineCapacity: '1.5L',
      basePrice: 17500,
      condition: VehicleCondition.used,
      description:
          'Comfortable {brand} {model} sedan with spacious trunk and efficient engine.',
    ),
  ];

  static const _bikeTemplates = [
    _Template(
      brand: 'Yamaha',
      model: 'MT-07',
      variants: ['Standard', 'ABS'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.manual,
      engineCapacity: '689cc',
      basePrice: 7200,
      condition: VehicleCondition.used,
      description:
          'Agile {brand} {model} naked bike, perfect for urban rides in {city}.',
    ),
    _Template(
      brand: 'Kawasaki',
      model: 'Ninja 400',
      variants: ['ABS', 'KRT Edition'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.manual,
      engineCapacity: '399cc',
      basePrice: 5400,
      condition: VehicleCondition.used,
      description:
          'Sporty {brand} {model} with lightweight chassis and beginner-friendly power.',
    ),
    _Template(
      brand: 'Harley-Davidson',
      model: 'Iron 883',
      variants: ['Base', 'Custom'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.manual,
      engineCapacity: '883cc',
      basePrice: 8900,
      condition: VehicleCondition.used,
      description:
          'Classic cruiser styling on this {brand} {model}. Strong torque and iconic sound.',
    ),
    _Template(
      brand: 'Honda',
      model: 'CB500F',
      variants: ['Standard', 'A2'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.manual,
      engineCapacity: '471cc',
      basePrice: 6100,
      condition: VehicleCondition.newVehicle,
      description:
          'Versatile {brand} {model} suitable for commuting and weekend rides.',
    ),
  ];

  static const _busTemplates = [
    _Template(
      brand: 'Mercedes-Benz',
      model: 'Sprinter',
      variants: ['2500', '3500'],
      fuelType: FuelType.diesel,
      transmission: TransmissionType.automatic,
      engineCapacity: '3.0L',
      basePrice: 42000,
      condition: VehicleCondition.used,
      description:
          'Commercial-ready {brand} {model} shuttle with high roof and low mileage.',
    ),
    _Template(
      brand: 'Ford',
      model: 'Transit',
      variants: ['150', '250'],
      fuelType: FuelType.diesel,
      transmission: TransmissionType.automatic,
      engineCapacity: '3.5L',
      basePrice: 38500,
      condition: VehicleCondition.used,
      description:
          'Reliable {brand} {model} passenger bus ideal for fleet operators in {city}.',
    ),
  ];

  static const _suvTemplates = [
    _Template(
      brand: 'Toyota',
      model: 'RAV4',
      variants: ['XLE', 'Limited', 'Adventure'],
      fuelType: FuelType.hybrid,
      transmission: TransmissionType.automatic,
      engineCapacity: '2.5L',
      basePrice: 28900,
      condition: VehicleCondition.used,
      description:
          'Family-friendly {brand} {model} SUV with excellent resale value.',
    ),
    _Template(
      brand: 'Ford',
      model: 'Explorer',
      variants: ['XLT', 'ST-Line', 'Platinum'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.automatic,
      engineCapacity: '2.3L',
      basePrice: 33500,
      condition: VehicleCondition.used,
      description:
          'Spacious 3-row {brand} {model} with modern infotainment and safety suite.',
    ),
    _Template(
      brand: 'Jeep',
      model: 'Grand Cherokee',
      variants: ['Laredo', 'Limited', 'Trailhawk'],
      fuelType: FuelType.petrol,
      transmission: TransmissionType.automatic,
      engineCapacity: '3.6L',
      basePrice: 31200,
      condition: VehicleCondition.used,
      description:
          'Capable {brand} {model} with premium interior and all-weather confidence.',
    ),
  ];

  static const _evTemplates = [
    _Template(
      brand: 'Tesla',
      model: 'Model 3',
      variants: ['Standard Range', 'Long Range'],
      fuelType: FuelType.electric,
      transmission: TransmissionType.automatic,
      engineCapacity: 'N/A',
      basePrice: 32900,
      condition: VehicleCondition.used,
      description:
          'Efficient {brand} {model} EV with autopilot hardware and fast charging support.',
    ),
    _Template(
      brand: 'Chevrolet',
      model: 'Bolt EUV',
      variants: ['LT', 'Premier'],
      fuelType: FuelType.electric,
      transmission: TransmissionType.automatic,
      engineCapacity: 'N/A',
      basePrice: 26800,
      condition: VehicleCondition.newVehicle,
      description:
          'Compact electric crossover {brand} {model} with strong range for daily use.',
    ),
    _Template(
      brand: 'Hyundai',
      model: 'Ioniq 5',
      variants: ['SE', 'SEL', 'Limited'],
      fuelType: FuelType.electric,
      transmission: TransmissionType.automatic,
      engineCapacity: 'N/A',
      basePrice: 35900,
      condition: VehicleCondition.used,
      description:
          'Futuristic {brand} {model} with ultra-fast charging and spacious cabin.',
    ),
  ];
}

class _Template {
  final String brand;
  final String model;
  final List<String> variants;
  final FuelType fuelType;
  final TransmissionType transmission;
  final String engineCapacity;
  final double basePrice;
  final VehicleCondition condition;
  final String description;

  const _Template({
    required this.brand,
    required this.model,
    required this.variants,
    required this.fuelType,
    required this.transmission,
    required this.engineCapacity,
    required this.basePrice,
    required this.condition,
    required this.description,
  });
}
