import 'package:app_web/views/main_screen.dart';
import 'package:app_web/views/screens/authentication_screens/login_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/category_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/vendors_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/products_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/upload_banner.screen.dart';
import 'package:app_web/views/screens/side_bar_screens/buyers_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/orders_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/register_account.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://deldgmhsvcwtqojoffrd.supabase.co',         // Dán Project URL của bạn vào đây
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlbGRnbWhzdmN3dHFvam9mZnJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4ODI4MDQsImV4cCI6MjA1ODQ1ODgwNH0.nxOvJp_mYRx08vDMx-7JCnHX8vHAPnFGDm5BfAX0fuM', // Dán anon public key của bạn vào đây
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginScreenAdmin(),
      // initialRoute: MainScreen.id, // Bắt đầu từ màn hình chính
      // routes: {
      //   MainScreen.id: (context) => const MainScreen(),
      //   CategoryScreen.id: (context) => const CategoryScreen(),
      //   VendorsScreen.id: (context) => const VendorsScreen(),
      //   ProductsScreen.id: (context) => const ProductsScreen(),
      //   UploadBanner.id: (context) => const UploadBanner(),
      //   BuyersScreen.id: (context) => const BuyersScreen(),
      //   OrdersScreen.id: (context) => const OrdersScreen(),
      //   RegisterScreenAdmin.id: (context) => const RegisterScreenAdmin(),
      // },



    );
  }
}

