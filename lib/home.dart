import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tesis/pages/qrscan.dart';
import 'package:tesis/provider/google_sign_in.dart';
import 'package:tesis/widgets/info_dialog.dart';
import 'package:tesis/pages/shop.dart';
import 'package:tesis/pages/shop_list.dart';
import 'package:tesis/widgets/dialog.dart';

enum Item { itemOne, itemTwo, itemThree }

class Home extends StatefulWidget {
  final QRViewController? controller;
  const Home({Key? key, this.controller}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var currentPageIndex = 0;
  final pageController = PageController();

  void onTappedBar(int value) {
    setState(() {
      currentPageIndex = value;
    });
    pageController.jumpToPage(value);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Item? selectedMenu;
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Swift Store'),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Item>(
            position: PopupMenuPosition.under,
            initialValue: selectedMenu,
            onSelected: (Item item) {
              setState(() {
                selectedMenu = item;
                if (selectedMenu == Item.itemOne) {
                  infoDialog(context);
                } else if (selectedMenu == Item.itemTwo) {
                  openDialog(context);
                } else if (selectedMenu == Item.itemThree) {
                  final provider =
                      Provider.of<GoogleSignInProvider>(context, listen: false);
                  provider.logout();
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem<Item>(
                value: Item.itemOne,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.account_circle),
                    ),
                    Text(
                      'Información',
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<Item>(
                value: Item.itemTwo,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.settings),
                    ),
                    Text('Configuración'),
                  ],
                ),
              ),
              const PopupMenuItem<Item>(
                value: Item.itemThree,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.logout_outlined),
                    ),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
            child: CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL!),
            ),
          )
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (value) {
          setState(() {
            currentPageIndex = value;
          });
        },
        children: <Widget>[
          const ShopPage(),
          QRScanner(showTab2: (int index) {
            setState(() {
              setState(() {
                currentPageIndex = index;
                if (currentPageIndex == 2) {
                  pageController.animateToPage(2,
                      curve: Curves.easeIn,
                      duration: const Duration(milliseconds: 300));
                }
              });
            });
          }),
          ShopListPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 2,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: currentPageIndex,
        onDestinationSelected: onTappedBar,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Tienda',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Escáner',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
