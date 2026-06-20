enum VehicleCategory {
  cars('Cars'),
  bikes('Bikes'),
  buses('Buses'),
  suvs('SUVs'),
  sevenSeaters('7 Seaters'),
  electricVehicles('Electric Vehicles');

  const VehicleCategory(this.label);
  final String label;
}

enum VehicleStatus {
  available('Available'),
  reserved('Reserved'),
  sold('Sold');

  const VehicleStatus(this.label);
  final String label;
}

enum VehicleCondition {
  newVehicle('New'),
  used('Used');

  const VehicleCondition(this.label);
  final String label;
}

enum FuelType {
  petrol('Petrol'),
  diesel('Diesel'),
  electric('Electric'),
  hybrid('Hybrid'),
  cng('CNG');

  const FuelType(this.label);
  final String label;
}

enum TransmissionType {
  manual('Manual'),
  automatic('Automatic');

  const TransmissionType(this.label);
  final String label;
}
