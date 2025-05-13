import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BusinessReviewManagement extends StatefulWidget {
  const BusinessReviewManagement({Key? key}) : super(key: key);

  @override
  _BusinessReviewManagementState createState() =>
      _BusinessReviewManagementState();
}

class _BusinessReviewManagementState extends State<BusinessReviewManagement> {
  final supabase = Supabase.instance.client;
  String? businessAccountId;
  bool isLoading = true;
  List<Map<String, dynamic>> reviews = [];
  double averageRating = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      // 1) Lấy businessAccountId
      final ba = await supabase
          .from('business_accounts')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle(); // Sử dụng maybeSingle để tránh lỗi nếu không tìm thấy

      if (!mounted) return; // Kiểm tra lại mounted sau await

      businessAccountId = ba?['id'] as String?;
      if (businessAccountId == null) {
        print("BusinessReviewManagement: Không tìm thấy businessAccountId cho user ${user.id}");
        setState(() => isLoading = false);
        return;
      }
      print("BusinessReviewManagement: businessAccountId = $businessAccountId");

      // 2) Load review
      await _loadReviews();
    } catch (e) {
      print("BusinessReviewManagement: Lỗi trong _init: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khởi tạo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadReviews() async {
    if (businessAccountId == null) {
      print("BusinessReviewManagement: businessAccountId is null, không thể load reviews.");
      if (mounted) {
        setState(() {
          reviews = []; // Đảm bảo reviews trống
          averageRating = 0;
          isLoading = false;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // Lấy danh sách orderId của shop
      final ordersResponse = await supabase
          .from('orders')
          .select('id')
          .eq('seller_id', businessAccountId!); // seller_id phải khớp với cột trong bảng orders

      // Kiểm tra kiểu dữ liệu trả về và xử lý
      List<String> orderIds = [];
      if (ordersResponse is List) {
        orderIds = (ordersResponse as List)
            .map((e) => e['id'] as String)
            .toList();
      } else {
        print("BusinessReviewManagement: ordersResponse không phải là List: $ordersResponse");
      }

      print("BusinessReviewManagement: orderIds của shop: $orderIds");

      // Nếu chưa có order nào thì clear luôn
      if (orderIds.isEmpty) {
        if (mounted) {
          setState(() {
            reviews = [];
            averageRating = 0;
            isLoading = false;
          });
        }
        print("BusinessReviewManagement: Không có orderIds, reviews được làm trống.");
        return;
      }

      // Tạo chuỗi IN-list: ("uuid1","uuid2",...)
      // Theo tài liệu Supabase, giá trị chuỗi trong IN list nên được đặt trong dấu ngoặc kép.
      final inListValues = orderIds.map((id) => "\"$id\"").join(',');
      final filterValue = '($inListValues)';
      print("BusinessReviewManagement: Filter value cho IN clause: $filterValue");


      // Fetch review theo orderId IN (...)
      // Đảm bảo tên cột "orderId" trong bảng "reviews" là chính xác (phân biệt chữ hoa/thường nếu có dấu ngoặc kép trong schema)
      final reviewsResponseData = await supabase
          .from('reviews')
          .select('''
            id,
            rating,
            comment,
            "fullName", 
            email,
            created_at,
            "orderId" 
          ''') // Đảm bảo "orderId" và "fullName" khớp với tên cột trong DB (có thể cần dấu ngoặc kép nếu tên cột có chữ hoa)
          .filter('orderId', 'in', filterValue) // Sử dụng filterValue đã tạo
          .order('created_at', ascending: false);

      if (!mounted) return;

      List<Map<String, dynamic>> fetchedReviewsList = [];
      if (reviewsResponseData is List) {
        fetchedReviewsList = (reviewsResponseData as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        print("BusinessReviewManagement: reviewsResponseData không phải là List: $reviewsResponseData");
      }

      print("BusinessReviewManagement: Số reviews lấy được: ${fetchedReviewsList.length}");
      if (fetchedReviewsList.isNotEmpty) {
        // In ra review đầu tiên để kiểm tra các keys
        print("BusinessReviewManagement: Dữ liệu review đầu tiên: ${fetchedReviewsList.first}");
      }


      // Tính trung bình
      double sum = 0;
      for (var r in fetchedReviewsList) {
        // Kiểm tra null cho rating trước khi ép kiểu
        final ratingValue = r['rating'];
        if (ratingValue != null) {
          sum += (ratingValue as num).toDouble();
        }
      }
      final double avg = fetchedReviewsList.isNotEmpty ? sum / fetchedReviewsList.length : 0;

      setState(() {
        reviews = fetchedReviewsList;
        averageRating = avg;
        isLoading = false;
      });
    } catch (e) {
      print("BusinessReviewManagement: Lỗi khi load reviews: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải đánh giá: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tổng đánh giá')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (businessAccountId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tổng đánh giá')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Không tìm thấy thông tin cửa hàng. Vui lòng đăng ký cửa hàng để xem đánh giá.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng đánh giá'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReviews, // Gọi hàm load reviews khi nhấn nút
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng đánh giá: ${reviews.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[600], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Danh sách
          Expanded(
            child: reviews.isEmpty
                ? const Center(child: Text('Chưa có đánh giá nào cho cửa hàng của bạn.'))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const Divider(indent: 16, endIndent: 16),
              itemBuilder: (context, i) {
                final r = reviews[i];
                // In dữ liệu của mỗi review để kiểm tra key "orderId"
                // print("Dữ liệu review tại index $i: $r");

                final date = r['created_at'] != null
                    ? DateFormat('dd/MM/yyyy – HH:mm').format(
                    DateTime.parse(r['created_at'] as String))
                    : 'Không rõ ngày';

                // Kiểm tra key "orderId" (hoặc "orderId" nếu schema của bạn dùng dấu ngoặc kép)
                final orderIdToDisplay = r['orderId'] ?? r['orderId'] ?? '—';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber[100],
                    child: Text(
                      (r['rating'] as num? ?? 0).toStringAsFixed(1), // Xử lý null cho rating
                      style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                      'Đơn hàng: $orderIdToDisplay',
                      style: const TextStyle(fontWeight: FontWeight.w500)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (r['comment'] != null && (r['comment'] as String).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                          child: Text(r['comment'] as String),
                        ),
                      Text(
                        'Người đánh giá: ${r['fullName'] ?? r['email'] ?? 'Ẩn danh'}', // Hiển thị fullName hoặc email
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  isThreeLine: (r['comment'] != null && (r['comment'] as String).isNotEmpty), // Tự động isThreeLine
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
