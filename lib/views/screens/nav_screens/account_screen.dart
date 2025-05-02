import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/inner_screens/order_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Center(
            child: TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return OrderScreen();
              }));
            },
            child: const Text('Đơn hàng của tôi'),
        )),
    );
  }
}
