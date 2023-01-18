import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tesis/pages/add_product.dart';
import '../widgets/user_cards.dart';

Stream<List<Products>> readProducts(String categorytext) {
  final String category = categorytext;
  if (category == 'Accesorios') {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: 'Accesorios')
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Products.fromJson(doc.data())).toList());
  } else if (category == 'Calzado') {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: 'Calzado')
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Products.fromJson(doc.data())).toList());
  } else if (category == 'Cuidado Personal') {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: 'Cuidado Personal')
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Products.fromJson(doc.data())).toList());
  } else if (category == 'Electrodoméstico') {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: 'Electrodoméstico')
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Products.fromJson(doc.data())).toList());
  } else {
    return FirebaseFirestore.instance
        .collection('products')
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Products.fromJson(doc.data())).toList());
  }
}

class UserShopPage extends StatefulWidget {
  const UserShopPage({super.key});

  @override
  State<UserShopPage> createState() => _UserShopPageState();
}

class _UserShopPageState extends State<UserShopPage> {
  final controllerCategory = TextEditingController();
  CategoryLabel? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<CategoryLabel>> categoryEntries =
        <DropdownMenuEntry<CategoryLabel>>[];
    for (final CategoryLabel category in CategoryLabel.values) {
      categoryEntries.add(DropdownMenuEntry<CategoryLabel>(
          value: category, label: category.label));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder<List<Products>>(
          stream: readProducts(controllerCategory.text),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Algo ha ocurrido! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final products = snapshot.data!;
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: DropdownMenu(
                        label: const Text('Categoria'),
                        controller: controllerCategory,
                        dropdownMenuEntries: categoryEntries,
                        initialSelection: CategoryLabel.todos,
                        onSelected: (CategoryLabel? category) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                        children: products
                            .map((p) => UserBuildShopCards(products: p))
                            .toList()),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

enum CategoryLabel {
  todos('Todos'),
  accesorios('Accesorios'),
  calzado('Calzado'),
  selfcare('Cuidado Personal'),
  electrodomestico('Electrodoméstico');

  const CategoryLabel(this.label);
  final String label;
}
