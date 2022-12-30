import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final user = FirebaseAuth.instance.currentUser!;
Future infoDialog(BuildContext context) => showDialog(
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
                Icon(Icons.account_circle,
                    color: Theme.of(context).colorScheme.secondary),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Información',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'ID del Usuario: ${user.uid}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        'Nombre: ${user.displayName!}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        'Email: ${user.email!}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final userDoc = snapshot.data!.data();
                              return Text(
                                'Rol: ${(userDoc as Map<String, dynamic>)['role']}',
                                style: Theme.of(context).textTheme.labelLarge,
                              );
                            } else {
                              return const Text('Rol: Error');
                            }
                          }),
                      Text(
                        'Foto:',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
                Image.network(user.photoURL!),
                Container(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                    ),
                    child: TextButton(
                      onPressed: (() {
                        Navigator.of(context).pop();
                      }),
                      child: const Text(
                        'Cerrar',
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
