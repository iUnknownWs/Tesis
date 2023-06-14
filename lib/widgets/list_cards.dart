import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tesis/widgets/shop_cards.dart';

class BuildListCards extends StatelessWidget {
  final ShopList shopList;
  final user = FirebaseAuth.instance.currentUser!;
  BuildListCards({Key? key, required this.shopList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.hardEdge,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: shopList.imageUrl,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    shopList.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  RichText(
                    text: TextSpan(
                        text: 'Precio: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                              text: '${shopList.price.toString()}\$',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal)),
                        ]),
                  ),
                  RichText(
                    text: TextSpan(
                        text: 'Cantidad: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                              text: shopList.quantity,
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal)),
                        ]),
                  ),
                  // Text('Precio: ${shopList.price}\$'),
                  // Text('Cantidad: ${shopList.quantity}')
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 25, 8, 0),
              child: ElevatedButton(
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
                    title: Text(
                      '¿Desea eliminar el producto ${shopList.name} de su lista de compras?',
                      textAlign: TextAlign.center,
                    ),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar')),
                      TextButton(
                          onPressed: () {
                            final docShopList = FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('shoplist')
                                .doc(shopList.id);

                            docShopList.delete();
                            Navigator.pop(context);
                          },
                          child: const Text('Eliminar')),
                    ],
                  ),
                ),
                child: const Text(
                  'Eliminar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
