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

  int? _existingReviewId;
  double _existingRating = 0;
  String _existingComment = '';

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
          .eq('productId', productId) // bây giờ đúng type
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

    // parse productId về int tương tự như trước
    final rawId = widget.orderData['productId'];
    final int productId =
        rawId is String ? int.parse(rawId) : (rawId is num ? rawId.toInt() : 0);

    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _hasUserReviewed = false;
        _isLoadingReviewStatus = false;
      });
      return;
    }

    try {
      final data =
          await supabase
              .from('reviews')
              .select('id, rating, comment')
              .eq('productId', productId)
              .eq('buyerId', user.id)
              .maybeSingle(); // single() nếu chắc là 1 bản ghi; or maybeSingle() nếu có thể null

      if (data != null) {
        _existingReviewId = data['id'] as int;
        _existingRating = (data['rating'] as num).toDouble();
        _existingComment = data['comment'] as String? ?? '';
        _hasUserReviewed = true;
      } else {
        _hasUserReviewed = false;
      }
    } catch (e) {
      print('Lỗi load review: $e');
      _hasUserReviewed = false;
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingReviewStatus = false;
      });
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

  Future<void> _submitReview(BuildContext dialogCtx) async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn sao.'),
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
      if (_hasUserReviewed && _existingReviewId != null) {
        // Update
        await supabase
            .from('reviews')
            .update({
              'rating': _rating,
              'comment': comment,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', _existingReviewId as Object);
      } else {
        // Insert mới
        final rawId = widget.orderData['productId'];
        final int productId =
            rawId is String
                ? int.parse(rawId)
                : (rawId is num ? rawId.toInt() : 0);

        await supabase.from('reviews').insert({
          'orderId': widget.orderData['orderId'],
          'productId': productId,
          'buyerId': supabase.auth.currentUser!.id,
          'fullName': widget.orderData['fullName'],
          'rating': _rating,
          'comment': comment,
          'email': widget.orderData['email'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      //cập nhật dữ liệu rating, totalReivews cho table products:
      await _updateProductAggregateRating(widget.orderData['productId']);



      // Thông báo thành công
      Navigator.of(dialogCtx).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _hasUserReviewed
                ? 'Cập nhật đánh giá thành công!'
                : 'Cảm ơn bạn đã đánh giá!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Reload lại trạng thái và dữ liệu review
      await _checkIfUserHasReviewed();
    } catch (e) {
      Navigator.of(dialogCtx).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi gửi đánh giá: $e'),
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
    // Pre-fill
    _rating = _hasUserReviewed ? _existingRating : 0;
    _reviewController.text = _hasUserReviewed ? _existingComment : '';
    _isSubmittingReview = false;

    showDialog(
      context: context,
      barrierDismissible: !_isSubmittingReview,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDialogState) => AlertDialog(
                  title: const Text('Đánh giá sản phẩm'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemBuilder:
                            (_, __) =>
                                const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (val) {
                          setDialogState(() => _rating = val);
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _reviewController,
                        decoration: const InputDecoration(
                          labelText: 'Viết đánh giá (không bắt buộc)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          _isSubmittingReview
                              ? null
                              : () => Navigator.of(ctx).pop(),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed:
                          _isSubmittingReview ? null : () => _submitReview(ctx),
                      child:
                          _isSubmittingReview
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                _hasUserReviewed ? 'Cập nhật' : 'Gửi đánh giá',
                              ),
                    ),
                  ],
                ),
          ),
    );
  }

  /// Cập nhật lại aggregate trên bảng products
  Future<void> _updateProductAggregateRating(int productId) async {
    try {
      // 1) Lấy về tất cả review.rating cho productId
      final reviews = await supabase
          .from('reviews')
          .select('rating')
          .eq('productId', productId);

      final int count = reviews.length;
      double avg = 0;

      if (count > 0) {
        // Tính tổng sao
        final totalStars = reviews.fold<double>(
          0,
              (sum, item) {
            final r = item['rating'];
            return sum + ((r is num) ? r.toDouble() : 0);
          },
        );
        avg = totalStars / count;
      }

      // 2) Update vào products
      await supabase
          .from('products')
          .update({
        'rating': avg,            // cột rating trung bình
        'totalReviews': count,    // cột số lượng review
      })
          .eq('productId', productId);
        } catch (e) {
      print('Lỗi cập nhật aggregate product: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final displayPrice = currencyFormat.format(widget.orderData['price'] ?? 0);
    final orderedAtString = widget.orderData['created_at'] as String?;
    final orderedDate =
        orderedAtString != null ? DateTime.parse(orderedAtString) : null;
    final displayDate =
        orderedDate != null
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.receipt_long_outlined,
                    'Mã đơn hàng:',
                    displayOrderId,
                    isBoldValue: true,
                  ),
                  const Divider(height: 16),
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    'Ngày đặt:',
                    displayDate,
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Trạng thái: ',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      Chip(
                        label: Text(
                          statusInfo['text'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin sản phẩm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                          loadingBuilder:
                              (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: CupertinoActivityIndicator(),
                                        ),
                                      ),
                          errorBuilder:
                              (context, _, __) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade100,
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.orderData['productName'] ?? 'N/A',
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.orderData['category'] ?? 'N/A',
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Số lượng: ${widget.orderData['quantity'] ?? 1} - Size: ${widget.orderData['size'] ?? 'N/A'}',
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              displayPrice,
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin giao hàng',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    Icons.person_outline,
                    'Người nhận:',
                    widget.orderData['fullName'] ?? 'N/A',
                  ),
                  const Divider(height: 16, indent: 30),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Địa chỉ:',
                    _formatAddress(),
                  ),
                  const Divider(height: 16, indent: 30),
                  _buildInfoRow(
                    Icons.email_outlined,
                    'Email:',
                    widget.orderData['email'] ?? 'N/A',
                  ),

                  // Loading trạng thái review
                  if (_isLoadingReviewStatus &&
                      widget.orderData['delivered'] == true)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // Nút Viết đánh giá
                  // --- Nút Viết đánh giá (luôn hiện nếu delivered) ---
                  if (widget.orderData['delivered'] == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: OutlinedButton.icon(
                          icon: const Icon(
                            Icons.rate_review_outlined,
                            size: 18,
                          ),
                          label: Text(
                            _hasUserReviewed
                                ? 'Chỉnh sửa đánh giá'
                                : 'Viết đánh giá',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                            foregroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed:
                              _isLoadingReviewStatus
                                  ? null
                                  : _showReviewDialog, // luôn mở dialog nhập/sửa
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isBoldValue = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight:
                        isBoldValue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
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
