import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BannerController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<String>> getBannerUrl(){
    // THAY THẾ 'id' BẰNG TÊN CỘT KHÓA CHÍNH THỰC TẾ (ví dụ: 'uid' nếu bạn đặt là uid)
    const String primaryKeyColumn = 'id';

    // 1. Lấy stream từ Supabase
    final stream = _supabase
        .from("banners")
        .stream(primaryKey: [primaryKeyColumn])
        .order('create_at', ascending: true);

    // 2. Chuyển đổi (map) stream kết quả
    // Stream trả về List<Map<String, dynamic>> mỗi khi có thay đổi
    // Chúng ta cần chuyển nó thành List<String> chứa các URL ảnh
    return stream.map((listOfMaps) {
      // listOfMaps là List<Map<String, dynamic>>

      // Lọc ra những map có key 'image' và giá trị là String
        final validMaps = listOfMaps.where((map) {
        // Trả về true nếu map là Map và map['image'] là String
        return map is Map<String, dynamic> && map['image'] is String;
      });

      // Biến đổi những map hợp lệ thành danh sách các URL String
      final List<String> urls = validMaps.map((map) {
        // Vì đã lọc ở trên, nên ở đây có thể ép kiểu trực tiếp (hoặc dùng as String)
        return map['image'] as String;
      }).toList(); // Chuyển kết quả map thành List

      print('Supabase Realtime Update - Banner URLs: $urls'); // Debug
      return urls;
    }).handleError((error) {
      // Xử lý lỗi nếu stream gặp vấn đề
      print('Lỗi Supabase Realtime Stream: $error');
      return <String>[];
    });
  }
}
