// screens/started_order_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/CurrentOrderModel.dart';
import '../state/orders_provider.dart';
import '../state/auth_provider.dart';

class StartedOrderScreen extends StatefulWidget {
  const StartedOrderScreen({super.key});

  @override
  State<StartedOrderScreen> createState() => _StartedOrderScreenState();
}

class _StartedOrderScreenState extends State<StartedOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<OrdersProvider>(context, listen: false)
          .fetchCurrentOrders(authProvider.user!.accessToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrdersProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Started Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => orderProvider.fetchCurrentOrders(authProvider.user!.accessToken),
          ),
        ],
      ),
      body: _buildBody(orderProvider),
    );
  }

  Widget _buildBody(OrdersProvider orderProvider) {
    if (orderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProvider.error.isNotEmpty) {
      return Center(child: Text(orderProvider.error));
    }

    if (orderProvider.startedOrder == null) {
      return const Center(
        child: Text('No currently started order'),
      );
    }

    return _buildOrderCard(orderProvider.startedOrder!);
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
                  order.orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Chip(
                  label: Text(
                    order.status,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Client: ${order.client.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Phone: ${order.client.phone.join(', ')}'),
            Text('Address: ${order.client.address}'),
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
                    Expanded(child: Text(product.product.name)),
                    Text('\$${product.price}'),
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
                  '\$${order.totalAmount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Payment: ${order.paymentMethod}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            if (order.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Notes: ${order.notes}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Delivery Info:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Location: ${order.location}'),
            Text('Estimated Duration: ${order.duration}'),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _completeOrder(context, order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Complete Order',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeOrder(BuildContext context, Order order) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrdersProvider>(context, listen: false);

    try {
      await orderProvider.startOrder(
        authProvider.user!.accessToken,
        order.id,
        order.location,
        order.duration,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order completed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing order: $e')),
      );
    }
  }
}