
import 'package:app_web/views/screens/side_bar_screens/widgets/order_list_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget{
  static const String id='orders_screen';
  const OrdersScreen({super.key});

  Widget rowHeader (int flex, String text) {
    flex: flex;
    return Expanded(child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3C55EF),
        border: Border.all(color: Colors.grey.shade700,),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              alignment: Alignment.topLeft,
              child: const Text(
                'Manage Orders',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          Row(
            children: [
              rowHeader(1, 'Image'),
              rowHeader(3, 'Full Name'),
              rowHeader(2, 'Address'),
              rowHeader(1, 'Action'),
              rowHeader(1, 'Reject'),
            ],
          ),

          const OrderListWidget(),
        ],
      ),
    );
  }
}