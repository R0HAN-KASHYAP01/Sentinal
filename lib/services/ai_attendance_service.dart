import 'dart:convert';

import 'package:http/http.dart' as http;

/// Service responsible for communicating with the
/// Sentinal AI FastAPI backend.
///
/// Current backend:
/// http://127.0.0.1:8000
///
/// This service currently reads attendance information.
/// It does not run AI locally inside Flutter.
class AiAttendanceService {
  /// FastAPI base URL.
  ///
  /// For Flutter Web running on the same computer:
  /// 127.0.0.1 points to the computer running FastAPI.
  static const String baseUrl = 'http://10.221.136.192:8000';

  /// Request timeout used for API calls.
  static const Duration requestTimeout = Duration(seconds: 10);

  /// Fetch the overall attendance summary.
  ///
  /// Endpoint:
  /// GET /api/v1/attendance/summary
  Future<Map<String, dynamic>> getAttendanceSummary() async {
    final uri = Uri.parse('$baseUrl/api/v1/attendance/summary');

    final response = await http.get(uri).timeout(requestTimeout);

    return _handleResponse(response);
  }

  /// Fetch role-wise attendance statistics.
  ///
  /// Endpoint:
  /// GET /api/v1/attendance/role-statistics
  Future<Map<String, dynamic>> getRoleStatistics() async {
    final uri = Uri.parse('$baseUrl/api/v1/attendance/role-statistics');

    final response = await http.get(uri).timeout(requestTimeout);

    return _handleResponse(response);
  }

  /// Fetch the latest attendance session.
  ///
  /// Endpoint:
  /// GET /api/v1/attendance/latest
  Future<Map<String, dynamic>> getLatestAttendance() async {
    final uri = Uri.parse('$baseUrl/api/v1/attendance/latest');

    final response = await http.get(uri).timeout(requestTimeout);

    return _handleResponse(response);
  }

  /// Fetch one specific attendance session.
  ///
  /// Endpoint:
  /// GET /api/v1/attendance/{sessionId}
  Future<Map<String, dynamic>> getAttendanceSession(String sessionId) async {
    final uri = Uri.parse('$baseUrl/api/v1/attendance/$sessionId');

    final response = await http.get(uri).timeout(requestTimeout);

    return _handleResponse(response);
  }

  /// Fetch role statistics for one specific session.
  ///
  /// Endpoint:
  /// GET /api/v1/attendance/{sessionId}/role-statistics
  Future<Map<String, dynamic>> getSessionRoleStatistics(
    String sessionId,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/api/v1/attendance/'
      '$sessionId/role-statistics',
    );

    final response = await http.get(uri).timeout(requestTimeout);

    return _handleResponse(response);
  }

  /// Check whether the AI backend is running.
  ///
  /// Endpoint:
  /// GET /health
  Future<bool> isBackendHealthy() async {
    try {
      final uri = Uri.parse('$baseUrl/health');

      final response = await http.get(uri).timeout(requestTimeout);

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body);

      return data is Map && data['status'] == 'healthy';
    } catch (_) {
      return false;
    }
  }

  /// Handle common HTTP API responses.
  Map<String, dynamic> _handleResponse(http.Response response) {
    final dynamic decodedBody;

    try {
      decodedBody = jsonDecode(response.body);
    } catch (_) {
      throw AiAttendanceApiException(
        'The AI server returned invalid JSON.',
        response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      }

      throw AiAttendanceApiException(
        'The AI server returned an unexpected response.',
        response.statusCode,
      );
    }

    String message = 'AI API request failed.';

    if (decodedBody is Map && decodedBody['detail'] != null) {
      message = decodedBody['detail'].toString();
    }

    throw AiAttendanceApiException(message, response.statusCode);
  }
}

/// Exception thrown when the Sentinal AI API
/// returns an error.
class AiAttendanceApiException implements Exception {
  final String message;
  final int statusCode;

  const AiAttendanceApiException(this.message, this.statusCode);

  @override
  String toString() {
    return 'AiAttendanceApiException: '
        '$message (HTTP $statusCode)';
  }
}
