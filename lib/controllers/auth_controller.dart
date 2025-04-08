import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final GoTrueClient  _auth = Supabase.instance.client.auth;
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<String> registerNewUser(
    String email,
    String fullname,
    String password,
  ) async {
    String res = 'something went wrong';

    try {
      // 1. Tạo người dùng trong Supabase Auth
      // Lưu ý: signUp trong Supabase không tự động đăng nhập người dùng theo mặc định
      // nếu bạn bật Email Confirmation. Nếu không bật, nó sẽ trả về session.
      // Thêm 'data' để lưu thông tin ban đầu nếu muốn (ít linh hoạt hơn bảng riêng)
      final AuthResponse authResponse = await _auth.signUp(
        email: email,
        password: password,
        // Bạn CÓ THỂ thêm dữ liệu tùy chỉnh vào đây nếu hồ sơ đơn giản
        // data: {'full_name': fullname},
      );
      if (authResponse.user != null) {
        // 2. Lưu thông tin bổ sung vào bảng 'profiles' (hoặc 'buyers')
        // Đảm bảo bảng 'profiles' đã được tạo trong Supabase với các cột tương ứng
        // và cột 'id' của bảng profiles là foreign key tham chiếu đến auth.users.id
        await _supabase.from('buyers').insert({ // Thay 'profiles' bằng tên bảng của bạn nếu khác
          'uid': authResponse.user!.id, // Lấy user ID từ kết quả signUp
          'fullName': fullname,
          'email': email,
          'profileImage': "", // Giá trị mặc định
          'pinCode': "",
          'locality': '',
          'city': '',
          'state': "",
          // created_at và updated_at thường được DB tự quản lý nếu cấu hình mặc định
        });

        // Nếu bạn bật Email Confirmation, người dùng cần xác thực email trước khi đăng nhập.
        // Nếu không bật, authResponse.session sẽ có giá trị và người dùng được coi là đã đăng nhập.
        res = 'success';

      } else {
        // Trường hợp signUp không thành công nhưng không ném lỗi (ít xảy ra)
        res = 'Không thể tạo người dùng.';
      }

    } on AuthException catch (e) {
      // Xử lý các lỗi cụ thể của Supabase Auth
      // Thông báo lỗi của Supabase thường khá rõ ràng
      res = e.message; // Lấy thông báo lỗi từ Supabase
      print('Supabase Auth Error: ${e.message}'); // Ghi log lỗi
    } catch (e) {
      // Xử lý các lỗi khác (ví dụ: lỗi mạng, lỗi insert vào bảng profiles)
      res = e.toString();
      print('Generic Error: $e'); // Ghi log lỗi
    }

    return res;
  }

  //LOGIN USER
  Future<String> loginUser(String email, String password) async {
    String res = 'Đã có lỗi xảy ra'; // Sửa lỗi chính tả

    try {
      // Đăng nhập người dùng bằng Supabase Auth
      final AuthResponse authResponse = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Kiểm tra xem đăng nhập có thành công và trả về session/user không
      if (authResponse.user != null && authResponse.session != null) {
        res = 'success';
      } else {
        // Trường hợp đăng nhập không thành công nhưng không ném lỗi
        res = 'Thông tin đăng nhập không hợp lệ.';
      }

    } on AuthException catch (e) {
      // Xử lý lỗi Supabase Auth
      res = e.message; // Thông báo lỗi như "Invalid login credentials"
      print('Supabase Auth Error: ${e.message}'); // Ghi log lỗi
    } catch (e) {
      // Xử lý các lỗi khác
      res = e.toString();
      print('Generic Error: $e'); // Ghi log lỗi
    }
    return res;
  }

  // (Tùy chọn) Thêm hàm đăng xuất
  Future<String> logoutUser() async {
    String res = 'Đã có lỗi xảy ra';
    try {
      await _auth.signOut();
      res = 'success';
    } on AuthException catch (e) {
      res = e.message;
      print('Supabase Auth Error: ${e.message}');
    } catch (e) {
      res = e.toString();
      print('Generic Error: $e');
    }
    return res;
  }
}
