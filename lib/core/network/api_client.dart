import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';
import 'api_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  /// Optional callback triggered when 401 Unauthorized occurs
  VoidCallback? onUnauthorized;

  Map<String, String> _buildHeaders({Map<String, String>? extraHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final base = ApiConstants.activeBaseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$base$cleanPath';

    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      final stringParams = queryParams.map((key, value) => MapEntry(key, value.toString()));
      return uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint, queryParams);
      return await _client.get(uri, headers: _buildHeaders(extraHeaders: headers)).timeout(ApiConstants.receiveTimeout);
    }, endpoint);
  }

  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint);
      final payload = body != null ? jsonEncode(body) : null;
      return await _client.post(uri, headers: _buildHeaders(extraHeaders: headers), body: payload).timeout(ApiConstants.receiveTimeout);
    }, endpoint);
  }

  Future<dynamic> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint);
      final payload = body != null ? jsonEncode(body) : null;
      return await _client.put(uri, headers: _buildHeaders(extraHeaders: headers), body: payload).timeout(ApiConstants.receiveTimeout);
    }, endpoint);
  }

  Future<dynamic> delete(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint);
      final payload = body != null ? jsonEncode(body) : null;
      return await _client.delete(uri, headers: _buildHeaders(extraHeaders: headers), body: payload).timeout(ApiConstants.receiveTimeout);
    }, endpoint);
  }

  /// Tests whether a given server base URL is actively responding
  Future<bool> testConnection(String candidateUrl) async {
    try {
      final sanitized = ApiConstants.sanitizeBaseUrl(candidateUrl);
      final healthUri = Uri.parse('$sanitized/health');
      final res = await _client.get(healthUri).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> _sendRequest(Future<http.Response> Function() requestFn, String endpoint) async {
    try {
      final response = await requestFn();
      return _handleResponse(response, endpoint);
    } catch (error) {
      // If network failure, attempt smart auto-failover to candidate servers (e.g. LAN IP vs localhost)
      if (error is SocketException || error is TimeoutException || error is http.ClientException) {
        final current = ApiConstants.activeBaseUrl;
        final candidates = [
          'http://${ApiConstants.defaultLanIp}:5000/api',
          'http://127.0.0.1:5000/api',
          'http://10.0.2.2:5000/api',
        ];

        for (final candidate in candidates) {
          if (candidate != current && await testConnection(candidate)) {
            if (kDebugMode) print('Auto-discovered working server: $candidate (switched from $current)');
            ApiConstants.customBaseUrl = candidate;
            await LocalStorage.saveApiBaseUrl(candidate);
            try {
              final retryResponse = await requestFn();
              return _handleResponse(retryResponse, endpoint);
            } catch (_) {
              break;
            }
          }
        }

        if (error is TimeoutException) {
          throw NetworkException(
            message: 'Request timed out connecting to ${ApiConstants.activeBaseUrl}. Please ensure your phone and computer are on the same Wi-Fi.',
          );
        }
        throw NetworkException(
          message: 'Cannot reach S3T server at [${ApiConstants.activeBaseUrl}]. Make sure Flask is running and phone is on the same Wi-Fi network.',
        );
      }

      if (error is ApiException) {
        rethrow;
      }
      if (kDebugMode) print('Unexpected API Error on [$endpoint]: $error');
      throw ApiException(message: 'An unexpected error occurred: $error');
    }
  }

  dynamic _handleResponse(http.Response response, String endpoint) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      jsonBody = null;
    }

    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (jsonBody is Map<String, dynamic>) {
        // If wrapped in standard S3T response { success: true, data: ... }
        if (jsonBody.containsKey('data')) {
          return jsonBody['data'];
        }
        return jsonBody;
      }
      return jsonBody;
    }

    // Extract error message
    String message = 'Request failed with status $statusCode';
    if (jsonBody is Map<String, dynamic>) {
      if (jsonBody.containsKey('message') && jsonBody['message'] != null) {
        message = jsonBody['message'].toString();
      } else if (jsonBody.containsKey('error') && jsonBody['error'] != null) {
        message = jsonBody['error'].toString();
      }
    }

    if (statusCode == 401) {
      if (!endpoint.contains('/auth/login')) {
        onUnauthorized?.call();
      }
      throw UnauthorizedException(message: message);
    }

    if (statusCode == 404) {
      throw NotFoundException(message: message);
    }

    if (statusCode >= 500) {
      throw ServerException(message: message);
    }

    throw ApiException(message: message, statusCode: statusCode, data: jsonBody);
  }
}
