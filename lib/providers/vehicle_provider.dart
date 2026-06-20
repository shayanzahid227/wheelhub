import 'package:flutter/foundation.dart';
import 'package:wheelhub/data/vehicle_dummy_data.dart';
import 'package:wheelhub/data/vehicle_repository.dart';
import 'package:wheelhub/models/app_user.dart';
import 'package:wheelhub/models/chat_message.dart';
import 'package:wheelhub/models/vehicle.dart';
import 'package:wheelhub/models/vehicle_enums.dart';

class VehicleProvider extends ChangeNotifier {
  VehicleProvider({VehicleRepository? repository})
      : _repository = repository ?? VehicleRepository();

  final VehicleRepository _repository;
  final AppUser user = currentUser;

  String _searchQuery = '';
  VehicleFilter _filter = VehicleFilter.empty;
  final Set<String> _favoriteIds = {};
  final List<ChatThread> _chatThreads = [];

  String get searchQuery => _searchQuery;
  VehicleFilter get filter => _filter;
  List<Vehicle> get allVehicles => _repository.getAll();
  List<ChatThread> get chatThreads => List.unmodifiable(_chatThreads);

  List<Vehicle> get filteredVehicles {
    final query = _searchQuery.trim().toLowerCase();
    return _repository.getAll().where((vehicle) {
      if (vehicle.status == VehicleStatus.sold && !_isOwnedByUser(vehicle)) {
        // Keep sold listings visible in marketplace unless filtering heavily
      }

      if (_filter.category != null) {
        if (_filter.category == VehicleCategory.sevenSeaters) {
          if (!vehicle.isSevenSeater) return false;
        } else if (vehicle.category != _filter.category) {
          return false;
        }
      }

      if (_filter.minPrice != null && vehicle.price < _filter.minPrice!) {
        return false;
      }
      if (_filter.maxPrice != null && vehicle.price > _filter.maxPrice!) {
        return false;
      }
      if (_filter.minYear != null &&
          vehicle.manufacturingYear < _filter.minYear!) {
        return false;
      }
      if (_filter.maxYear != null &&
          vehicle.manufacturingYear > _filter.maxYear!) {
        return false;
      }
      if (_filter.fuelType != null && vehicle.fuelType != _filter.fuelType) {
        return false;
      }
      if (_filter.transmission != null &&
          vehicle.transmission != _filter.transmission) {
        return false;
      }

      if (query.isEmpty) return true;

      return vehicle.title.toLowerCase().contains(query) ||
          vehicle.brand.toLowerCase().contains(query) ||
          vehicle.model.toLowerCase().contains(query) ||
          vehicle.registrationCity.toLowerCase().contains(query) ||
          vehicle.location.toLowerCase().contains(query);
    }).toList();
  }

  List<Vehicle> get favoriteVehicles =>
      _repository.getAll().where((v) => _favoriteIds.contains(v.id)).toList();

  List<Vehicle> get myVehicles =>
      _repository.getAll().where((v) => v.sellerId == user.id).toList();

  bool isFavorite(String vehicleId) => _favoriteIds.contains(vehicleId);

  Vehicle? vehicleById(String id) => _repository.getById(id);

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setFilter(VehicleFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearFilters() {
    _filter = VehicleFilter.empty;
    notifyListeners();
  }

  void toggleFavorite(String vehicleId) {
    if (_favoriteIds.contains(vehicleId)) {
      _favoriteIds.remove(vehicleId);
    } else {
      _favoriteIds.add(vehicleId);
    }
    notifyListeners();
  }

  String addVehicle(Vehicle vehicle) {
    _repository.add(vehicle);
    notifyListeners();
    return vehicle.id;
  }

  void updateVehicle(Vehicle vehicle) {
    _repository.update(vehicle);
    notifyListeners();
  }

  void deleteVehicle(String id) {
    _repository.delete(id);
    _favoriteIds.remove(id);
    _chatThreads.removeWhere((t) => t.vehicleId == id);
    notifyListeners();
  }

  void markAsSold(String id) {
    final vehicle = _repository.getById(id);
    if (vehicle == null) return;
    _repository.update(vehicle.copyWith(status: VehicleStatus.sold));
    notifyListeners();
  }

  void markAsReserved(String id) {
    final vehicle = _repository.getById(id);
    if (vehicle == null) return;
    _repository.update(vehicle.copyWith(status: VehicleStatus.reserved));
    notifyListeners();
  }

  void simulateBuyNow(String id) {
    markAsReserved(id);
  }

  ChatThread startChat(Vehicle vehicle) {
    for (final thread in _chatThreads) {
      if (thread.vehicleId == vehicle.id) return thread;
    }

    final thread = ChatThread(
      vehicleId: vehicle.id,
      vehicleTitle: vehicle.title,
      sellerId: vehicle.sellerId,
      sellerName: vehicle.sellerName,
      sellerPhone: vehicle.sellerContactNumber,
      messages: [
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          vehicleId: vehicle.id,
          senderId: user.id,
          senderName: user.name,
          text:
              'Hi ${vehicle.sellerName}, I am interested in your ${vehicle.title}. Is it still available?',
          sentAt: DateTime.now(),
        ),
      ],
    );
    _chatThreads.insert(0, thread);
    notifyListeners();
    return thread;
  }

  void sendMessage(String vehicleId, String text) {
    final index = _chatThreads.indexWhere((t) => t.vehicleId == vehicleId);
    if (index == -1) return;

    final thread = _chatThreads[index];
    final updated = thread.copyWith(
      messages: [
        ...thread.messages,
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          vehicleId: vehicleId,
          senderId: user.id,
          senderName: user.name,
          text: text,
          sentAt: DateTime.now(),
        ),
      ],
    );
    _chatThreads[index] = updated;
    notifyListeners();
  }

  ChatThread? threadForVehicle(String vehicleId) {
    try {
      return _chatThreads.firstWhere((t) => t.vehicleId == vehicleId);
    } catch (_) {
      return null;
    }
  }

  String nextVehicleId() {
    final count = _repository.getAll().length + 1;
    return 'veh_${count.toString().padLeft(3, '0')}';
  }

  bool _isOwnedByUser(Vehicle vehicle) => vehicle.sellerId == user.id;
}
