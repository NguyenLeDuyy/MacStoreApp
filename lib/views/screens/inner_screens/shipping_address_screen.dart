import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.96),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.96),
        title: Text(
          'Địa chỉ giao hàng',
          style: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  textAlign: TextAlign.center,
                  'Lựa chọn địa chỉ giao hàng',
                  style: GoogleFonts.lato(fontSize: 17, letterSpacing: 2),
                ),
            
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return "Vui lòng không để trống";
                    }else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tỉnh/Thành phố',
                    // border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30,),
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return "Vui lòng không để trống";
                    }else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Quận/Huyện'
                  ),
                ),
            
                const SizedBox(height: 30,),
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return "Vui lòng không để trống";
                    }else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Phường/Xã'
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: (){
            if(_formKey.currentState!.validate()){
              //update the user address

            }else {
              //Show a snackbar

            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFF1532E7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
              child: Text('Thêm địa chỉ', style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),),
            ),
          ),
        ),
      ),
    );
  }
}
