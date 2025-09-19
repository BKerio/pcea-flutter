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
      print('🌐 Making API call to get counties...');
      final response = await ApiService.getCounties();
      print('🌐 API Response - Success: ${response.isSuccess}, Message: ${response.message}');
      
      if (response.isSuccess && response.data != null) {
        print('🌐 Raw response data: ${response.data}');
        
        // Check if data contains counties key
        if (response.data.containsKey('counties')) {
          final countiesData = response.data['counties'] as List<dynamic>;
          print('🌐 Found ${countiesData.length} counties in response');
          
          _counties = countiesData
              .map((county) => County.fromJson(county as Map<String, dynamic>))
              .toList();
          
          // Sort alphabetically
          _counties!.sort((a, b) => a.countyName.compareTo(b.countyName));
          
          return _counties!;
        } else {
          throw Exception('No counties key found in response data');
        }
      } else {
        // If API fails, provide some mock data for testing
        print('⚠️ API failed, using mock counties data');
        _counties = _getMockCounties();
        return _counties!;
      }
    } catch (e) {
      print('❌ Exception in getCounties: $e');
      
      // Fallback to mock data
      print('⚠️ Using fallback mock counties data');
      _counties = _getMockCounties();
      return _counties!;
    }
  }

  /// Get mock counties for testing
  List<County> _getMockCounties() {
    return [
      County(id: 1, countyName: 'Nairobi', countyCode: '047'),
      County(id: 2, countyName: 'Kiambu', countyCode: '022'),
      County(id: 3, countyName: 'Machakos', countyCode: '016'),
      County(id: 4, countyName: 'Kajiado', countyCode: '034'),
      County(id: 5, countyName: 'Murang\'a', countyCode: '021'),
    ];
  }

  /// Get constituencies for a county (cached)
  Future<List<Constituency>> getConstituencies(int countyId) async {
    if (_constituenciesCache.containsKey(countyId)) {
      return _constituenciesCache[countyId]!;
    }

    try {
      print('🏘️ Making API call to get constituencies for county ID: $countyId');
      final response = await ApiService.getConstituencies(countyId);
      print('🏘️ API Response - Success: ${response.isSuccess}, Message: ${response.message}');
      
      if (response.isSuccess && response.data != null) {
        print('🏘️ Raw response data: ${response.data}');
        
        if (response.data.containsKey('constituencies')) {
          final constituenciesData = response.data['constituencies'] as List<dynamic>;
          print('🏘️ Found ${constituenciesData.length} constituencies in response');
          
          final constituencies = constituenciesData
              .map((constituency) => Constituency.fromJson(constituency as Map<String, dynamic>))
              .toList();
          
          // Sort alphabetically
          constituencies.sort((a, b) => a.constituencyName.compareTo(b.constituencyName));
          
          _constituenciesCache[countyId] = constituencies;
          return constituencies;
        } else {
          throw Exception('No constituencies key found in response data');
        }
      } else {
        // If API fails, provide some mock data for testing
        print('⚠️ API failed, using mock constituencies data');
        final mockConstituencies = _getMockConstituencies(countyId);
        _constituenciesCache[countyId] = mockConstituencies;
        return mockConstituencies;
      }
    } catch (e) {
      print('❌ Exception in getConstituencies: $e');
      
      // Fallback to mock data
      print('⚠️ Using fallback mock constituencies data');
      final mockConstituencies = _getMockConstituencies(countyId);
      _constituenciesCache[countyId] = mockConstituencies;
      return mockConstituencies;
    }
  }

  /// Get mock constituencies for testing
  List<Constituency> _getMockConstituencies(int countyId) {
    switch (countyId) {
      case 1: // Nairobi
        return [
          Constituency(id: 1, countyId: 1, constituencyName: 'Westlands'),
          Constituency(id: 2, countyId: 1, constituencyName: 'Dagoretti North'),
          Constituency(id: 3, countyId: 1, constituencyName: 'Dagoretti South'),
          Constituency(id: 4, countyId: 1, constituencyName: 'Lang\'ata'),
        ];
      case 2: // Kiambu
        return [
          Constituency(id: 5, countyId: 2, constituencyName: 'Juja'),
          Constituency(id: 6, countyId: 2, constituencyName: 'Thika Town'),
          Constituency(id: 7, countyId: 2, constituencyName: 'Ruiru'),
        ];
      case 3: // Machakos
        return [
          Constituency(id: 8, countyId: 3, constituencyName: 'Machakos Town'),
          Constituency(id: 9, countyId: 3, constituencyName: 'Mavoko'),
          Constituency(id: 10, countyId: 3, constituencyName: 'Kathiani'),
        ];
      default:
        return [
          Constituency(id: 11, countyId: countyId, constituencyName: 'Central'),
          Constituency(id: 12, countyId: countyId, constituencyName: 'North'),
          Constituency(id: 13, countyId: countyId, constituencyName: 'South'),
        ];
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
