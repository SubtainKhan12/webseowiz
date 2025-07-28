import 'CurrentOrderModel.dart';

class CancelOrderResponse {
  final int statusCode;
  final CancelOrderData data;
  final String message;
  final bool success;

  CancelOrderResponse({
    required this.statusCode,
    required this.data,
    required this.message,
    required this.success,
  });

  factory CancelOrderResponse.fromJson(Map<String, dynamic> json) {
    try {
      return CancelOrderResponse(
        statusCode: json['statusCode'] as int? ?? 0,
        data: CancelOrderData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
        message: json['message'] as String? ?? 'No message',
        success: json['success'] as bool? ?? false,
      );
    } catch (e) {
      print('Error parsing CancelOrderResponse: $e');
      rethrow;
    }
  }
}

class CancelOrderData {
  final List<Order> orders;
  final bool hasMore;

  CancelOrderData({
    required this.orders,
    required this.hasMore,
  });

  factory CancelOrderData.fromJson(Map<String, dynamic> json) {
    try {
      return CancelOrderData(
        orders: (json['orders'] as List? ?? [])
            .map((order) => Order.fromJson(order as Map<String, dynamic>? ?? {}))
            .toList(),
        hasMore: json['hasMore'] as bool? ?? false,
      );
    } catch (e) {
      print('Error parsing CancelOrderData: $e');
      rethrow;
    }
  }
}