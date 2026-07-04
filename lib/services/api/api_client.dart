// lib/services/api/api_client.dart
// HTTP client abstraction – ready for backend integration

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/env.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  final _client = http.Client();
  String? _authToken;

  void setAuthToken(String token) => _authToken = token;
  void clearAuthToken() => _authToken = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Uri _buildUri(String path, [Map<String, dynamic>? params]) {
    final uri = Uri.parse('${Env.apiBaseUrl}$path');
    if (params == null) return uri;
    return uri.replace(
      queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _client
          .get(_buildUri(path, params), headers: _headers)
          .timeout(Duration(milliseconds: Env.connectTimeoutMs));
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client
          .post(
            _buildUri(path),
            headers: _headers,
            body: jsonEncode(body ?? {}),
          )
          .timeout(Duration(milliseconds: Env.connectTimeoutMs));
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client
          .put(
            _buildUri(path),
            headers: _headers,
            body: jsonEncode(body ?? {}),
          )
          .timeout(Duration(milliseconds: Env.connectTimeoutMs));
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _client
          .delete(_buildUri(path), headers: _headers)
          .timeout(Duration(milliseconds: Env.connectTimeoutMs));
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      body['message'] ?? 'Server error',
      statusCode: response.statusCode,
    );
  }

  void dispose() => _client.close();
}
