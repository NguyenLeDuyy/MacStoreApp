import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadbannerListWidget extends StatelessWidget {
  const UploadbannerListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<List<Map<String, dynamic>>> _bannerStream =
    Supabase.instance.client
        .from('banners')
        .stream(primaryKey: ['id']);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _bannerStream,
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No banners found");
        }

        final List<Map<String, dynamic>> banners = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          itemCount: banners.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final banner = banners[index];
            final imageUrl = banner['image'];

            return Column(
              children: [
                imageUrl != null
                    ? Image.network(
                  imageUrl,
                  height: 100,
                  width: 100,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
                )
                    : Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey,
                  child: const Icon(Icons.image),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
