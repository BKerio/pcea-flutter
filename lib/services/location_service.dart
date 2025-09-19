import '../models/location.dart';
import 'api_service.dart';

/// Service for handling location data (counties and constituencies)
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Cached data
  List<County>? _counties;
  Map<int, List<Constituency>> _constituenciesCache = {};

  /// Get all counties (cached)
  Future<List<County>> getCounties() async {
    if (_counties != null) {
      return _counties!;
    }

    try {
      final response = await ApiService.getCounties();
      if (response.isSuccess && response.data != null) {
        final countiesData = response.data['counties'] as List<dynamic>;
        _counties = countiesData
            .map((county) => County.fromJson(county as Map<String, dynamic>))
            .toList();
        
        // Sort alphabetically
        _counties!.sort((a, b) => a.countyName.compareTo(b.countyName));
        
        return _counties!;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to load counties: ${e.toString()}');
    }
  }

  /// Get constituencies for a county (cached)
  Future<List<Constituency>> getConstituencies(int countyId) async {
    if (_constituenciesCache.containsKey(countyId)) {
      return _constituenciesCache[countyId]!;
    }

    try {
      final response = await ApiService.getConstituencies(countyId);
      if (response.isSuccess && response.data != null) {
        final constituenciesData = response.data['constituencies'] as List<dynamic>;
        final constituencies = constituenciesData
            .map((constituency) => Constituency.fromJson(constituency as Map<String, dynamic>))
            .toList();
        
        // Sort alphabetically
        constituencies.sort((a, b) => a.constituencyName.compareTo(b.constituencyName));
        
        _constituenciesCache[countyId] = constituencies;
        return constituencies;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to load constituencies: ${e.toString()}');
    }
  }

  /// Find county by name
  Future<County?> findCountyByName(String name) async {
    final counties = await getCounties();
    try {
      return counties.firstWhere(
        (county) => county.countyName.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Find constituency by name in a county
  Future<Constituency?> findConstituencyByName(int countyId, String name) async {
    final constituencies = await getConstituencies(countyId);
    try {
      return constituencies.firstWhere(
        (constituency) => constituency.constituencyName.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear cache
  void clearCache() {
    _counties = null;
    _constituenciesCache.clear();
  }

  /// Preload all location data
  Future<void> preloadLocationData() async {
    try {
      final counties = await getCounties();
      
      // Preload constituencies for major counties
      final majorCounties = counties.take(10); // Load first 10 counties
      await Future.wait(
        majorCounties.map((county) => getConstituencies(county.id)),
      );
    } catch (e) {
      print('Warning: Could not preload location data: $e');
    }
  }

  /// Get county options for dropdown
  Future<List<DropdownOption>> getCountyOptions() async {
    final counties = await getCounties();
    return counties
        .map((county) => DropdownOption(
              value: county.id,
              label: county.countyName,
            ))
        .toList();
  }

  /// Get constituency options for dropdown
  Future<List<DropdownOption>> getConstituencyOptions(int countyId) async {
    final constituencies = await getConstituencies(countyId);
    return constituencies
        .map((constituency) => DropdownOption(
              value: constituency.id,
              label: constituency.constituencyName,
            ))
        .toList();
  }
}

/// Helper class for dropdown options
class DropdownOption {
  final int value;
  final String label;

  DropdownOption({
    required this.value,
    required this.label,
  });

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownOption && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
