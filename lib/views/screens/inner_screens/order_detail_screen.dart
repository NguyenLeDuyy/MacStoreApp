import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  const OrderDetailScreen({super.key, required this.orderData});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmittingReview = false;

  final supabase = Supabase.instance.client;
  bool _hasUserReviewed = false;
  bool _isLoadingReviewStatus = true;

  @override
  void initState() {
    super.initState();
    _checkIfUserHasReviewed();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<bool> hasUserReviewedProduct(int productId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    try {
      final response = await supabase
          .from('reviews')
          .select('id')
          .eq('productId', productId)  // bây giờ đúng type
          .eq('buyerId', user.id)
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      print("Lỗi khi kiểm tra đánh giá: $e");
      return false;
    }
  }


  Future<void> _checkIfUserHasReviewed() async {
    if (!mounted) return;
    setState(() {
      _isLoadingReviewStatus = true;
    });

    final productId = widget.orderData['productId'];
    if (productId != null) {
      final reviewed = await hasUserReviewedProduct(productId);
      if (!mounted) return;
      setState(() {
        _hasUserReviewed = reviewed;
        _isLoadingReviewStatus = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _hasUserReviewed = false;
        _isLoadingReviewStatus = false;
      });
      print("Lỗi: Không tìm thấy productId trong orderData");
    }
  }

  Map<String, dynamic> _getStatusInfo() {
    if (widget.orderData['delivered'] == true) {
      return {'text': 'Đã giao hàng', 'color': Colors.green.shade700};
    } else if (widget.orderData['processing'] == true) {
      return {'text': 'Đang xử lý', 'color': Colors.orange.shade700};
    } else {
      return {'text': 'Đã hủy', 'color': Colors.red.shade700};
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    final comment = _reviewController.text.trim();
    try {
      await supabase.from('reviews').insert({
        'orderId': widget.orderData['orderId'],
        'productId': widget.orderData['productId'],
        'buyerId': supabase.auth.currentUser!.id,
        'fullName': widget.orderData['fullName'],
        'rating': _rating,
        'comment': comment,
        'email': widget.orderData['email'],
        'created_at': DateTime.now().toIso8601String(),
      });

      // giả lập delay nếu cần
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cảm ơn bạn đã đánh giá!'),
          backgroundColor: Colors.green,
        ),
      );
      // cập nhật lại trạng thái
      _checkIfUserHasReviewed();
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gửi đánh giá thất bại: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmittingReview = false;
      });
    }
  }

  void _showReviewDialog() {
    _rating = 0;
    _reviewController.clear();
    _isSubmittingReview = false;

    showDialog(
      context: context,
      barrierDismissible: !_isSubmittingReview,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Đánh giá sản phẩm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bạn cảm thấy sản phẩm này thế nào?'),
                const SizedBox(height: 10),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (ratingValue) {
                    setDialogState(() => _rating = ratingValue);
                    setState(() => _rating = ratingValue);
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _reviewController,
                  decoration: const InputDecoration(
                    labelText: 'Viết đánh giá của bạn (không bắt buộc)',
                    hintText: 'Chia sẻ cảm nhận của bạn...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
              _isSubmittingReview ? null : () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: _isSubmittingReview ? null : _submitReview,
              child: _isSubmittingReview
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();
    final currencyFormat =
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final displayPrice =
    currencyFormat.format(widget.orderData['price'] ?? 0);
    final orderedAtString = widget.orderData['ordered_at'] as String?;
    final orderedDate = orderedAtString != null
        ? DateTime.parse(orderedAtString)
        : null;
    final displayDate = orderedDate != null
        ? DateFormat('HH:mm dd/MM/yyyy', 'vi_VN').format(orderedDate)
        : 'N/A';
    final displayOrderId = widget.orderData['id'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại',
        ),
        title: const Text('Chi tiết đơn hàng'),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          // Thông tin chung
          Card(
            elevation: 1,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _buildInfoRow(Icons.receipt_long_outlined,
                      'Mã đơn hàng:', displayOrderId,
                      isBoldValue: true),
                  const Divider(height: 16),
                  _buildInfoRow(Icons.calendar_today_outlined,
                      'Ngày đặt:', displayDate),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          size: 18, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      const Text('Trạng thái: ',
                          style: TextStyle(
                              fontSize: 15, color: Colors.black87)),
                      Chip(
                        label: Text(
                          statusInfo['text'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        backgroundColor: statusInfo['color'],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Thông tin sản phẩm
          Card(
            elevation: 1,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thông tin sản phẩm',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.orderData['productImage'] ?? '',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade200,
                              child: const Center(
                                  child:
                                  CupertinoActivityIndicator())),
                          errorBuilder: (context, _, __) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade100,
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey.shade400)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.orderData['productName'] ?? 'N/A',
                                style: GoogleFonts.lato(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(widget.orderData['category'] ?? 'N/A',
                                style: GoogleFonts.lato(
                                    fontSize: 13, color: Colors.grey.shade700)),
                            const SizedBox(height: 4),
                            Text(
                                'Số lượng: ${widget.orderData['quantity'] ?? 1} - Size: ${widget.orderData['size'] ?? 'N/A'}',
                                style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: Colors.grey.shade700)),
                            const SizedBox(height: 6),
                            Text(displayPrice,
                                style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                    Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Thông tin giao hàng + nút đánh giá
          Card(
            elevation: 1,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thông tin giao hàng',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.person_outline, 'Người nhận:',
                      widget.orderData['fullName'] ?? 'N/A'),
                  const Divider(height: 16, indent: 30),
                  _buildInfoRow(Icons.location_on_outlined, 'Địa chỉ:',
                      _formatAddress()),
                  const Divider(height: 16, indent: 30),
                  _buildInfoRow(Icons.email_outlined, 'Email:',
                      widget.orderData['email'] ?? 'N/A'),

                  // Loading trạng thái review
                  if (_isLoadingReviewStatus &&
                      widget.orderData['delivered'] == true)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // Nút Viết đánh giá
                  if (widget.orderData['delivered'] == true &&
                      !_isLoadingReviewStatus &&
                      !_hasUserReviewed)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.rate_review_outlined,
                              size: 18),
                          label: const Text('Viết đánh giá'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                            foregroundColor:
                            Theme.of(context).primaryColor,
                          ),
                          onPressed: _showReviewDialog,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isBoldValue = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: '$label ',
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade800)),
              TextSpan(
                  text: value,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: isBoldValue
                          ? FontWeight.bold
                          : FontWeight.normal)),
            ]),
            style: const TextStyle(height: 1.4),
          ),
        ),
      ],
    );
  }

  String _formatAddress() {
    final parts = [
      widget.orderData['locality'] ?? '',
      widget.orderData['state'] ?? '',
      widget.orderData['city'] ?? '',
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }
}
