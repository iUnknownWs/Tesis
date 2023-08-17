import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Stream<QuerySnapshot> readSells() => FirebaseFirestore.instance
    .collection('reports')
    .orderBy('name')
    .snapshots();

class SellReports extends StatelessWidget {
  const SellReports({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ventas'),
      ),
      body: StreamBuilder(
        stream: readSells(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Algo salio mal!');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return ListView(
            children: snapshot.data!.docs
                .map(
                  (DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return Card(
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 140),
                            child: CachedNetworkImage(
                              imageUrl: data['imageUrl'],
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  data['name'],
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Comprador: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(data['uname'])
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Precio: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(data['price'].toString())
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Cantidad: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(data['quantity'])
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(data['total'].toString())
                                  ],
                                ),
                                // Text('Precio: ${shopList.price}\$'),
                                // Text('Cantidad: ${shopList.quantity}')
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                )
                .toList()
                .cast(),
          );
        },
      ),
    );
  }
}
