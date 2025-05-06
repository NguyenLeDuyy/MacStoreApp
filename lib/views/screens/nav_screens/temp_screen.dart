import 'package:flutter/material.dart';
// Optional: Nếu bạn có cấu hình localization
// import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MinimalInputApp());
}

class MinimalInputApp extends StatelessWidget {
  const MinimalInputApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Optional: Cấu hình locale tiếng Việt nếu cần
      // locale: Locale('vi', 'VN'),
      // supportedLocales: [
      //   Locale('en', ''),
      //   Locale('vi', 'VN'),
      // ],
      // localizationsDelegates: [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      home: MinimalInputScreen(),
      debugShowCheckedModeBanner: false, // Tắt banner debug
    );
  }
}

class MinimalInputScreen extends StatefulWidget {
  const MinimalInputScreen({super.key});

  @override
  _MinimalInputScreenState createState() => _MinimalInputScreenState();
}

class _MinimalInputScreenState extends State<MinimalInputScreen> {
  final TextEditingController _testController = TextEditingController();

  @override
  void dispose() {
    _testController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kiểm tra gõ Tiếng Việt')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Vui lòng thử gõ tiếng Việt có dấu vào ô bên dưới:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _testController,
              decoration: InputDecoration(
                labelText: 'Nhập ở đây (Ví dụ: Cà, Việt, Trường)',
                border: OutlineInputBorder(),
                hintText: 'Gõ thử chữ "Cà"...',
              ),
              style: TextStyle(fontSize: 18), // Tăng cỡ chữ cho dễ nhìn
            ),
            SizedBox(height: 20),
            // Hiển thị giá trị đang được nhập để kiểm tra
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _testController,
              builder: (context, value, child) {
                return Text('Giá trị hiện tại: ${value.text}');
              },
            ),
          ],
        ),
      ),
    );
  }
}