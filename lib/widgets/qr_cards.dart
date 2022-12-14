import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tesis/pages/add_product.dart';
import 'package:tesis/widgets/info_dialog.dart';
import 'package:tesis/widgets/shop_cards.dart';

class BuildQRCards extends StatefulWidget {
  final Products products;
  final QRViewController? controller;
  final Function callback;

  const BuildQRCards({
    required this.callback,
    required this.products,
    this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<BuildQRCards> createState() => _BuildQRCardsState();
}

class _BuildQRCardsState extends State<BuildQRCards> {
  Future addToList({
    required String id,
    required double total,
    required String name,
    required double price,
    required String imgUrl,
    required String quantity,
  }) async {
    final docShopList = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('shoplist')
        .doc(widget.products.id);
    final shopList = ShopList(
        total: total,
        id: docShopList.id,
        name: name,
        price: price,
        imageUrl: imgUrl,
        quantity: quantity);
    final json = shopList.toJson();
    await docShopList.set(json);
  }

  String quantity = '1';
  quantityFunction(String q) {
    setState(() {
      quantity = q;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              imageUrl: widget.products.imageUrl,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
              child: Text(
                widget.products.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text('Precio: ${widget.products.price}\$'),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: Column(
                children: [
                  const Text('Cantidad: '),
                  QuantityMenu(quantityFuction: quantityFunction),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFFFFFFFF),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF6750A4),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.controller!.resumeCamera();
                    },
                    child: const Text(
                      'Cancelar',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
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
                        content: Text(
                          '??Desea a??adir el producto ${widget.products.name} a la lista de compras?',
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
                              double total = (widget.products.price *
                                  double.parse(quantity));
                              addToList(
                                  id: widget.products.id,
                                  total: total,
                                  name: widget.products.name,
                                  price: widget.products.price,
                                  imgUrl: widget.products.imageUrl,
                                  quantity: quantity);
                              widget.callback(2);
                              widget.controller!.resumeCamera();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('A??adir'),
                          ),
                        ],
                      ),
                    ),
                    child: const Text(
                      'A??adir al Carro',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuantityMenu extends StatefulWidget {
  final Function quantityFuction;
  const QuantityMenu({super.key, required this.quantityFuction});

  @override
  State<QuantityMenu> createState() => _QuantityMenuState();
}

class _QuantityMenuState extends State<QuantityMenu> {
  String selected = '1';
  List<String> intList = List<String>.generate(99, (index) => '${index + 1}');
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        dropdownColor: ElevationOverlay.applySurfaceTint(
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceTint,
            2),
        iconEnabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
        style: Theme.of(context).textTheme.labelLarge,
        items: intList
            .map((val) => DropdownMenuItem(
                  value: val,
                  child: Text(val),
                ))
            .toList(),
        value: selected,
        onChanged: (value) {
          setState(() {
            selected = value!;
            widget.quantityFuction(selected);
          });
        },
      ),
    );
  }
}
