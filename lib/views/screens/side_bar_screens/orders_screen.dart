import 'package:app_web/views/screens/side_bar_screens/widgets/order_list_widget.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  static const String id = 'orders_screen';
  const OrdersScreen({super.key});

  Widget rowHeader(int flex, String text) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          //color: const Color(0xFF3C55EF),
          //border: Border.all(color: Colors.grey.shade700),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(bottom: 10),
            child: const Text(
              'Manage Orders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Row(
            children: [
              rowHeader(1, 'Image'),
              rowHeader(2, 'Full Name'),
              rowHeader(2, 'Address'),
              rowHeader(1, 'Action'),
              rowHeader(1, 'Reject'),
            ],
          ),
          const SizedBox(height: 4),
          const OrderListWidget(),
        ],
      ),
    );
  }
}
