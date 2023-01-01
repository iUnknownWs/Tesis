import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProductDialog extends StatefulWidget {
  const ProductDialog({super.key});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  final controllerName = TextEditingController();
  final controllerPrice = TextEditingController();
  final controllerCategory = TextEditingController();
  CategoryLabel? selectedCategory;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future createProduct(
      {required String name,
      required String category,
      required double price}) async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() => null);
    final imageUrl = await snapshot.ref.getDownloadURL();

    setState(() {
      uploadTask = null;
    });

    final docProducts = FirebaseFirestore.instance.collection('products').doc();

    final products = Products(
      id: docProducts.id,
      name: name,
      price: price,
      category: category,
      imageUrl: imageUrl,
    );
    final json = products.toJson();

    await docProducts.set(json).then(
          (value) => showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'El producto se ha añadido a la base de datos correctamente',
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

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
            return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green,
                  ),
                  Center(
                    child: Text(
                      '${(100 * progress).roundToDouble()}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            );
          } else {
            return const SizedBox(height: 50);
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<CategoryLabel>> categoryEntries =
        <DropdownMenuEntry<CategoryLabel>>[];
    for (final CategoryLabel category in CategoryLabel.values) {
      categoryEntries.add(DropdownMenuEntry<CategoryLabel>(
          value: category, label: category.label));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          title: const Text('Añadir un producto'),
          actions: [
            TextButton(
                onPressed: () {
                  final name = controllerName.text;
                  final price = double.parse(controllerPrice.text);
                  final category = controllerCategory.text;
                  createProduct(name: name, price: price, category: category)
                      .then((value) => Navigator.pop(context));
                },
                child: const Text("Añadir"))
          ]),
      body: ListView(children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Nombre del Producto',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: controllerName,
                  decoration: const InputDecoration(
                    hintText: 'Inserte el Nombre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.badge,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Precio',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: controllerPrice,
                  decoration: const InputDecoration(
                    hintText: 'Insterte el precio',
                    suffixText: '\$',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.attach_money,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Categoria',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownMenu(
                    controller: controllerCategory,
                    dropdownMenuEntries: categoryEntries,
                    onSelected: (CategoryLabel? category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Foto del Producto',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: selectFile,
                  label: const Text('Seleccionar Imagen'),
                  icon: const Icon(
                    Icons.image,
                  ),
                ),
              ),
              if (pickedFile != null)
                Container(
                  color: Colors.purple[100],
                  child: Image.file(
                    File(pickedFile!.path!),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              buildProgress(),
            ],
          ),
        ),
      ]),
    );
  }
}

class Products {
  String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;

  Products({
    this.id = '',
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
        'imageUrl': imageUrl,
      };

  static Products fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      category: json['category'],
      imageUrl: json['imageUrl'],
    );
  }
}

enum CategoryLabel {
  accesorios('Accesorios'),
  calzado('Calzado'),
  selfcare('Cuidado Personal'),
  electrodomestico('Electrodoméstico');

  const CategoryLabel(this.label);
  final String label;
}
