
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
class _CategoryScreenState extends State<CategoryScreen>{
  final GlobalKey<FormState> _formKey=GlobalKey<FormState>();
  late final SupabaseClient supabase = Supabase.instance.client;
  late final SupabaseStorageClient storage = supabase.storage;

  late String categoryName;
  dynamic _image;
  String? fileName;

  Future<void> pickImage() async {
    try {
      final XFile? file = await openFile(
        acceptedTypeGroups: [XTypeGroup(extensions: ['jpg', 'png', 'jpeg', 'gif'])],
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _image = bytes;
          fileName = file.name;
        });
      }
    } catch (e) {
      setState(() {
        _image = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't select an image. Please try again!")),
      );
    }
  }

  Future<String?> uploadImageToStorage(dynamic imageBytes, String fileName) async {
    try {
      final String path = fileName;

      final response = await storage
          .from('categories') // Tên bucket
          .uploadBinary(
        path,
        imageBytes,
        fileOptions: const FileOptions(upsert: true),
      );

      if (response.isNotEmpty && !response.contains('error')) {
        final String publicUrl = Supabase.instance.client.storage
            .from('categories')
            .getPublicUrl(path);

        return publicUrl;
      } else {
        debugPrint('Upload error: $response');
        return null;
      }
    } catch (e) {
      debugPrint('Upload failed: $e');
      return null;
    }
  }



  Future<void> uploadToSupabaseDatabase() async {

    if (_formKey.currentState!.validate()) {
      if (_image != null && fileName != null) {
        String? imageUrl = await uploadImageToStorage(_image, fileName!);

        if (imageUrl != null) {
          try {
            final insertedData = await Supabase.instance.client
                .from('categories')
                .insert({
              'category_name': categoryName,
              'category_image': imageUrl,
              'created_at': DateTime.now().toIso8601String(),
            });
                //.select(); // lấy về data vừa insert nếu cần

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category uploaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            debugPrint('Insert DB error: $e');
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category upload failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image upload failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
           children: [
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Container(
                 alignment: Alignment.topLeft,
                 child: Text(
                   'Categories',
                   style: TextStyle(
                       fontSize: 36,
                       fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             ),

             Divider(
               color: Colors.grey,
             ),

             Row(
               children: [
                 Column(
                   children: [
                     Container(
                       height: 140,
                       width: 150,
                       decoration: BoxDecoration(
                         color: Colors.grey.shade500,
                         border: Border.all(
                           color: Colors.grey.shade800,
                         ),
                         borderRadius: BorderRadius.circular(8),
                       ),

                       child: Center(
                         child: _image!=null ? Image.memory(_image) : Text(
                           'Upload Image',
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ),
                     ),

                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: ElevatedButton(
                         onPressed: (){
                           pickImage();
                         },
                         child: const Text(
                           'Upload Image',
                           style: TextStyle(
                             color: Colors.white,
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
                 SizedBox(
                   width: 30,
                 ),
                 SizedBox(
                   width: 150,
                   child: TextFormField(
                     onChanged: (value){
                       categoryName=value;
                     },
                     validator: (value){
                       if (value!.isEmpty){
                         return 'Please enter category name';
                       }else{
                         return null;
                       }
                     },
                     decoration: const InputDecoration(
                       labelText: 'Category Name',
                     ),
                   ),
                 ),

                 TextButton(
                   style: ButtonStyle(
                     backgroundColor: WidgetStateProperty.all(
                       Colors.white,
                     ),
                     side: WidgetStateProperty.all(
                         BorderSide(
                             color: Colors.blue.shade900,
                         ),
                     ),
                   ),
                   onPressed: (){
                      uploadToSupabaseDatabase();
                   },
                   child: const Text('Save',
                   ),
                 ),
               ],
             ),

             CategoryListWidget(),
           ],
        ),
      ),
    ),
    );
  }
}
