import 'package:flutter/material.dart';
import '../models/CurrentOrderModel.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onStart;
  final VoidCallback? onCancel;
  final bool isStarted;

  const OrderCard({
    Key? key,
    required this.order,
    this.onStart,
    this.onCancel,
    this.isStarted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Status: ${order.status}'),
            if (order.location.isNotEmpty) Text('Location: ${order.location}'),
            if (order.duration.isNotEmpty) Text('Duration: ${order.duration}'),
            if (order.cancelReason.isNotEmpty)
              Text('Cancel Reason: ${order.cancelReason}'),
            const SizedBox(height: 12),
            Row(
              children: [
                if (onStart != null && !isStarted)
                  ElevatedButton(
                    onPressed: onStart,
                    child: const Text('Start Order'),
                  ),
                if (onCancel != null && !isStarted) const SizedBox(width: 8),
                if (onCancel != null && !isStarted)
                  OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                if (isStarted)
                  const Chip(
                    label: Text('Order Started'),
                    backgroundColor: Colors.greenAccent,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
