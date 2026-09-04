// FILE: lib/services/inspector_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Combined `profiles` + `pmu_inspectors` data for the authenticated inspector.
class InspectorProfileData {
  final String profileId;
  final String fullName;
  final String? phone;
  final String status; // pending, approved, rejected
  final String department;
  final String? designation;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final DateTime? locationUpdatedAt;

  const InspectorProfileData({
    required this.profileId,
    required this.fullName,
    this.phone,
    required this.status,
    required this.department,
    this.designation,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.locationUpdatedAt,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory InspectorProfileData.fromMaps({
    required Map<String, dynamic> profile,
    required Map<String, dynamic> pmu,
  }) {
    return InspectorProfileData(
      profileId: profile['id'] as String,
      fullName: profile['full_name'] as String,
      phone: profile['phone'] as String?,
      status: profile['status'] as String,
      department: pmu['department'] as String,
      designation: pmu['designation'] as String?,
      createdAt: DateTime.parse(profile['created_at'] as String),
      latitude: (pmu['latitude'] as num?)?.toDouble(),
      longitude: (pmu['longitude'] as num?)?.toDouble(),
      locationUpdatedAt: pmu['location_updated_at'] != null
          ? DateTime.parse(pmu['location_updated_at'] as String)
          : null,
    );
  }

  InspectorProfileData copyWithLocation({
    required double latitude,
    required double longitude,
    required DateTime locationUpdatedAt,
  }) {
    return InspectorProfileData(
      profileId: profileId,
      fullName: fullName,
      phone: phone,
      status: status,
      department: department,
      designation: designation,
      createdAt: createdAt,
      latitude: latitude,
      longitude: longitude,
      locationUpdatedAt: locationUpdatedAt,
    );
  }
}

class InspectorService {
  InspectorService._();
  static final InspectorService instance = InspectorService._();

  final SupabaseClient _client = Supabase.instance.client;

  /// Loads the currently authenticated inspector's combined profile.
  /// Returns null if not logged in, not a PMU inspector, or the
  /// `pmu_inspectors` row hasn't been created yet.
  Future<InspectorProfileData?> fetchCurrentProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;

    final profile = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    if (profile == null) return null;

    final pmu = await _client.from('pmu_inspectors').select().eq('profile_id', uid).maybeSingle();
    if (pmu == null) return null;

    return InspectorProfileData.fromMaps(profile: profile, pmu: pmu);
  }

  /// Persists a newly detected GPS position to the inspector's own row.
  /// Requires the `pmu_update_own_location` RLS policy from the migration.
  Future<DateTime> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Not authenticated.');
    }
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      throw ArgumentError('Invalid coordinates.');
    }

    final now = DateTime.now().toUtc();
    await _client.from('pmu_inspectors').update({
      'latitude': latitude,
      'longitude': longitude,
      'location_updated_at': now.toIso8601String(),
    }).eq('profile_id', uid);

    return now;
  }
}