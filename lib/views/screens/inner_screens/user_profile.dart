import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final SupabaseClient _client = Supabase.instance.client;

  /// Lấy thông tin người dùng hiện tại từ bảng "buyers"
  Future<Map<String, dynamic>?> fetchBuyerProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('buyers')
        .select('fullName, profileImage, city')
        .eq('uid', user.id)
        .maybeSingle();

    return response;
  }
}
