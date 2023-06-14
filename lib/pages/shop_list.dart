import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tesis/widgets/list_cards.dart';
import 'package:tesis/widgets/shop_cards.dart';
import 'package:http/http.dart' as http;

class ShopListPage extends StatelessWidget {
  ShopListPage({super.key});
  final user = FirebaseAuth.instance.currentUser!;

  Stream<List<ShopList>> readProducts() => FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
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
    final Stream<QuerySnapshot> shoplistStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('shoplist')
        .snapshots();

    void onGooglePayResult(paymentResult) {
      final dbUserDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      debugPrint(paymentResult.toString());
      const SnackBar snackBar = SnackBar(
        content: Text('El pago se ha realizado con exito'),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      dbUserDoc.collection('shoplist').get().then((querySnapshot) => {
            // ignore: avoid_function_literals_in_foreach_calls
            querySnapshot.docs.forEach((result) {
              final docPro = FirebaseFirestore.instance
                  .collection('products')
                  .doc(result.id);
              docPro.get().then((DocumentSnapshot doc) {
                final data = doc.data() as Map<String, dynamic>;
                final int stockInt =
                    data['stock'] - int.parse(result['quantity']);
                final stock = <String, int>{"stock": stockInt};
                docPro.set(stock, SetOptions(merge: true));
              });
            })
          });
      dbUserDoc.collection('shoplist').get().then((querySnapshot) => {
            // ignore: avoid_function_literals_in_foreach_calls
            querySnapshot.docs.forEach((result) {
              dbUserDoc
                  .collection('history')
                  .doc()
                  .set(result.data())
                  .then((value) => result.reference.delete());
            })
          });
      // const String message = 'Testing';
      // sendEmail(
      //     toname: user.displayName!, toemail: user.email!, message: message);
    }

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
              if (sum != 0) {
                return Column(
                  children: [
                    Text(
                      'Monto total a Pagar: ${sum.toStringAsFixed(2)}\$',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    GooglePayButton(
                      paymentConfigurationAsset: 'gpay.json',
                      paymentItems: paymentItems,
                      type: GooglePayButtonType.pay,
                      margin: const EdgeInsets.only(top: 15.0),
                      onPaymentResult: onGooglePayResult,
                      // ignore: avoid_print
                      onError: (error) => print(error),
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsetsDirectional.only(bottom: 8)),
                    ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFFFFFFFF),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF6750A4),
                        ),
                      ),
                      onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                          title: SizedBox(
                            width: 240,
                            height: 260,
                            child: QrImage(
                              data: sum.toString(),
                              backgroundColor: Colors.white,
                            ),
                          ),
                          content: SizedBox(
                              height: 18,
                              child: Center(
                                  child: Text(
                                      'Precio total a pagar: ${sum.toStringAsFixed(2)} \$'))),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cerrar')),
                          ],
                        ),
                      ),
                      child: const Text(
                        'Mostrar el QR',
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsetsDirectional.only(bottom: 8)),
                  ],
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Center(child: Text('No ha añadido ningún producto aún')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

Future sendEmail({
  required String toname,
  required String toemail,
  required String message,
}) async {
  const serviceId = 'service_iq9tb2n';
  const templateId = 'template_gi33xd8';
  const userId = '5nhNlo4H4FEu6rDx7';
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_name': toname,
          'to_email': toemail,
          'message': message,
        }
      }));

  // ignore: avoid_print
  print(response.body);
}
