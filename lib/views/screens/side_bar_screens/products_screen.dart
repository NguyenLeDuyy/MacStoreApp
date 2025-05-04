
// import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_selector/file_selector.dart';
import 'package:uuid/uuid.dart';


class ProductsScreen extends StatefulWidget {
  static const String id='products_screen';

  const ProductsScreen ({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final SupabaseStorageClient storage = Supabase.instance.client.storage;

  final TextEditingController _sizeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  //final bool _isLoading = false;


  final List<String> _categoryList = [];
  final List<String> _sizeList = [];
  final List<Uint8List> _images = [];
  final List<String> _imageUrls = [];

  String? selectedCategory;
  bool isLoading = false;
  String? productName;
  double? productPrice;
  double? discount;
  int? quantity;
  String? description;

  bool _isEntered = false;


  void chooseImage() async {
    final typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'png', 'jpeg', 'gif'],
    );

    final files = await openFiles(acceptedTypeGroups: [typeGroup]);

    if (files.isEmpty) {
      print('No image picked');
      return;
    }

    for (var file in files) {
      final bytes = await file.readAsBytes();
      _images.add(bytes);
    }

    setState(() {});
  }

  Future<void> _getCategories() async {
    final response = await supabase.from('categories').select();

    setState(() {
      for (var item in response) {
        _categoryList.add(item['category_name'] ?? 'Unknown');
      }
    });
  }

  @override
  void initState() {
    _getCategories();
    super.initState();

  }

  Future<void> uploadImageToStorage() async {
    final uuid = Uuid();
    try {
      for (var img in _images) {
        final fileName = '${uuid.v4()}.png';

        final response = await storage.from('product-images').uploadBinary(
          fileName,
          img,
          fileOptions: const FileOptions(upsert: true),
        );

        if (response != null) {
          final imageUrl = storage.from('product-images').getPublicUrl(fileName);
          setState(() {
            _imageUrls.add(imageUrl);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No response received'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred when uploading: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Upload image error: $e');
    }
  }

  Future<void> uploadData() async {
    setState(() {
      isLoading = true;
    });
    await uploadImageToStorage();
    if (_imageUrls.isNotEmpty) {
      final productId = Uuid().v4();
      await supabase.from('products').insert({
        'productId': productId,
        'productName': productName,
        'productPrice': productPrice,
        'productSize': _sizeList,
        'category': selectedCategory,
        'description': description,
        'discount': discount,
        'quantity': quantity,
        //'images': _imageUrls,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 400,
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Products Information',
                style: TextStyle(
                    fontSize:19,
                    fontWeight: FontWeight.bold),
              ),
                
              SizedBox(height: 20,),
                
              TextFormField(
                onChanged: (value){
                  productName=value;
                },
                validator: (value){
                  if (value!.isEmpty){
                    return 'Enter field';
                  }else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Enter Product Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
                
              SizedBox(height: 20,),
                
              Row(
                children: [
                  Flexible(child: TextFormField(
                    onChanged: (value){
                      productPrice = double.parse(value);
                    },
                    validator: (value){
                      if (value!.isEmpty){
                        return 'Enter field';
                      }else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter price',
                      filled: true,
                      fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                
                  const SizedBox(width: 20,),
                
                  Flexible(
                    child: builDropDownField(),
                  ),
                ],
              ),
                
              const SizedBox(height: 20,),
                
              TextFormField(
                onChanged: (value) {
                  discount = double.parse(value);
                },
                validator: (value){
                  if (value!.isEmpty){
                    return 'Enter field';
                  }else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Discount',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 20,),

              TextFormField(
                onChanged: (value){
                  quantity = int.parse(value);
                },
                validator: (value){
                  if (value!.isEmpty){
                    return 'Enter field';
                  }else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              TextFormField(
                onChanged: (value){
                  description = value;
                },
                maxLength: 800,
                maxLines: 4,
                validator: (value){
                  if (value!.isEmpty){
                    return 'Enter field';
                  }else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Enter Description',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
                
              const SizedBox(height: 20,),

              Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: _sizeController,
                        onChanged: (value) {
                          setState(() {
                            _isEntered = true;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Add size',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
          
                  const SizedBox(width: 10,),
          
                  _isEntered==true ? Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _sizeList.add(_sizeController.text);
                          _sizeController.clear();
                        });
                      },
                      child: const Text(
                          'Add'
                      ),
                    ),
                  ): const Text(''),
                ],
              ),
          
              _sizeList.isNotEmpty ?
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sizeList.length ,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _sizeList.removeAt(index);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade800,
                              borderRadius: BorderRadius.circular(8),
                            ),
          
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _sizeList[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ),
              ): Text(''),
          
              const SizedBox(height: 20,),
              GridView.builder(
                  itemCount: _images.length +1,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8,
                  ), itemBuilder: (context,index) {
                      return index==0 ? Center(
                          child: IconButton(onPressed: (){
                          chooseImage();
                          }, icon: const Icon(Icons.add)),
                      ):Image.memory(_images[index-1]);
                  }),
              InkWell(
                onTap: () {
                  if (_formkey.currentState!.validate()){
                    uploadData();
                    print('Uploaded');
                  }else{
                    //please fill in all fields
                    print('Bad status');
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width -50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: isLoading ? CircularProgressIndicator(color: Colors.white,)
                  : const Center(
                    child: Text('Upload Product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                ),
              )
            ],
          ),
        ),
      ),
    );

  }

  Widget builDropDownField () {
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
          items: _categoryList.map((value){
        return DropdownMenuItem(
            value: value,
            child: Text(value));
      }).toList(), onChanged: (value) {
        if (value!=null){
          setState(() {
            selectedCategory =value;
          });
        }
      });
  }
}
