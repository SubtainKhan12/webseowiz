import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/CurrentOrderModel.dart';
import '../state/orders_provider.dart';
import '../state/auth_provider.dart';

class CurrentOrdersScreen extends StatefulWidget {
  const CurrentOrdersScreen({super.key});

  @override
  State<CurrentOrdersScreen> createState() => _CurrentOrdersScreenState();
}

class _CurrentOrdersScreenState extends State<CurrentOrdersScreen> {
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
        title: const Text('Current Orders'),
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

    return SingleChildScrollView(
      child: Column(
        children: [
          if (orderProvider.startedOrder != null)
            _buildOrderCard(orderProvider.startedOrder!, true),
          ...orderProvider.currentOrders
              .map((order) => _buildOrderCard(order, false))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isStarted) {
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
                  backgroundColor: isStarted ? Colors.green : Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Client: ${order.client.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Phone: ${order.client.phone.join(', ')}'),
            if (order.client.address.isNotEmpty)
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
            if (!isStarted)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _startOrder(context, order),
                      child: const Text('Start Order'),
                    ),
                    ElevatedButton(
                      onPressed: () => _cancelOrder(context, order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startOrder(BuildContext context, Order order) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrdersProvider>(context, listen: false);

    await orderProvider.startOrder(
      authProvider.user!.accessToken,
      order.id,
      'Current Location', // In a real app, get actual location
      '30 minutes', // Estimated duration
    );
  }

  void _cancelOrder(BuildContext context, Order order) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrdersProvider>(context, listen: false);

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Enter reason for cancellation'),
          onChanged: (value) {},
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Reason'); // In a real app, get the actual reason
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (reason != null) {
      await orderProvider.cancelOrder(
        authProvider.user!.accessToken,
        order.id,
        reason,
      );
    }
  }
}