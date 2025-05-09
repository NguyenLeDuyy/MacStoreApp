import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderListWidget extends StatefulWidget {
  const OrderListWidget({super.key});

  @override
  _OrderListWidgetState createState() => _OrderListWidgetState();
}

class _OrderListWidgetState extends State<OrderListWidget> {
  late Stream<List<Map<String, dynamic>>> _ordersStream;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _ordersStream = Supabase.instance.client
        .from('orders')
        .stream(primaryKey: ['id']);
    _ordersStream.listen((data) {
      setState(() {
        _orders = data;
      });
    });
  }

  Future<void> _updateOrder(Map<String, dynamic> orderData, bool delivered) async {
    final orderId = orderData['id'];
    if (orderId != null) {
      await Supabase.instance.client
          .from('orders')
          .update({
        'delivered': delivered,
        'processing': false,
        if (delivered)
          'deliveriedCount': (orderData['deliveriedCount'] ?? 0) + 1,
      })
          .eq('id', orderId);
    }
  }

  Widget orderCell(Widget child, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _orders.map((orderData) {
        return Column(
          children: [
            Row(
              children: [
                // Image
                orderCell(
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        orderData['productImage'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  ),
                  1,
                ),

                // Full Name
                orderCell(
                  Text(
                    orderData['fullName'] ?? 'No Name',
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  2,
                ),

                // Address
                orderCell(
                  Text(
                    '${orderData['State'] ?? ''}, ${orderData['locality'] ?? ''}',
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  2,
                ),

                // Action (Mark Delivered)
                orderCell(
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orderData['delivered'] == true
                          ? Colors.green // Delivered -> Green
                          : const Color(0xFF3C55EF), // Not Delivered -> Blue
                    ),
                    onPressed: () => _updateOrder(orderData, true),
                    child: Text(
                      orderData['delivered'] == true
                          ? 'Delivered'
                          : 'Mark Delivered',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  1,
                ),


                // Reject (Cancel)
                orderCell(
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _updateOrder(orderData, false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  1,
                ),
              ],
            ),
            // Divider line for each row
            const Divider(
              color: Colors.black,
              thickness: 1,
            ),
          ],
        );
      }).toList(),
    );
  }
}
