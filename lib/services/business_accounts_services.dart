// services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/business_accounts.dart';

class BusinessAccountsServices {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<BusinessAccount>> getBusinessAccounts() async {
    try {
      final response = await _client.from('business_accounts').select();

      if (response == null) {
        // Xử lý trường hợp không có dữ liệu hoặc lỗi null response
        print('Error fetching business accounts: Response is null');
        return [];
      }

      // Supabase trả về List<Map<String, dynamic>>
      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((json) => BusinessAccount.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // Xử lý lỗi một cách cẩn thận hơn trong ứng dụng thực tế
      print('Error fetching business accounts: $e');
      throw Exception('Failed to load business accounts: $e');
    }
  }

  // Thêm các hàm khác ở đây (ví dụ: getBusinessAccountById, updateBusinessAccountStatus, etc.)
  // Ví dụ: cập nhật trạng thái vendor
  Future<void> updateVendorStatus(String vendorId, String newStatus) async {
    try {
      await _client
          .from('business_accounts')
          .update({'status': newStatus, 'reviewed_at': DateTime.now().toIso8601String()})
          .eq('id', vendorId);
    } catch (e) {
      print('Error updating vendor status: $e');
      throw Exception('Failed to update vendor status: $e');
    }
  }

  // Ví dụ: lấy thông tin chi tiết một vendor
  Future<BusinessAccount?> getBusinessAccountById(String vendorId) async {
    try {
      final response = await _client
          .from('business_accounts')
          .select()
          .eq('id', vendorId)
          .single(); // Sử dụng .single() nếu bạn mong đợi chỉ một kết quả

      if (response == null) {
        print('Vendor not found with id: $vendorId');
        return null;
      }
      return BusinessAccount.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching business account by id: $e');
      throw Exception('Failed to load business account: $e');
    }
  }
}