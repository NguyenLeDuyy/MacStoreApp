
import 'package:flutter/cupertino.dart';

class VendorsScreen extends StatelessWidget{
  static const String id='vendors_screen';

  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text('Vendor Screen'),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class VendorsScreen extends StatefulWidget {
//   static const String id = 'vendors_screen';
//
//   const VendorsScreen({super.key});
//
//   @override
//   _VendorsScreenState createState() => _VendorsScreenState();
// }
//
// class _VendorsScreenState extends State<VendorsScreen> {
//   final SupabaseClient supabase = Supabase.instance.client;
//   List<Map<String, dynamic>> vendors = [];
//
//   final TextEditingController nameController = TextEditingController();
//   String? selectedVendorId; // Dùng để chỉnh sửa nhà cung cấp
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchVendors(); // Tải danh sách nhà cung cấp từ Supabase khi mở màn hình
//   }
//
//   Future<void> _fetchVendors() async {
//     final response = await supabase.from('vendors').select('*');
//     setState(() {
//       vendors = response as List<Map<String, dynamic>>;
//     });
//   }
//
//   Future<void> _addOrUpdateVendor() async {
//     final name = nameController.text.trim();
//     if (name.isEmpty) return;
//
//     if (selectedVendorId == null) {
//       // Thêm nhà cung cấp mới
//       await supabase.from('vendors').insert({'name': name});
//     } else {
//       // Cập nhật nhà cung cấp đã chọn
//       await supabase.from('vendors').update({'name': name}).eq('id', selectedVendorId);
//     }
//
//     nameController.clear();
//     selectedVendorId = null;
//     _fetchVendors(); // Làm mới danh sách sau khi thêm/cập nhật
//   }
//
//   Future<void> _deleteVendor(String id) async {
//     await supabase.from('vendors').delete().eq('id', id);
//     _fetchVendors(); // Làm mới danh sách sau khi xóa
//   }
//
//   void _editVendor(String id, String name) {
//     setState(() {
//       selectedVendorId = id;
//       nameController.text = name;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Danh sách Nhà Cung Cấp')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: vendors.length,
//                 itemBuilder: (context, index) {
//                   final vendor = vendors[index];
//                   return ListTile(
//                     title: Text(vendor['name']),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit, color: Colors.blue),
//                           onPressed: () => _editVendor(vendor['id'], vendor['name']),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => _deleteVendor(vendor['id']),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Tên Nhà Cung Cấp',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _addOrUpdateVendor,
//               child: Text(selectedVendorId == null ? 'Thêm Nhà Cung Cấp' : 'Cập Nhật Nhà Cung Cấp'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }