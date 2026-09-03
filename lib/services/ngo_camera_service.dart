import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

enum NgoFeedType { upload, liveLink }

class NgoCameraFeed {
  final String id;
  final NgoFeedType type;
  final String? label;
  final String? videoPath;
  final String? streamUrl;
  final DateTime createdAt;

  NgoCameraFeed({
    required this.id,
    required this.type,
    this.label,
    this.videoPath,
    this.streamUrl,
    required this.createdAt,
  });

  factory NgoCameraFeed.fromMap(Map<String, dynamic> map) {
    return NgoCameraFeed(
      id: map['id'] as String,
      type: (map['feed_type'] as String) == 'upload' ? NgoFeedType.upload : NgoFeedType.liveLink,
      label: map['label'] as String?,
      videoPath: map['video_path'] as String?,
      streamUrl: map['stream_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class NgoCameraService {
  NgoCameraService._();
  static final NgoCameraService instance = NgoCameraService._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<void> addUploadedVideo({
    required AppUser user,
    required String videoPath,
    String? label,
  }) async {
    await _client.from('ngo_camera_feeds').insert({
      'profile_id': user.id,
      'organization_id': user.organizationId,
      'feed_type': 'upload',
      'label': label,
      'video_path': videoPath,
    });
  }

  Future<void> addLiveLink({
    required AppUser user,
    required String streamUrl,
    String? label,
  }) async {
    await _client.from('ngo_camera_feeds').insert({
      'profile_id': user.id,
      'organization_id': user.organizationId,
      'feed_type': 'live_link',
      'label': label,
      'stream_url': streamUrl,
    });
  }

  Future<List<NgoCameraFeed>> fetchFeeds(String profileId) async {
    final rows = await _client
        .from('ngo_camera_feeds')
        .select()
        .eq('profile_id', profileId)
        .order('created_at', ascending: false);
    return (rows as List).map((r) => NgoCameraFeed.fromMap(r as Map<String, dynamic>)).toList();
  }
}