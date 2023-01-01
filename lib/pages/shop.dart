import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tesis/pages/add_product.dart';
import 'package:tesis/widgets/shop_cards.dart';

Stream<List<Products>> readProducts() => FirebaseFirestore.instance
    .collection('products')
    .orderBy('name')
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => Products.fromJson(doc.data())).toList());

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder<List<Products>>(
          stream: readProducts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Algo ha ocurrido! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final products = snapshot.data!;
              return ListView(
                  children: products
                      .map((p) => BuildShopCards(products: p))
                      .toList());
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn1',
        mini: true,
        child: const Icon(
          Icons.add,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const ProductDialog(),
              fullscreenDialog: true,
            ),
          );
        },
      ),
    );
  }
}