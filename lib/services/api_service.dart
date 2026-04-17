// ============================================================
// services/api_service.dart  –  HTTP Client for Node.js Backend
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../models/food_item_model.dart';
import '../models/request_model.dart';

class ApiService {
  // ─── Singleton ───────────────────────────────────────────────
  ApiService._();
  static final ApiService instance = ApiService._();

  // ─── Base URL – change to your server IP in production ───────
  static const String _baseUrl = 'https://foodloop-production-9c9e.up.railway.app/api';
static const String _baseHost = 'https://foodloop-production-9c9e.up.railway.app';

  // ─── For Android emulator, use: http://10.0.2.2:4000
  // ─── For physical device, use your machine's IP: http://192.168.x.x:4000

  /// Converts a relative photo path (e.g. '/uploads/foo.jpg') returned by
  /// the backend into a fully-qualified URL that the browser can fetch.
  static String? resolvePhotoUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return '$_baseHost${raw.startsWith('/') ? raw : '/$raw'}';
  }

  // ─── Helpers ─────────────────────────────────────────────────
  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<dynamic> _get(String path, {String? token}) async {
    final resp = await http.get(Uri.parse('$_baseUrl$path'), headers: _headers(token));
    _checkStatus(resp);
    return jsonDecode(resp.body);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body, {String? token}) async {
    final resp = await http.post(Uri.parse('$_baseUrl$path'), headers: _headers(token), body: jsonEncode(body));
    _checkStatus(resp);
    return jsonDecode(resp.body);
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body, {String? token}) async {
    final resp = await http.put(Uri.parse('$_baseUrl$path'), headers: _headers(token), body: jsonEncode(body));
    _checkStatus(resp);
    return jsonDecode(resp.body);
  }

  Future<dynamic> _delete(String path, {String? token}) async {
    final resp = await http.delete(Uri.parse('$_baseUrl$path'), headers: _headers(token));
    _checkStatus(resp);
    return jsonDecode(resp.body);
  }

  void _checkStatus(http.Response resp) {
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final body = jsonDecode(resp.body);
      throw Exception(body['message'] ?? 'Request failed: ${resp.statusCode}');
    }
  }

  // ─── Auth ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final data = await _post('/auth/signin', {'email': email, 'password': password}) as Map<String, dynamic>;
    return {
      'user':  UserModel.fromJson(data['user'] as Map<String, dynamic>),
      'token': data['token'],
    };
  }

  Future<Map<String, dynamic>> signUp(String email, String password, String name) async {
    final data = await _post('/auth/signup', {'email': email, 'password': password, 'name': name}) as Map<String, dynamic>;
    return {
      'user':  UserModel.fromJson(data['user'] as Map<String, dynamic>),
      'token': data['token'],
    };
  }

  Future<UserModel> getMe(String token) async {
    final data = await _get('/auth/me', token: token) as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> changePassword(String currentPassword, String newPassword, String token) async {
    await _post('/auth/change-password', {'currentPassword': currentPassword, 'newPassword': newPassword}, token: token);
  }

  Future<void> updateUserRole(String userId, String role, String token) async {
    await _put('/users/$userId', {'role': role}, token: token);
  }

  // ─── Food Items ──────────────────────────────────────────────
  Future<List<FoodItemModel>> getFoodItems({
    String? token,
    double? lat,
    double? lng,
    double? radiusKm,
    String? category,
    String? status,
  }) async {
    final params = <String, String>{
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
      if (radiusKm != null) 'radius': radiusKm.toString(),
      if (category != null) 'category': category,
      if (status != null) 'status': status,
    };
    final query = params.isNotEmpty ? '?${Uri(queryParameters: params).query}' : '';
    final data = await _get('/food$query', token: token) as List;
    return data.map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FoodItemModel> getFoodItem(String id, {String? token}) async {
    final data = await _get('/food/$id', token: token) as Map<String, dynamic>;
    return FoodItemModel.fromJson(data);
  }

  Future<FoodItemModel> postFoodItem(Map<String, dynamic> body, String token, {Uint8List? imageBytes, String? imageFilename}) async {
    if (imageBytes != null) {
      final req = http.MultipartRequest('POST', Uri.parse('$_baseUrl/food'));
      req.headers['Authorization'] = 'Bearer $token';
      
      body.forEach((key, value) {
        req.fields[key] = value.toString();
      });
      
      MediaType? mediaType;
      final fname = imageFilename ?? 'upload.jpg';
      final ext = fname.split('.').last.toLowerCase();
      if (ext == 'png') mediaType = MediaType('image', 'png');
      else if (ext == 'webp') mediaType = MediaType('image', 'webp');
      else mediaType = MediaType('image', 'jpeg');
      
      req.files.add(http.MultipartFile.fromBytes(
        'photo', 
        imageBytes, 
        filename: fname,
        contentType: mediaType,
      ));
      
      final resp = await req.send();
      final respStr = await resp.stream.bytesToString();
      
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        try {
          final b = jsonDecode(respStr);
          throw Exception(b['message'] ?? 'Request failed: ${resp.statusCode}');
        } catch (_) {
          throw Exception('Request failed: ${resp.statusCode} - $respStr');
        }
      }
      return FoodItemModel.fromJson(jsonDecode(respStr) as Map<String, dynamic>);
    } else {
      final data = await _post('/food', body, token: token) as Map<String, dynamic>;
      return FoodItemModel.fromJson(data);
    }
  }

  Future<void> deleteFoodItem(String id, String token) async {
    await _delete('/food/$id', token: token);
  }

  /// Marks a food item as 'completed' — removes it from active listings
  /// without deleting the record (preserves history).
  Future<void> completeFoodItem(String foodId, String token) async {
    await _put('/food/$foodId/status', {'status': 'completed'}, token: token);
  }

  Future<List<FoodItemModel>> getMyFoodItems(String token) async {
    final data = await _get('/food/mine', token: token) as List;
    return data.map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── Requests ────────────────────────────────────────────────
  Future<RequestModel> createRequest(String foodId, String token) async {
    // Convert foodId to number
    final foodIdNum = int.tryParse(foodId) ?? 0;
    final data = await _post('/requests', {'food_id': foodIdNum}, token: token) as Map<String, dynamic>;
    return RequestModel.fromJson(data);
  }

  Future<List<RequestModel>> getGiverRequests(String token) async {
    final data = await _get('/requests/giver', token: token) as List;
    return data.map((e) => RequestModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<RequestModel>> getTakerRequests(String token) async {
    final data = await _get('/requests/taker', token: token) as List;
    return data.map((e) => RequestModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RequestModel> updateRequestStatus(String id, String status, String token) async {
    final data = await _put('/requests/$id', {'status': status}, token: token) as Map<String, dynamic>;
    return RequestModel.fromJson(data);
  }

  // ─── Reviews ─────────────────────────────────────────────────
  Future<void> postReview(String requestId, int rating, String comment, String token) async {
    final reqIdNum = int.tryParse(requestId) ?? 0;
    await _post('/reviews', {'request_id': reqIdNum, 'rating': rating, 'comment': comment}, token: token);
  }

  Future<List<Map<String, dynamic>>> getGiverReviews(String giverId) async {
    final data = await _get('/reviews/user/$giverId') as List;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}