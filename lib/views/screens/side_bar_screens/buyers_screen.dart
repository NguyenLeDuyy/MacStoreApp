import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyersScreen extends StatefulWidget {
  static const String id = 'buyer_Screen';

  const BuyersScreen({super.key});

  @override
  State<BuyersScreen> createState() => _BuyersScreenState();
}

class _BuyersScreenState extends State<BuyersScreen> {
  late Future<List<Buyer>> _buyersFuture;

  @override
  void initState() {
    super.initState();
    _buyersFuture = fetchBuyers();
  }

  Future<List<Buyer>> fetchBuyers() async {
    try {
      final response = await Supabase.instance.client
          .from('buyers')
          .select()
          .order('created_at', ascending: false);

      final List data = response as List;
      return data.map((json) => Buyer.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching buyers: $e');
      return [];
    }
  }

  Future<void> deleteBuyer(String uid) async {
    try {
      await Supabase.instance.client
          .from('buyers')
          .delete()
          .eq('uid', uid);
      print('Buyer deleted: $uid');

      // Cập nhật lại danh sách sau khi xóa
      setState(() {
        _buyersFuture = fetchBuyers();
      });
    } catch (e) {
      print('Error deleting buyer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete buyer')),
      );
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
        future: _buyersFuture,
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
                DataColumn(label: Text('City', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Created At', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: buyers.map((buyer) {
                return DataRow(cells: [
                  DataCell(Text(buyer.fullName)),
                  DataCell(Text(buyer.email)),
                  DataCell(Text(buyer.city.isNotEmpty ? buyer.city : 'None')),
                  DataCell(Text(buyer.createdAt.split('T').first)),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text('Are you sure you want to delete ${buyer.fullName}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await deleteBuyer(buyer.uid);
                        }
                      },
                    ),
                  ),
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
      city: (json['city'] ?? '').toString().trim(),
      createdAt: json['created_at'],
    );
  }
}
