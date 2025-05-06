import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/views/screens/inner_screens/order_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderScreen extends StatefulWidget {
   const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    // final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance.collection('orders').where('buyerId', isEqualTo: FirebaseAuth.instancee.currentUser!.uid).snapshots();

    final ordersStream = Supabase.instance.client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('buyerId', Supabase.instance.client.auth.currentUser!.id)
        .order('created_at');

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 118,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/cartb.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 322,
                  top: 52,
                  child: Stack(
                    children: [
                      Image.asset('assets/icons/not.png', width: 26, height: 25),
                    ],
                  ),
                ),
                Positioned(
                  left: 10, // Adjust position as needed
                  top: 50,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  left: 61,
                  top: 51,
                  child: Text(
                    'Đơn hàng của tôi',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ordersStream,
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.isEmpty){
            return const  Center(
              child: Text('Bạn đang không có đơn hàng nào',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),

              )
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length ,
            itemBuilder: (context, index){
              final orderData = snapshot.data![index];
             // print(snapshot.data); // Kiểm tra toàn bộ dữ liệu trả về
              return Padding(
                padding: const  EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 25,
              ),
                child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return OrderDetailScreen(orderData: orderData,);
                  }));
                },
                child: Container(
                  width: 335,
                  height: 153,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(),
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 336,
                            height: 154,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(
                                  0xffeff0f2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(9,),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                    left:13,
                                    top: 9,
                                    child: Container(
                                      width: 78,
                                      height: 78,
                                      clipBehavior: Clip.antiAlias,
                                      decoration:  BoxDecoration(
                                        color: const Color(
                                          0xffbcc5ff,
                                        ),
                                        borderRadius: BorderRadius.circular(8,),
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                              left:10,
                                              top:5,
                                              child: Image.network(
                                                orderData['productImage'],
                                                width: 58,
                                                height: 67,
                                                fit: BoxFit.cover,
                                              ),
                                          ),


                                        ],
                                      ),
                                    ),
                                ),
                                Positioned(
                                  left: 101,
                                  top: 14,
                                  child: SizedBox(
                                    width: 216,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  orderData['productName'],overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.getFont(
                                                    'Lato',
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4,),

                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(orderData['category'],

                                                  style: const TextStyle(
                                                    color: Color(
                                                      0xff7f808c,
                                                    ),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              const  SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                "\$${orderData['price']}",
                                                style: const TextStyle(
                                                  color: Color(
                                                    0xff0b0c1e,
                                                  ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 13,
                                  top: 113,
                                  child: Container(
                                    width:90,
                                    height: 25,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: orderData['delivered']== true?Color(0xff3c55ef):orderData['processing']==true?
                                      Colors.purple
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(4,),
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                            left: 9,
                                            top: 3,
                                            child: Text(
                                              orderData['delivered']==true
                                                  ?'Đã giao hàng':orderData['processing']==
                                                  true
                                                  ?'Đang xử lý'
                                                  :'Đã hủy',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                height: 1.3,
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 298,
                                  top:115,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                            top: 0,
                                            left: 0,
                                            child: InkWell(
                                              onTap: () async{
                                                await _supabase
                                                    .from('orders')
                                                    .delete()
                                                    .eq('id', orderData['id']);
                                                setState(() {});
                                              },
                                              child: Image.asset('assets/icons/delete.png',
                                                width: 20, height: 20,),
                                            ))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              );
            },
          );

        },
      )
    );
  }
}
