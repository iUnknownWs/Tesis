import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tesis/pages/add_product.dart';
import 'package:tesis/widgets/info_dialog.dart';

class BuildShopCards extends StatefulWidget {
  final Products products;
  const BuildShopCards({required this.products, Key? key}) : super(key: key);

  @override
  State<BuildShopCards> createState() => _BuildShopCardsState();
}

class _BuildShopCardsState extends State<BuildShopCards> {
  String quantity = '1';
  quantityFunction(String q) {
    setState(() {
      quantity = q;
    });
  }

  Future addToList({
    required String id,
    required String name,
    required double price,
    required String imgUrl,
    required String quantity,
    required double total,
  }) async {
    final docShopList = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('shoplist')
        .doc(widget.products.id);
    final shopList = ShopList(
        id: docShopList.id,
        total: total,
        name: name,
        price: price,
        imageUrl: imgUrl,
        quantity: quantity);
    final json = shopList.toJson();
    await docShopList.set(json).then(
          (value) => showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'El producto se ha añadido al carrito',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    String data = widget.products.id;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(
              image: NetworkImage(widget.products.imageUrl),
              fit: BoxFit.cover,
            ),
            ListTile(
              title: Text(widget.products.name),
              subtitle: Text('Precio: ${widget.products.price}\$'),
              visualDensity: VisualDensity.compact,
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cantidad: '),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                    child: QuantityMenu(
                      quantityFuction: quantityFunction,
                    ),
                  ),
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
                    onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => AlertDialog(
                        title: SizedBox(
                          width: 240,
                          height: 260,
                          child: QrImage(
                            data: data,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        content: Text('ID del producto: $data'),
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
                      'Mostrar QR',
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
                        title: Text(
                          '¿Desea eliminar el producto ${widget.products.name} de la base de datos?',
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
                                final docProducts = FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(widget.products.id);

                                docProducts.delete();
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
                          '¿Desea añadir $quantity ${widget.products.name}(s) a la lista de compras? \n \n'
                          'Atencion!: Si este producto ya se encuentra en el carrito añadirlo de nuevo reemplazará el anterior',
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
                                double total = widget.products.price *
                                    double.parse(quantity);
                                addToList(
                                        id: widget.products.id,
                                        total: total,
                                        name: widget.products.name,
                                        price: widget.products.price,
                                        imgUrl: widget.products.imageUrl,
                                        quantity: quantity)
                                    .then((value) => Navigator.pop(context));
                              },
                              child: const Text('Añadir')),
                        ],
                      ),
                    ),
                    child: const Text(
                      'Añadir al Carro',
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
        enableFeedback: true,
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

class ShopList {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String quantity;
  final double total;

  ShopList({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'quantity': quantity,
        'total': total,
      };

  static ShopList fromJson(Map<String, dynamic> json) {
    return ShopList(
      total: json['total'],
      id: json['id'],
      name: json['name'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
    );
  }
}
