// state/orders_provider.dart
import 'package:flutter/foundation.dart';
import '../models/CurrentOrderModel.dart';
import '../services/api_service.dart';


class OrdersProvider with ChangeNotifier {
  List<Order> _currentOrders = [];
  List<Order> _cancelledOrders = [];
  List<Order> _onHoldOrders = [];
  Order? _startedOrder;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _error = '';
  int _cancelledPage = 1;
  bool _hasMoreCancelled = true;
  final ApiService _apiService = ApiService();
  static const int pageSize = 10;

  List<Order> get currentOrders => List.unmodifiable(_currentOrders);
  List<Order> get cancelledOrders => List.unmodifiable(_cancelledOrders);
  List<Order> get onHoldOrders => List.unmodifiable(_onHoldOrders);
  Order? get startedOrder => _startedOrder;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get error => _error;
  bool get hasMoreCancelled => _hasMoreCancelled;

  Future<void> fetchCurrentOrders(String token) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final orderResponse = await _apiService.getCurrentOrders(token);

      _currentOrders = orderResponse.data.currentOrders;
      _startedOrder = orderResponse.data.startedOrder;
      _error = '';
    } catch (e) {
      _error = 'Failed to fetch current orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOnHoldOrders(String token) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final orders = await _apiService.getOnHoldOrders(token);

      _onHoldOrders = orders;
      _error = '';
    } catch (e) {
      _error = 'Failed to fetch on-hold orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCancelledOrders(
      String token, {
        bool loadMore = false,
      }) async {
    if (loadMore && (!_hasMoreCancelled || _isLoadingMore)) return;
    if (!loadMore && _isLoading) return;

    try {
      _isLoading = !loadMore;
      _isLoadingMore = loadMore;
      _error = '';
      notifyListeners();

      final page = loadMore ? _cancelledPage + 1 : 1;
      final response = await _apiService.getCancelledOrders(
        token,
        pageSize,
        page,
      );

      if (response.data.orders.isEmpty && !loadMore) {
        // Handle empty response on first load
        _cancelledOrders = [];
        _hasMoreCancelled = false;
        return;
      }

      if (loadMore) {
        _cancelledOrders.addAll(response.data.orders);
      } else {
        _cancelledOrders = response.data.orders;
      }

      _cancelledPage = page;
      _hasMoreCancelled = response.data.hasMore;
    } catch (e) {
      _error = 'Failed to fetch cancelled orders: ${e.toString()}';
      if (e.toString().contains('Null')) {
        _error = 'Data format error: Some fields were missing in the response';
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> startOrder(
      String token,
      String orderId,
      String location,
      String duration,
      ) async {
    if (_isLoading) return;


    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _apiService.patchOrderStatus(
        token: token,
        orderId: orderId,
        status: 'Order Started',
        location: location,
        duration: duration,
      );

      await fetchCurrentOrders(token);
    } catch (e) {
      _error = 'Failed to start order: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String token, String orderId, String reason) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _apiService.patchOrderStatus(
        token: token,
        orderId: orderId,
        status: 'Cancelled',
        cancelReason: reason,
      );

      await fetchCurrentOrders(token);
      await fetchCancelledOrders(token, loadMore: false);
    } catch (e) {
      _error = 'Failed to cancel order: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrors() {
    _error = '';
    notifyListeners();
  }
}