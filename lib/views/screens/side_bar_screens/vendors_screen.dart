// screens/vendors_screen.dart
import 'package:app_web/services/business_accounts_services.dart';
import 'package:flutter/material.dart';
import '../../../models/business_accounts.dart';

class VendorsScreen extends StatefulWidget {
  static const String id = 'vendors_screen';

  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final BusinessAccountsServices _businessAccountsServices = BusinessAccountsServices();
  late Future<List<BusinessAccount>> _vendorsFuture;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  void _loadVendors() {
    setState(() {
      _vendorsFuture = _businessAccountsServices.getBusinessAccounts();
    });
  }

  Future<void> _updateVendorStatus(String vendorId, String currentStatus) async {
    // Hiển thị dialog xác nhận hoặc chọn trạng thái mới
    String? newStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String selectedStatus = currentStatus; // Trạng thái hiện tại làm giá trị ban đầu
        return AlertDialog(
          title: const Text('Update Vendor Status'),
          content: StatefulBuilder( // Sử dụng StatefulBuilder để cập nhật UI trong dialog
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButtonFormField<String>(
                value: selectedStatus,
                items: ['pending', 'approved', 'rejected', 'suspended']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'New Status'),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                Navigator.of(context).pop(selectedStatus);
              },
            ),
          ],
        );
      },
    );

    if (newStatus != null && newStatus != currentStatus) {
      try {
        await _businessAccountsServices.updateVendorStatus(vendorId, newStatus);
        // Tải lại danh sách vendors để cập nhật UI
        _loadVendors();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vendor status updated to $newStatus successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update vendor status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewVendorDetails(BusinessAccount vendor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorDetailsScreen(vendorId: vendor.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Vendors',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<BusinessAccount>>(
              future: _vendorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No vendors found.'));
                }

                final vendors = snapshot.data!;

                // Sử dụng PaginatedDataTable để hiển thị dữ liệu dạng bảng
                // và có phân trang
                return SingleChildScrollView( // Cần cho PaginatedDataTable trên web nếu nội dung quá dài
                  child: PaginatedDataTable(
                    header: const Text('Vendor List'),
                    rowsPerPage: 10, // Số lượng dòng mỗi trang
                    columns: const [
                      DataColumn(label: Text('Company Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Requested At')),
                      DataColumn(label: Text('Actions')),
                    ],
                    source: _VendorDataSource(
                      vendors: vendors,
                      onStatusUpdate: (vendor) => _updateVendorStatus(vendor.id, vendor.status),
                      onViewDetails: _viewVendorDetails,
                    ),
                    // Cấu hình thêm cho PaginatedDataTable nếu cần
                    // showCheckboxColumn: false,
                    // sortColumnIndex: _sortColumnIndex,
                    // sortAscending: _sortAscending,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// DataSource cho PaginatedDataTable
class _VendorDataSource extends DataTableSource {
  final List<BusinessAccount> vendors;
  final Function(BusinessAccount) onStatusUpdate;
  final Function(BusinessAccount) onViewDetails;


  _VendorDataSource({
    required this.vendors,
    required this.onStatusUpdate,
    required this.onViewDetails,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= vendors.length) {
      return null;
    }
    final vendor = vendors[index];
    return DataRow(
      cells: [
        DataCell(Text(vendor.companyName ?? 'N/A')),
        DataCell(Text(vendor.email ?? 'N/A')),
        DataCell(
          Chip(
            label: Text(vendor.status.toUpperCase()),
            backgroundColor: _getStatusColor(vendor.status),
            labelStyle: const TextStyle(color: Colors.white),
          ),
        ),
        DataCell(Text(vendor.requestedAt?.toLocal().toString().substring(0,16) ?? 'N/A')),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              tooltip: 'Update Status',
              onPressed: () => onStatusUpdate(vendor),
            ),
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.green),
              tooltip: 'View Details',
              onPressed: () => onViewDetails(vendor),
            ),
            // Thêm các hành động khác nếu cần (ví dụ: xóa, tạm ngưng)
          ],
        )),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'suspended':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => vendors.length;

  @override
  int get selectedRowCount => 0; // Không sử dụng checkbox ở đây
}


// Màn hình chi tiết Vendor (ví dụ đơn giản)
class VendorDetailsScreen extends StatelessWidget {
  final String vendorId;
  final BusinessAccountsServices _businessAccountsServices = BusinessAccountsServices();

  VendorDetailsScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Details'),
      ),
      body: FutureBuilder<BusinessAccount?>(
        future: _businessAccountsServices.getBusinessAccountById(vendorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Vendor not found.'));
          }

          final vendor = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView( // Sử dụng ListView để có thể cuộn nếu nội dung dài
              children: <Widget>[
                _buildDetailRow('Company Name:', vendor.companyName),
                _buildDetailRow('Company Number:', vendor.companyNumber),
                _buildDetailRow('Email:', vendor.email),
                _buildDetailRow('Address:', vendor.address),
                _buildDetailRow('NID Owner:', vendor.nidOwner),
                _buildDetailRow('Status:', vendor.status.toUpperCase()),
                _buildDetailRow('Balance:', vendor.balance?.toStringAsFixed(2) ?? 'N/A'),
                _buildDetailRow('About:', vendor.about),
                _buildDetailRow('Categories:', vendor.categories?.join(', ')),
                _buildDetailRow('Tags:', vendor.tags?.join(', ')),
                _buildDetailRow('Created At:', vendor.createdAt.toLocal().toString()),
                _buildDetailRow('Requested At:', vendor.requestedAt?.toLocal().toString()),
                _buildDetailRow('Reviewed At:', vendor.reviewedAt?.toLocal().toString()),
                if (vendor.profilePictureUrl != null && vendor.profilePictureUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Profile Picture:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Image.network(vendor.profilePictureUrl!, height: 150, errorBuilder: (context, error, stackTrace) => const Text('Could not load image')),
                      ],
                    ),
                  ),
                // Thêm các trường khác nếu cần
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.approval),
                  label: const Text('Approve Vendor'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: vendor.status == 'pending' ? () async {
                    // Logic phê duyệt vendor
                    try {
                      await _businessAccountsServices.updateVendorStatus(vendor.id, 'approved');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vendor approved successfully!'), backgroundColor: Colors.green),
                      );
                      Navigator.pop(context); // Quay lại màn hình danh sách và làm mới
                      // Cân nhắc việc gọi _loadVendors() ở màn hình trước nếu cần
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to approve vendor: $e'), backgroundColor: Colors.red),
                      );
                    }
                  } : null, // Disable nút nếu không phải 'pending'
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.block),
                  label: const Text('Reject Vendor'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: vendor.status == 'pending' ? () async {
                    // Logic từ chối vendor
                    try {
                      await _businessAccountsServices.updateVendorStatus(vendor.id, 'rejected');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vendor rejected successfully!'), backgroundColor: Colors.orange),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to reject vendor: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }: null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }
}