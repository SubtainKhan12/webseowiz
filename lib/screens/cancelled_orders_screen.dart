// screens/cancelled_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/CurrentOrderModel.dart';
import '../state/orders_provider.dart';
import '../state/auth_provider.dart';

class CancelledOrdersScreen extends StatefulWidget {
  const CancelledOrdersScreen({super.key});

  @override
  State<CancelledOrdersScreen> createState() => _CancelledOrdersScreenState();
}

class _CancelledOrdersScreenState extends State<CancelledOrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<OrdersProvider>(
        context,
        listen: false,
      ).fetchCancelledOrders(authProvider.user!.accessToken);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      final orderProvider = Provider.of<OrdersProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!orderProvider.isLoadingMore && orderProvider.hasMoreCancelled) {
        orderProvider.fetchCancelledOrders(
          authProvider.user!.accessToken,
          loadMore: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrdersProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancelled Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => orderProvider.fetchCancelledOrders(
                  authProvider.user!.accessToken,
                ),
          ),
        ],
      ),
      body: _buildBody(orderProvider, authProvider),
    );
  }

  Widget _buildBody(OrdersProvider orderProvider, AuthProvider authProvider) {
    if (orderProvider.isLoading && orderProvider.cancelledOrders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProvider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${orderProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () => orderProvider.fetchCancelledOrders(
                    authProvider.user!.accessToken,
                  ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await orderProvider.fetchCancelledOrders(
          authProvider.user!.accessToken,
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: orderProvider.cancelledOrders.length + 1,
        itemBuilder: (context, index) {
          if (index == orderProvider.cancelledOrders.length) {
            if (orderProvider.isLoadingMore) {
              return const Center(child: CircularProgressIndicator());
            } else if (orderProvider.hasMoreCancelled) {
              return const SizedBox.shrink(); // Let the scroll listener handle it
            } else {
              return const SizedBox.shrink();
            }
          }
          final order = orderProvider.cancelledOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Chip(
                  label: Text(
                    order.status ?? 'N/A',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Client: ${order.client.name ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (order.client.phone != 'null' &&
                order.client.phone.isNotEmpty &&
                order.client.phone[0].isNotEmpty)
              Text('Phone: ${order.client.phone.join(', ')}'),
            if (order.client.address != 'null' &&
                order.client.address.isNotEmpty)
              Text('Address: ${order.client.address}'),
            const SizedBox(height: 8),
            Text(
              'Cancelled on: ${order.updatedAt.toString()}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (order.cancelReason != 'null' && order.cancelReason.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Reason: ${order.cancelReason}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...order.products.map((product) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text('${product.quantity}x'),
                    const SizedBox(width: 8),
                    Expanded(child: Text(product.product.name ?? 'N/A')),
                    Text('Rs. ${product.price ?? 'N/A'}'),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs. ${order.totalAmount ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Payment Method: ${order.paymentMethod ?? 'N/A'}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
