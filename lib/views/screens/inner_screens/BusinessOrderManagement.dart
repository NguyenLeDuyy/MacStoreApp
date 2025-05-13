import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BussinessOrderManagement extends StatefulWidget {
  const BussinessOrderManagement({Key? key}) : super(key: key);

  @override
  State<BussinessOrderManagement> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<BussinessOrderManagement> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _businessAccountId; // Lưu trữ ID của business account

  @override
  void initState() {
    super.initState();
    _initializeAndLoadOrders();
  }

  Future<void> _initializeAndLoadOrders() async {
    // Lấy businessAccountId trước
    await _fetchBusinessAccountId();
    // Sau đó load đơn hàng nếu businessAccountId tồn tại
    if (_businessAccountId != null) {
      _loadPendingOrders();
    } else {
      // Xử lý trường hợp không tìm thấy business account
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Có thể hiển thị thông báo lỗi hoặc trạng thái không có cửa hàng
        });
      }
    }
  }

  Future<void> _fetchBusinessAccountId() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final baRes = await supabase
          .from('business_accounts')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle(); // Sử dụng maybeSingle để tránh lỗi nếu không tìm thấy

      if (mounted) {
        if (baRes != null && baRes['id'] != null) {
          _businessAccountId = baRes['id'];
        } else {
          print("Không tìm thấy business account cho user: ${user.id}");
          // Xử lý trường hợp không tìm thấy, ví dụ: hiển thị thông báo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy thông tin cửa hàng. Vui lòng đăng ký cửa hàng.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print("Lỗi khi lấy business_account_id: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lấy thông tin cửa hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Future<void> _loadPendingOrders() async {
    if (_businessAccountId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _orders = []; // Đảm bảo danh sách trống nếu không có businessAccountId
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Fetch các đơn chưa giao (processing = true)
      final response = await supabase // Đổi tên biến để tránh nhầm lẫn với kiểu dữ liệu
          .from('orders')
          .select() // <--- SỬA Ở ĐÂY: Bỏ <List<Map<String, dynamic>>>
          .eq('seller_id', _businessAccountId!)
          .order('created_at', ascending: false); // Sắp xếp đơn mới nhất lên đầu (tùy chọn)

      if (mounted) {
        setState(() {
          // Supabase client trả về List<dynamic> (mỗi phần tử là Map<String, dynamic>)
          // hoặc có thể là một kiểu dữ liệu cụ thể của Supabase (PostgrestList).
          // Cần ép kiểu một cách an toàn.
          if (response is List) { // Kiểm tra nếu response là một List
            _orders = List<Map<String, dynamic>>.from(response);
          } else {
            // Xử lý trường hợp response không phải là List như mong đợi
            print("Dữ liệu trả về từ Supabase không phải là List: $response");
            _orders = []; // Đặt danh sách trống để tránh lỗi
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi khi tải đơn hàng chờ xử lý: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải đơn hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateOrderStatus(String orderId, int itemIndex, String newSelectedStatus) async {
    final bool newDeliveredStatus = newSelectedStatus == 'Đã chuyển đi';

    try {
      await supabase
          .from('orders')
          .update({
        'delivered': newDeliveredStatus,
        'processing': !newDeliveredStatus, // Nếu đã chuyển đi thì không còn processing
      })
          .eq('id', orderId);

      // Cập nhật UI bằng cách tạo danh sách mới
      if (mounted) {
        setState(() {
          // Tạo một danh sách mới không bao gồm phần tử đã được cập nhật trạng thái
          // vì màn hình này chỉ hiển thị đơn 'processing' = true
          final updatedOrders = List<Map<String, dynamic>>.from(_orders);
          updatedOrders.removeAt(itemIndex);
          _orders = updatedOrders; // Gán danh sách mới cho _orders
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đơn $orderId đã chuyển sang "$newSelectedStatus"')),
        );
      }
    } catch (e) {
      print("Lỗi cập nhật trạng thái đơn hàng: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng đơn hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _businessAccountId != null ? _loadPendingOrders : null, // Chỉ cho phép refresh nếu có businessAccountId
            tooltip: 'Tải lại danh sách',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _businessAccountId == null // Thêm kiểm tra này
          ? const Center(child: Text('Vui lòng đăng ký thông tin cửa hàng để xem đơn hàng.'))
          : _orders.isEmpty
          ? const Center(child: Text('Không có đơn chờ xử lý.'))
          : ListView.separated(
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, i) {
          final order = _orders[i];
          final createdAt = order['created_at'] != null
              ? DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.parse(order['created_at']))
              : 'Không rõ';

          final currentDropdownStatus = order['delivered'] == true
              ? 'Đã chuyển đi'
              : 'Đang xử lý';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              'Mã đơn: ${order['id']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Ngày đặt: $createdAt\n'
                  'Khách hàng: ${order['fullName'] ?? 'Không rõ'}\n'
                  'Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(order['price'] ?? 0)}',
            ),
            isThreeLine: true,
            trailing: DropdownButton<String>(
              value: currentDropdownStatus,
              items: const [
                DropdownMenuItem(
                  value: 'Đang xử lý',
                  child: Text('Đang xử lý'),
                ),
                DropdownMenuItem(
                  value: 'Đã chuyển đi',
                  child: Text('Đã chuyển đi'),
                ),
              ],
              onChanged: (newSelectedStatus) async {
                if (newSelectedStatus == null || newSelectedStatus == currentDropdownStatus) {
                  return;
                }
                await _updateOrderStatus(order['id'], i, newSelectedStatus);
              },
            ),
            onTap: () {
              print('Xem chi tiết đơn: ${order['id']}');
            },
          );
        },
      ),
    );
  }
}
