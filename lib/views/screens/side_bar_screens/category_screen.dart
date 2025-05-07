import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_web/views/screens/side_bar_screens/widgets/category_list_widget.dart'; // Đảm bảo đường dẫn này đúng

class CategoryScreen extends StatefulWidget {
  static const String id = 'category_screen';

  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final SupabaseClient supabase = Supabase.instance.client;
  // late final SupabaseStorageClient storage = supabase.storage; // Không cần khai báo riêng nếu đã có supabase.storage

  late String categoryName = ''; // Khởi tạo để tránh lỗi late
  dynamic _image;
  String? fileName;
  bool _isUploading = false; // Thêm biến trạng thái loading

  Key _categoryListKey = UniqueKey(); // Key để rebuild CategoryListWidget

  Future<void> pickImage() async {
    try {
      final XFile? file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(extensions: ['jpg', 'png', 'jpeg', 'gif'])
        ],
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _image = bytes;
          fileName = file.name;
        });
      }
    } catch (e) {
      // Không cần setState _image = null ở đây vì nó đã được xử lý trong UI
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Couldn't select an image. Please try again!")),
      );
    }
  }

  Future<String?> uploadImageToStorage(
      dynamic imageBytes, String fileName) async {
    try {
      final String path = 'category_images/$fileName'; // Thêm thư mục để tổ chức

      await supabase.storage.from('categories').uploadBinary(
        // Tên bucket
        path,
        imageBytes,
        fileOptions: const FileOptions(upsert: true), // upsert: true sẽ ghi đè nếu file tồn tại
      );

      // Sau khi upload thành công, lấy public URL
      final String publicUrl =
      supabase.storage.from('categories').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Image Upload failed: $e');
      return null;
    }
  }

  Future<void> _uploadCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_image == null || fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image for the category.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? imageUrl = await uploadImageToStorage(_image!, fileName!);

    if (imageUrl != null) {
      try {
        await supabase.from('categories').insert({
          'category_name': categoryName,
          'category_image': imageUrl,
          // 'created_at': DateTime.now().toIso8601String(), // Supabase sẽ tự thêm nếu cột có default now()
        });

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() { // Reset form và làm mới danh sách
          _image = null;
          fileName = null;
          _formKey.currentState?.reset();
          categoryName = ''; // Reset categoryName
          _categoryListKey = UniqueKey();
        });
      } catch (e) {
        debugPrint('Insert DB error: $e');
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save category to database: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image upload failed. Category not saved.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Căn các phần tử con về bên trái
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0), // Chỉ cần padding dọc
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 28, // Giảm kích thước một chút cho cân đối
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.grey,
              ),
              const SizedBox(height: 20), // Khoảng cách sau Divider
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 140,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300, // Màu nền nhạt hơn
                          border: Border.all(
                            color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: _image != null
                              ? Image.memory(_image, fit: BoxFit.cover)
                              : const Icon(Icons.image_outlined, size: 50, color: Colors.grey), // Icon placeholder
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isUploading ? null : pickImage, // Disable khi đang upload
                        child: const Text('Upload Image'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: categoryName, // Để reset hoạt động
                          onChanged: (value) {
                            categoryName = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter category name';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Category Name',
                            hintText: 'Enter category name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: _isUploading
                              ? Container( // Spinner nhỏ
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.save),
                          label: Text(_isUploading ? 'Saving...' : 'Save Category'),
                          onPressed: _isUploading ? null : _uploadCategory,
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Khoảng cách trước danh sách
              const Text(
                'Category List',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const Divider(),
              Expanded( // QUAN TRỌNG: Cho phép danh sách cuộn và chiếm không gian còn lại
                child: CategoryListWidget(key: _categoryListKey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}