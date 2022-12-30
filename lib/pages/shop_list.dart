import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:tesis/widgets/list_cards.dart';
import 'package:tesis/widgets/shop_cards.dart';

class ShopListPage extends StatelessWidget {
  ShopListPage({super.key});

  Stream<List<ShopList>> readProducts() => FirebaseFirestore.instance
      .collection('shoplist')
      .orderBy('price')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ShopList.fromJson(doc.data())).toList());

  final paymentItems = [
    const PaymentItem(
      label: 'Total',
      amount: '99.99',
      status: PaymentItemStatus.final_price,
    )
  ];

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> shoplistStream =
        FirebaseFirestore.instance.collection('shoplist').snapshots();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ShopList>>(
                stream: readProducts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Algo ha ocurrido! ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final shoplist = snapshot.data!;
                    return ListView(
                        children: shoplist
                            .map((p) => BuildListCards(shopList: p))
                            .toList());
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          ),
          StreamBuilder(
            stream: shoplistStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              final ds = snapshot.data!.docs;
              double sum = 0.0;
              for (int i = 0; i < ds.length; i++) {
                sum += (ds[i]['total']).toDouble();
              }
              return Column(
                children: [
                  Text('Monto total a Pagar: $sum'),
                  GooglePayButton(
                    paymentConfigurationAsset: 'gpay.json',
                    paymentItems: paymentItems,
                    type: GooglePayButtonType.pay,
                    margin: const EdgeInsets.only(top: 15.0),
                    onPaymentResult: print,
                    // ignore: avoid_print
                    onError: (error) => print(error),
                    childOnError: const Text('Error'),
                    loadingIndicator: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  const Padding(padding: EdgeInsetsDirectional.only(bottom: 8))
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.paid,
        ),
        onPressed: () {},
      ),
    );
  }
}
