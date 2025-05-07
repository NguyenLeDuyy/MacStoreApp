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
    _ordersStream = Supabase.instance.client.from('orders').stream(primaryKey: ['id']);
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
        if (delivered) 'deliveriedCount': (orderData['deliveriedCount'] ?? 0) + 1,
      })
          .eq('id', orderId);

      setState(() {
        orderData['delivered'] = delivered;
        orderData['processing'] = false;
        if (delivered) {
          orderData['deliveriedCount'] = (orderData['deliveriedCount'] ?? 0) + 1;
        }
      }); // Cập nhật ngay UI
    }
  }

  Widget orderDisplayData(Widget widget, int flex) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: widget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final orderData = _orders[index];
        return Row(
          children: [
            orderDisplayData(
              SizedBox(
                width: 50,
                height: 50,
                child: Image.network(orderData['productImage']),
              ),
              1,
            ),
            orderDisplayData(
              Text(
                orderData['fullName'] ?? 'No Name',
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              3,
            ),
            orderDisplayData(
              Text(
                "${orderData['State'] ?? ''} ${orderData['locality'] ?? ''}",
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              2,
            ),
            orderDisplayData(
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C55EF),
                ),
                onPressed: () => _updateOrder(orderData, true),
                child: orderData['delivered'] == true
                    ? const Text('Delivered', style: TextStyle(color: Colors.white))
                    : const Text('Mark Delivered', style: TextStyle(color: Colors.white)),
              ),
              1,
            ),
            orderDisplayData(
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => _updateOrder(orderData, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              1,
            ),
          ],
        );
      },
    );
  }
}