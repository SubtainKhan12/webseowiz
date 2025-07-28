class OrderResponse {
  final int statusCode;
  final OrderData data;
  final String message;
  final bool success;

  OrderResponse({
    required this.statusCode,
    required this.data,
    required this.message,
    required this.success,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      statusCode: json['statusCode'],
      data: OrderData.fromJson(json['data']),
      message: json['message'],
      success: json['success'],
    );
  }
}

class OrderData {
  final Order? startedOrder;
  final List<Order> currentOrders;
  final bool hasStartedOrder;

  OrderData({
    this.startedOrder,
    required this.currentOrders,
    required this.hasStartedOrder,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      startedOrder:
      json['startedOrder'] != null ? Order.fromJson(json['startedOrder']) : null,
      currentOrders:
      List<Order>.from(json['currentOrders'].map((x) => Order.fromJson(x))),
      hasStartedOrder: json['hasStartedOrder'],
    );
  }
}

class Order {
  final String id;
  final String location;
  final String duration;
  final String orderNumber;
  final Client client;
  final User agent;
  final String admin;
  final User? commercialist;
  final User rider;
  final List<ProductItem> products;
  final String status;
  final int totalAmount;
  final String paymentMethod;
  final String notes;
  final String bookedVia;
  final double distanceInKm;
  final int travelTimeInMinutes;
  final String cancelReason;
  final List<StatusHistory> statusHistory;
  final List<dynamic> returns;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.location,
    required this.duration,
    required this.orderNumber,
    required this.client,
    required this.agent,
    required this.admin,
    this.commercialist,
    required this.rider,
    required this.products,
    required this.status,
    required this.totalAmount,
    required this.paymentMethod,
    required this.notes,
    required this.bookedVia,
    required this.distanceInKm,
    required this.travelTimeInMinutes,
    required this.cancelReason,
    required this.statusHistory,
    required this.returns,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      location: json['location'] is String ? json['location'] : '',
      duration: json['duration'] ?? '',
      orderNumber: json['orderNumber'],
      client: Client.fromJson(json['client']),
      agent: User.fromJson(json['agent']),
      admin: json['admin'],
      commercialist: json['commercialist'] != null
          ? User.fromJson(json['commercialist'])
          : null,
      rider: User.fromJson(json['rider']),
      products: List<ProductItem>.from(
          json['products'].map((x) => ProductItem.fromJson(x))),
      status: json['status'],
      totalAmount: json['totalAmount'],
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
      bookedVia: json['bookedVia'],
      distanceInKm: (json['distanceInKm'] ?? 0).toDouble(),
      travelTimeInMinutes: json['travelTimeInMinutes'] ?? 0,
      cancelReason: json['cancelReason'] ?? '',
      statusHistory: List<StatusHistory>.from(
          json['statusHistory'].map((x) => StatusHistory.fromJson(x))),
      returns: json['returns'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Client {
  final String id;
  final String name;
  final List<String> phone;
  final String address;
  final String city;
  final String floor;
  final String neighborhood;
  final String type;
  final String notes;
  final GeoLocation location;
  final String createdBy;
  final int missingItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.floor,
    required this.neighborhood,
    required this.type,
    required this.notes,
    required this.location,
    required this.createdBy,
    required this.missingItems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['_id'],
      name: json['name'],
      phone: List<String>.from(json['phone']),
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      floor: json['floor'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      type: json['type'],
      notes: json['notes'],
      location: GeoLocation.fromJson(json['location']),
      createdBy: json['createdBy'],
      missingItems: json['missingItems'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class GeoLocation {
  final double latitude;
  final double longitude;

  GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}

class User {
  final String id;
  final String username;

  User({
    required this.id,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
    );
  }
}

class ProductItem {
  final Product product;
  final int quantity;
  final int price;
  final String id;

  ProductItem({
    required this.product,
    required this.quantity,
    required this.price,
    required this.id,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      price: json['price'],
      id: json['_id'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final int price;
  final String category;
  final String sku;
  final List<dynamic> images;
  final bool returnable;
  final bool safetyApproved;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int calculatedCurrentPrice;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.sku,
    required this.images,
    required this.returnable,
    required this.safetyApproved,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.calculatedCurrentPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      category: json['category'],
      sku: json['sku'],
      images: json['images'],
      returnable: json['returnable'],
      safetyApproved: json['safetyApproved'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      calculatedCurrentPrice: json['calculatedCurrentPrice'],
    );
  }
}

class StatusHistory {
  final String status;
  final DateTime timestamp;
  final User by;
  final String id;

  StatusHistory({
    required this.status,
    required this.timestamp,
    required this.by,
    required this.id,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      by: User.fromJson(json['by']),
      id: json['_id'],
    );
  }
}
