import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_web/views/screens/side_bar_screens/widgets/category_list_widget.dart';

class CategoryScreen extends StatefulWidget {
  static const String id = 'category_screen';

  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  Uint8List? _imageBytes;
  String? _fileName;
  String _categoryName = '';
  bool _isUploading = false;
  Key _categoryListKey = UniqueKey();

  /* ───────────────────── PICK IMAGE ───────────────────── */
  Future<void> _pickImage() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [XTypeGroup(extensions: ['jpg', 'png', 'jpeg', 'gif'])],
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _fileName   = file.name;
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't select an image, try again!")),
      );
    }
  }

  /* ───────────────────── UPLOAD IMAGE ───────────────────── */
  Future<String?> _uploadImage() async {
    if (_imageBytes == null || _fileName == null) return null;

    // thêm timestamp để tránh ghi đè file trùng tên
    final ext  = _fileName!.split('.').last;
    final path = 'category_images/${DateTime.now().millisecondsSinceEpoch}.$ext';

    try {
      await supabase.storage.from('categories').uploadBinary(
        path,
        _imageBytes!,
        fileOptions: const FileOptions(upsert: false),
      );
      return supabase.storage.from('categories').getPublicUrl(path);
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }

  /* ───────────────────── SAVE CATEGORY ───────────────────── */
  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUploading = true);
    final imageUrl = await _uploadImage();

    if (imageUrl == null) {
      _showSnack('Image upload failed. Category not saved.', Colors.red);
      setState(() => _isUploading = false);
      return;
    }

    try {
      await supabase.from('categories').upsert(
        {
          'category_name': _categoryName.trim(),
          'category_image': imageUrl,
        },
        onConflict: 'category_name',
      ).select(); // trả về row mới, ném lỗi nếu thất bại

      _showSnack('Category saved!', Colors.green);

      // reset form & refresh list
      setState(() {
        _imageBytes      = null;
        _fileName        = null;
        _categoryName    = '';
        _isUploading     = false;
        _categoryListKey = UniqueKey();
        _formKey.currentState?.reset();
      });
    } on PostgrestException catch (e) {
      _showSnack('Supabase error: ${e.message}', Colors.red);
      setState(() => _isUploading = false);
    } catch (e) {
      _showSnack('Unexpected error: $e', Colors.red);
      setState(() => _isUploading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  /* ───────────────────── UI ───────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Categories',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 16),

              /* ---------- Upload row ---------- */
              Wrap(
                spacing: 32,
                runSpacing: 24,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  _imagePickerCard(),
                  _nameAndSaveCard(),
                ],
              ),

              const SizedBox(height: 32),
              const Text('Category List',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const Divider(),

              /* ---------- List ---------- */
              SizedBox(
                height: 500, // cố định để ScrollView cha không lỗi height
                child: CategoryListWidget(key: _categoryListKey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ───────── Helpers UI ───────── */

  Widget _imagePickerCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 140,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(color: Colors.grey.shade500),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageBytes == null
              ? const Icon(Icons.image_outlined, size: 50, color: Colors.grey)
              : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _isUploading ? null : _pickImage,
          child: const Text('Upload Image'),
        ),
      ],
    );
  }

  Widget _nameAndSaveCard() {
    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: _categoryName,
            onChanged: (v) => _categoryName = v,
            validator: (v) =>
            v == null || v.trim().isEmpty ? 'Please enter category name' : null,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: _isUploading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.save),
            label: Text(_isUploading ? 'Saving...' : 'Save Category'),
            onPressed: _isUploading ? null : _saveCategory,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
