/// County model for location management
class County {
  final int id;
  final String countyName;
  final String countyCode;

  County({
    required this.id,
    required this.countyName,
    required this.countyCode,
  });

  /// Create County from JSON response
  factory County.fromJson(Map<String, dynamic> json) {
    return County(
      id: json['id'] as int,
      countyName: json['county_name'] as String,
      countyCode: json['county_code'] as String,
    );
  }

  /// Convert County to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'county_name': countyName,
      'county_code': countyCode,
    };
  }

  @override
  String toString() => countyName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is County && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Constituency model for location management
class Constituency {
  final int id;
  final int countyId;
  final String constituencyName;

  Constituency({
    required this.id,
    required this.countyId,
    required this.constituencyName,
  });

  /// Create Constituency from JSON response
  factory Constituency.fromJson(Map<String, dynamic> json) {
    return Constituency(
      id: json['id'] as int,
      countyId: json['county_id'] as int,
      constituencyName: json['constituency_name'] as String,
    );
  }

  /// Convert Constituency to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'county_id': countyId,
      'constituency_name': constituencyName,
    };
  }

  @override
  String toString() => constituencyName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Constituency && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
