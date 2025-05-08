import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProductsScreen extends StatefulWidget {
  static const String id = 'products_screen';

  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final SupabaseStorageClient storage = Supabase.instance.client.storage;

  final TextEditingController _sizeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _categoryList = [];
  final List<String> _sizeList = [];
  final List<Uint8List> _images = [];
  final List<String> _imageUrls = [];

  int? selectedCategoryId;
  bool isLoading = false;
  String? productName;
  double? productPrice;
  double? discount;
  int? quantity;
  String? description;

  bool _isEntered = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _getCategories();
    super.initState();
  }

  void chooseImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final bytes = await pickedFile.readAsBytes();
    setState(() {
      _images.add(bytes);
    });
  }

  Future<void> _getCategories() async {
    final response = await supabase.from('categories').select('id, category_name');
    setState(() {
      _categoryList.clear();
      for (var item in response) {
        _categoryList.add({'id': item['id'], 'name': item['category_name']});
      }
    });
  }

  // Future<int> getNextProductId() async {
  //   final data = await supabase
  //       .from('products')
  //       .select('productId')
  //       .order('productId', ascending: false)
  //       .limit(1);
  //
  //   if (data.isNotEmpty && data[0]['productId'] != null) {
  //     return (data[0]['productId'] as int) + 1;
  //   } else {
  //     return 1; // Nếu chưa có sản phẩm nào
  //   }
  // }

  Future<String?> getSellerId(String email) async {
    final response = await Supabase.instance.client
        .from('business_accounts')
        .select('id')
        .eq('email', email)
        .maybeSingle(); // Tránh lỗi nếu không có kết quả

    if (response == null) {
      print('Không tìm thấy seller_id cho email: $email');
      return null;
    }

    return response['id'] as String?;
  }
  Future<void> uploadImageToStorage() async {
    final uuid = Uuid();
    try {
      for (var img in _images) {
        final fileName = '${uuid.v4()}.png';
        final response = await storage.from('products').uploadBinary(
          fileName,
          img,
          fileOptions: const FileOptions(upsert: true),
        );
        if (response != null) {
          final imageUrl = storage.from('products').getPublicUrl(fileName);
          _imageUrls.add(imageUrl);
        } else {
          throw Exception('Không nhận được phản hồi từ Supabase Storage.');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải ảnh: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> uploadData() async {
    setState(() {
      isLoading = true;
    });

    await uploadImageToStorage();
    if (_imageUrls.isNotEmpty) {
      final userEmail = Supabase.instance.client.auth.currentUser?.email;
      final sellerId = await getSellerId(userEmail!);
      if (sellerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Không tìm thấy tài khoản doanh nghiệp')),
        );
        return;
      }

     // final int productId = await getNextProductId();
      print({
        'productName': productName,
        'productPrice': productPrice,
        'productSize': _sizeList.join(', '),
        'category': selectedCategoryId,
        'description': description,
        'discount': discount,
        'quantity': quantity,
        'productImage': _imageUrls,
        'seller_id': sellerId,
        // 'created_at': DateTime.now().toIso8601String(),  // Thêm created_at
        // 'updated_at': DateTime.now().toIso8601String(),  // Thêm updated_at
      });

      await supabase.from('products').insert({
       // 'productId': productId,
        'productName': productName,
        'productPrice': productPrice,
        'productSize': _sizeList.join(', '),
        'category': selectedCategoryId,
        'description': description,
        'discount': discount,
        'quantity': quantity,
        'productImage': _imageUrls,
        'seller_id': sellerId,
        // 'created_at': DateTime.now().toIso8601String(),  // Thêm created_at
        // 'updated_at': DateTime.now().toIso8601String(),  // Thêm updated_at
      }).whenComplete(() {
        setState(() {
          isLoading = false;
          _formkey.currentState!.reset();
          _imageUrls.clear();
          _images.clear();
        });
      });
    }
  }


  Widget buildDropDownField() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Select category',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      items: _categoryList.map((item) {
        return DropdownMenuItem(
          value: item['id'], // Giá trị thực là ID
          child: Text(item['name']), // Hiển thị tên
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCategoryId = value as int?;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin sản phẩm'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                onChanged: (value) => productName = value,
                validator: (value) => value!.isEmpty ? 'Tên sản phẩm' : null,
                decoration: _inputDecoration('Tên sản phẩm'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) => productPrice = double.tryParse(value),
                      validator: (value) => value!.isEmpty ? 'Giá bán' : null,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Giá bán'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: buildDropDownField()),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) => discount = double.tryParse(value),
                validator: (value) => value!.isEmpty ? 'Giảm giá' : null,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Giảm giá'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) => quantity = int.tryParse(value),
                validator: (value) => value!.isEmpty ? 'Nhập số lượng' : null,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Nhập số lượng'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) => description = value,
                maxLength: 800,
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Mô tả' : null,
                decoration: _inputDecoration('Mô tả'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sizeController,
                      onChanged: (value) => setState(() => _isEntered = true),
                      decoration: _inputDecoration('Size'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _isEntered
                      ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sizeList.add(_sizeController.text);
                        _sizeController.clear();
                        _isEntered = false;
                      });
                    },
                    child: const Text('Thêm'),
                  )
                      : const SizedBox.shrink(),
                ],
              ),
              if (_sizeList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    spacing: 8,
                    children: _sizeList.map((size) {
                      return Chip(
                        label: Text(size),
                        onDeleted: () {
                          setState(() {
                            _sizeList.remove(size);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 20),
              GridView.builder(
                itemCount: _images.length + 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return index == 0
                      ? Center(
                    child: IconButton(
                      onPressed: chooseImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                      : Image.memory(_images[index - 1], fit: BoxFit.cover);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      uploadData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Upload Product',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
