import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/delivery.dart';
import '../models/meal.dart';
// import 'package:flutter/foundation.dart';


class ApiService {
  static const _baseUrl = 'http://10.0.2.2:8000/api';

  /// POST /delivery/get-deliveries  Body: { "day": "YYYY-MM-DD" }
  static Future<List<Delivery>> fetchDeliveriesByDay(String day) async {
    final uri = Uri.parse('$_baseUrl/delivery/get-deliveries');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'day': day}),
    );

    // ─── DEBUG: Log raw response ───────────────────────────────
    
    // debugPrint('BODY: ${response.body}');
    // ────────────────────────────────────────────────────────────

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      // extract the array under `data`
      final List<dynamic> dataList = decoded['data'] as List<dynamic>;

      return dataList
          .map((json) => Delivery.fromJson(json as Map<String, dynamic>))
          .toList(growable: false);
    } else if (response.statusCode == 404) {
      // no deliveries found
      return [];
    } else {
      throw Exception(
          'Failed to load deliveries for $day (status ${response.statusCode})');
    }
  }

  /// GET /delivery/{deliveryId}/meals
  /// returns { status:200, data: [ {…meal…}, … ] }
  static Future<List<Meal>> fetchMealsByDeliveryId(String deliveryId) async {
    final uri = Uri.parse('$_baseUrl/delivery/get-meals/$deliveryId');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> dataList = decoded['data'] as List<dynamic>;
      return dataList
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList(growable: false);
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception(
          'Failed to load meals for delivery $deliveryId (status ${response.statusCode})');
    }
  }

  static Future<Delivery> updateDeliveryDateTime({
  required String deliveryId,
  required String day,
  required String time,
}) async {
  final uri = Uri.parse('$_baseUrl/delivery/reschedule-delivery/$deliveryId');
  final response = await http.put(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'day': day, 'time': time}),
  );

  // Debug
  // print('PUT $uri → ${response.statusCode}');
  // print('BODY: ${response.body}');

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    // Try to pull out the payload in various forms:
    dynamic raw = decoded;
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      raw = decoded['data'];
    }

    // If it’s a JSON string, decode it again:
    Map<String, dynamic> jsonMap;
    if (raw is String) {
      jsonMap = jsonDecode(raw) as Map<String, dynamic>;
    } else {
      jsonMap = raw as Map<String, dynamic>;
    }

    return Delivery.fromJson(jsonMap);
  } else {
    throw Exception(
      'Failed to update delivery (status ${response.statusCode})'
    );
  }
}

}



