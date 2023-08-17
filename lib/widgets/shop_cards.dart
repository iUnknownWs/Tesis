import 'package:cached_network_image/cached_network_image.dart';
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
        id: id,
        total: total,
        name: name,
        uname: user.displayName!,
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
              child: Row(
                children: [
                  const Text('Precio: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.products.price.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Cantidad: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 8),
                    child: QuantityMenu(
                      quantityFuction: quantityFunction,
                      stock: widget.products.stock,
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
                          child: QrImageView(
                            data: data,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Column(
                                children: [
                                  const Text(
                                    'ID del producto:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(data),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Column(
                                children: [
                                  const Text(
                                    'Creado por: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(widget.products.uname),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Fecha de Creación: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(widget.products.date),
                              ],
                            ),
                          ],
                        ),
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
                      'Info',
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
                                final delProducts = FirebaseFirestore.instance
                                    .collection('delProducts')
                                    .doc(widget.products.id);

                                final data = <String, String>{
                                  "delBy": user.displayName!,
                                  "id": user.uid,
                                  "delDate": DateTime.now().toString()
                                };
                                docProducts.get().then(
                                    (DocumentSnapshot result) => delProducts
                                        .set(result.data()
                                            as Map<String, dynamic>)
                                        .then((value) => delProducts.set(
                                            data, SetOptions(merge: true)))
                                        .then((value) => docProducts.delete()));
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
                          '¿Desea añadir $quantity ${widget.products.name}(s) a la lista de compras?',
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
  final int stock;
  const QuantityMenu(
      {super.key, required this.quantityFuction, required this.stock});

  @override
  State<QuantityMenu> createState() => _QuantityMenuState();
}

class _QuantityMenuState extends State<QuantityMenu> {
  String selected = '1';
  @override
  Widget build(BuildContext context) {
    List<String> intList =
        List<String>.generate(widget.stock, (index) => '${index + 1}');
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        enableFeedback: true,
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
  final String uname;
  final double price;
  final String imageUrl;
  final String quantity;
  final double total;

  ShopList({
    required this.id,
    required this.name,
    required this.uname,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'uname': uname,
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
      uname: json['uname'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
    );
  }
}
