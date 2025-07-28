// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/CancleOrderModel.dart';
import '../models/CurrentOrderModel.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://152.53.82.172:4000/api/v1';

  Future<LoginUser> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'requestFrom': 'mobile',
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return LoginUser(email: email, accessToken: data['data']['accessToken']);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<OrderResponse> getCurrentOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/delivery-riders/current-orders'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return OrderResponse.fromJson(data);
    } else {
      throw Exception('Failed to fetch current orders');
    }
  }

  Future<List<Order>> getOnHoldOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/delivery-riders/on-hold-orders'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch on-hold orders');
    }
  }

  // services/api_service.dart
  Future<CancelOrderResponse> getCancelledOrders(
      String token,
      int limit,
      int page,
      ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/delivery-riders/cancelled-orders?limit=$limit&page=$page',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return CancelOrderResponse.fromJson(data);
    } else {
      throw Exception('Failed to fetch cancelled orders');
    }
  }

  Future<void> patchOrderStatus({
    required String token,
    required String orderId,
    required String status,
    String cancelReason = '',
    String location = '',
    String duration = '',
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
        'cancelReason': cancelReason,
        'location': location,
        'duration': duration,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }
}