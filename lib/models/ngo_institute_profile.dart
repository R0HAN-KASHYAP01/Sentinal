/// Matches the Postgres enum `ngo_scheme_type`.
enum NgoSchemeType { ngo, educational, economicalDevelopment, socialEmpowerment }

extension NgoSchemeTypeX on NgoSchemeType {
  /// Value stored in the `ngo_institutes.scheme_type` column.
  String get dbValue {
    switch (this) {
      case NgoSchemeType.ngo:
        return 'ngo';
      case NgoSchemeType.educational:
        return 'educational';
      case NgoSchemeType.economicalDevelopment:
        return 'economical_development';
      case NgoSchemeType.socialEmpowerment:
        return 'social_empowerment';
    }
  }

  /// Label shown in the dropdown.
  String get label {
    switch (this) {
      case NgoSchemeType.ngo:
        return 'NGO';
      case NgoSchemeType.educational:
        return 'Educational';
      case NgoSchemeType.economicalDevelopment:
        return 'Economical Development';
      case NgoSchemeType.socialEmpowerment:
        return 'Social Empowerment';
    }
  }

  static NgoSchemeType fromDb(String value) {
    return NgoSchemeType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => NgoSchemeType.ngo,
    );
  }
}

class NgoInstituteProfile {
  final String profileId;
  final String? organizationId;
  final String? registrationNumber;
  final NgoSchemeType? schemeType;
  final String? address;
  final double? latitude;
  final double? longitude;

  const NgoInstituteProfile({
    required this.profileId,
    this.organizationId,
    this.registrationNumber,
    this.schemeType,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory NgoInstituteProfile.fromMap(Map<String, dynamic> map) {
    return NgoInstituteProfile(
      profileId: map['profile_id'] as String,
      organizationId: map['organization_id'] as String?,
      registrationNumber: map['registration_number'] as String?,
      schemeType: map['scheme_type'] != null
          ? NgoSchemeTypeX.fromDb(map['scheme_type'] as String)
          : null,
      address: map['address'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  /// Used for `upsert`. `profile_id` is the PK, so Supabase will insert
  /// a new row the first time and update it on every save afterwards.
  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      if (organizationId != null) 'organization_id': organizationId,
      'registration_number': registrationNumber,
      'scheme_type': schemeType?.dbValue,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  NgoInstituteProfile copyWith({
    String? organizationId,
    String? registrationNumber,
    NgoSchemeType? schemeType,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return NgoInstituteProfile(
      profileId: profileId,
      organizationId: organizationId ?? this.organizationId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      schemeType: schemeType ?? this.schemeType,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}