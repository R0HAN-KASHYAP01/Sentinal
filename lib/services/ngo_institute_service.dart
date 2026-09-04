import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ngo_institute_profile.dart';
import '../models/institute_map_point.dart';

class NgoInstituteService {
  NgoInstituteService._();
  static final NgoInstituteService instance = NgoInstituteService._();

  final SupabaseClient _client = Supabase.instance.client;

  /// Returns null if the institute hasn't created a profile row yet.
  Future<NgoInstituteProfile?> fetchProfile(String profileId) async {
    final data = await _client
        .from('ngo_institutes')
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();

    if (data == null) return null;
    return NgoInstituteProfile.fromMap(data);
  }

  /// Insert-or-update in one call (profile_id is the primary key).
  Future<NgoInstituteProfile> upsertProfile(NgoInstituteProfile profile) async {
    final data = await _client
        .from('ngo_institutes')
        .upsert(profile.toMap())
        .select()
        .single();

    return NgoInstituteProfile.fromMap(data);
  }

  /// Fetches every institute with valid coordinates, joined with its
  /// organization name, for use on the monitoring map.
  ///
  /// Requires the `ngo_institutes_select_staff` RLS policy (staff-only
  /// read-all) to be present — callers without that access will only ever
  /// get their own row back, per RLS, not an error.
  Future<List<InstituteMapPoint>> fetchAllForMap() async {
    final rows = await _client
        .from('ngo_institutes')
        .select(
          'profile_id, organization_id, scheme_type, address, '
          'registration_number, latitude, longitude, organizations(name)',
        )
        .not('latitude', 'is', null)
        .not('longitude', 'is', null);

    final points = <InstituteMapPoint>[];
    for (final row in rows as List) {
      final point = InstituteMapPoint.tryFromMap(row as Map<String, dynamic>);
      if (point != null) {
        points.add(point);
      }
      // Records with null/invalid coordinates are silently skipped —
      // tryFromMap returns null for those rather than throwing.
    }
    return points;
  }
}