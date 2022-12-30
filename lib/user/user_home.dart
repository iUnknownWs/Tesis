import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tesis/pages/qrscan.dart';
import 'package:tesis/provider/google_sign_in.dart';
import 'package:tesis/user/user_shop.dart';
import 'package:tesis/widgets/info_dialog.dart';
// import 'package:tesis/widgets/qrscan.dart';
import 'package:tesis/pages/shop_list.dart';
import 'package:tesis/widgets/dialog.dart';

class UserHome extends StatefulWidget {
  final QRViewController? controller;
  const UserHome({Key? key, this.controller}) : super(key: key);

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
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
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Asistente'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
              position: PopupMenuPosition.under,
              // color: ElevationOverlay.applySurfaceTint(
              //     Theme.of(context).colorScheme.surface,
              //     Theme.of(context).colorScheme.surfaceTint,
              //     2),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              constraints: const BoxConstraints(
                minWidth: 112,
                maxWidth: 280,
              ),
              iconSize: 30,
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL!),
              ),
              // icon: const Icon(Icons.account_circle_outlined),
              itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      child: ListTile(
                        iconColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        leading: const Icon(Icons.settings),
                        onTap: (() {
                          Navigator.pop(context);
                          openDialog(context);
                        }),
                        title: Text(
                          'Configuración',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        iconColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        leading: const Icon(Icons.account_circle),
                        onTap: (() {
                          Navigator.pop(context);
                          infoDialog(context);
                        }),
                        title: Text(
                          'Información',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        iconColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        leading: const Icon(Icons.logout_outlined),
                        onTap: (() {
                          final provider = Provider.of<GoogleSignInProvider>(
                              context,
                              listen: false);
                          provider.logout();
                          Navigator.pop(context);
                        }),
                        title: Text(
                          'Cerrar Sesión',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ])
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
          const UserShopPage(),
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
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Escaner',
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
