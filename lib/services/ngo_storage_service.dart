import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class NgoStorageService {
  NgoStorageService._();
  static final NgoStorageService instance = NgoStorageService._();

  static const String _bucket = 'ngo-uploads';
  final SupabaseClient _client = Supabase.instance.client;

  /// Uploads bytes under {profileId}/{folder}/{timestamp}_{fileName}
  /// and returns the storage path (not a public URL, since the bucket is private).
  Future<String> uploadFile({
    required String folder,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final profileId = _client.auth.currentUser!.id;
    final path = '$profileId/$folder/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from(_bucket).uploadBinary(path, bytes);
    return path;
  }

  /// Generates a temporary signed URL to view/download a stored file.
  Future<String> getSignedUrl(String path, {int expiresInSeconds = 3600}) {
    return _client.storage.from(_bucket).createSignedUrl(path, expiresInSeconds);
  }
}