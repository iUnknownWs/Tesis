import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tesis/widgets/shop_cards.dart';

class BuildListCards extends StatelessWidget {
  final ShopList shopList;
  const BuildListCards({Key? key, required this.shopList}) : super(key: key);

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
            Image(
              image: NetworkImage(shopList.imageUrl),
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(shopList.name),
                  Text('Precio: ${shopList.price}\$'),
                  Text('Cantidad: ${shopList.quantity}')
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
                          '¿Desea eliminar el producto ${shopList.name} de la base de datos?',
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
