import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis/theme/theme_provider.dart';
import 'package:tesis/widgets/info_dialog.dart';

import '../provider/google_sign_in.dart';

Future openDialog(BuildContext context) => showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, setState) => Dialog(
          insetPadding: const EdgeInsets.all(28),
          backgroundColor: ElevationOverlay.applySurfaceTint(
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceTint,
              3),
          elevation: 3,
          child: Container(
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings,
                    color: Theme.of(context).colorScheme.secondary),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Configuración',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 24,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Tema: ',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Consumer<ThemeProvider>(
                          builder: (context, provider, child) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: ElevationOverlay.applySurfaceTint(
                                Theme.of(context).colorScheme.surface,
                                Theme.of(context).colorScheme.surfaceTint,
                                2),
                            iconEnabledColor:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            style: Theme.of(context).textTheme.labelLarge,
                            value: provider.currentTheme,
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'light',
                                child: Text('Claro'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'dark',
                                child: Text('Oscuro'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'system',
                                child: Text('Sistema'),
                              ),
                            ],
                            onChanged: (String? value) => {
                              provider.changeTheme(value ?? 'system'),
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                ElevatedButton(
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
                      title: const Text(
                        '¿Desea eliminar su cuenta?',
                        textAlign: TextAlign.center,
                      ),
                      content: const Text(
                        'Si presiona aceptar se eliminara todos los datos de su cuenta de manera permanente ¿Está seguro?',
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
                                  .collection('users')
                                  .doc(user.uid);
                              final docHistory = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('history')
                                  .get();
                              final docShoplist = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('shoplist')
                                  .get();
                              final provider =
                                  Provider.of<GoogleSignInProvider>(context,
                                      listen: false);

                              docHistory.then((querySnapshot) => {
                                    // ignore: avoid_function_literals_in_foreach_calls
                                    querySnapshot.docs.forEach((result) {
                                      result.reference.delete();
                                    })
                                  });
                              docShoplist.then((querySnapshot) => {
                                    // ignore: avoid_function_literals_in_foreach_calls
                                    querySnapshot.docs.forEach((result) {
                                      result.reference.delete();
                                    })
                                  });
                              docProducts
                                  .delete()
                                  .then((value) => provider.logout());
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Eliminar')),
                      ],
                    ),
                  ),
                  child: const Text(
                    'Eliminar permanentemente la cuenta',
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),
                    child: TextButton(
                      onPressed: (() {
                        Navigator.of(context).pop();
                      }),
                      child: Text(
                        'Hecho',
                        style: TextStyle(
                          wordSpacing: 0.5,
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
