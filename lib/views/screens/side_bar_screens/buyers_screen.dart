import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';


class BuyersScreen extends StatefulWidget {
  //dùng static vì có thể dùng trực tiếp tên class để truy cập
  static const String id = 'buyer_Screen';

  const BuyersScreen({super.key});

  @override
  State<BuyersScreen> createState() => _BuyersScreenState();
}

class _BuyersScreenState extends State<BuyersScreen> {
  //biến này sẽ được khởi tạo sau, chứ không cần khởi tạo ngay khi khai báo.
  // Nhưng nó phải được gán giá trị trước khi được sử dụng
  //Future<List<Buyer>>: Đây là một giá trị bất đồng bộ (asynchronous) kiểu Future
  //kểu Future là kiểu gì?
  // =>đại diện cho một giá trị sẽ có trong tương lai
  //=>gọi một hàm mà mất thời gian để hoàn thành (ví dụ: gọi API, đọc file, đợi dữ liệu từ cơ sở dữ liệu
  late Future<List<Buyer>> _buyersFuture;

  @override
  // 1. initState() là gì?
  //    Là phương thức được gọi khi widget được tạo lần đầu tiên.
  //    Dùng để khởi tạo biến, gọi API, hoặc chuẩn bị dữ liệu.
  //    Chỉ chạy một lần duy nhất trong vòng đời widget.
  // 2. super.initState();
  //    Gọi initState() từ lớp cha (State) để đảm bảo mọi thứ hoạt động đúng.
  //    Luôn gọi đầu tiên trong initState().
  // 3. _buyersFuture = fetchBuyers();
  //    Gọi hàm fetchBuyers() (một hàm bất đồng bộ), và gán kết quả Future vào biến _buyersFuture.
  //    Sau đó, bạn sẽ dùng _buyersFuture trong FutureBuilder để hiển thị dữ liệu khi sẵn sàng.
  void initState() {
    super.initState();
    _buyersFuture = fetchBuyers();
  }

  Future<List<Buyer>> fetchBuyers() async {
    try {
      //Đợi dữ liệu trả về vì đây là thao tác bất đồng bộ
      final response = await Supabase.instance.client
          .from('buyers')
          .select()
      //Sắp xếp theo cột created_at, mới nhất lên trước (giảm dần)
          .order('created_at', ascending: false);

      //Ép kiểu response (do Supabase trả về) thành một List<dynamic>
      final List data = response as List;
      //Duyệt từng phần tử (là Map<String, dynamic>) và
      // dùng hàm fromJson() để chuyển nó thành Buyer
      return data.map((json) => Buyer.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching buyers: $e');
      return [];
    }
  }

  Future<void> deleteBuyer(String uid) async {
    try {
      // Xóa bản ghi business_account nếu tồn tại
      await Supabase.instance.client
          .from('business_accounts')
          .delete()
          .eq('user_id', uid);

      // Sau đó xóa buyer
      await Supabase.instance.client
          .from('buyers')
          .delete()
          .eq('uid', uid);

      print('Buyer and associated business account deleted: $uid');

      // Cập nhật lại danh sách sau khi xóa
      setState(() {
        _buyersFuture = fetchBuyers();
      });
    } catch (e) {
      print('Error deleting buyer or business account: $e');
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
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(buyer.createdAt))),
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
  final DateTime createdAt; // <-- dùng DateTime

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
      createdAt: DateTime.parse(json['created_at']), // <-- chuyển từ chuỗi sang DateTime
    );
  }
}

