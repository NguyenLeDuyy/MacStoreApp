// import 'package:flutter/cupertino.dart';
//
// class BuyersScreen extends StatelessWidget{
//   static const String id='buyer_Screen';
//
//   const BuyersScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Center(
//       child: Text('Buyers Screen'),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyersScreen extends StatelessWidget {
  static const String id = 'buyer_Screen';

  const BuyersScreen({super.key});

  Future<List<Buyer>> fetchBuyers() async {
    try {
      final response = await Supabase.instance.client
          .from('buyers')
          .select()
          .order('created_at', ascending: false);

      print('Buyers response: $response');

      final List data = response as List;
      return data.map((json) => Buyer.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching buyers: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buyers Screen"),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Buyer>>(
        future: fetchBuyers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final buyers = snapshot.data ?? [];

          if (buyers.isEmpty) {
            return const Center(child: Text('No buyers found.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('City', style: TextStyle(fontWeight: FontWeight.bold))), // Changed here
                DataColumn(label: Text('Created At', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: buyers.map((buyer) {
                return DataRow(cells: [
                  DataCell(Text(buyer.fullName)),
                  DataCell(Text(buyer.email)),
                  DataCell(Text(buyer.city.isNotEmpty ? buyer.city : 'None')), // Changed here
                  DataCell(Text(buyer.createdAt.split('T').first)),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class Buyer {
  final String uid;
  final String fullName;
  final String email;
  final String city;
  final String createdAt;

  Buyer({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.city,
    required this.createdAt,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      uid: json['uid'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      city: (json['city'] ?? '').toString().trim(), // Add city with default
      createdAt: json['created_at'],
    );
  }
}


