import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final user = FirebaseAuth.instance.currentUser!;
String role = '';

Stream<QuerySnapshot> readUsers() =>
    FirebaseFirestore.instance.collection('users').snapshots();
Future accDialog(BuildContext context) => showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, setState) => Dialog(
          child: Container(
            margin: const EdgeInsets.all(24),
            child: StreamBuilder(
              stream: readUsers(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Algo ha salido mal!');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Cargando");
                }
                return ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        roleFunction(String q) {
                          setState(() {
                            role = q;
                          });
                        }

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: Padding(
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
                                RichText(
                                  text: TextSpan(
                                      text: 'Correo: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                            text: data['email'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal)),
                                      ]),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: 'Rol: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                            text: data['role'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal)),
                                      ]),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: RoleMenu(
                                            roleFunction: roleFunction)),
                                    const Spacer(),
                                    ElevatedButton(
                                        onPressed: () {
                                          final setRole = <String, String>{
                                            'role': role,
                                          };
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(document.id)
                                              .set(setRole,
                                                  SetOptions(merge: true));
                                        },
                                        child: const Text('Guardar'))
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      })
                      .toList()
                      .cast(),
                );
              },
            ),
          ),
        ),
      ),
    );

class RoleMenu extends StatefulWidget {
  final Function roleFunction;
  const RoleMenu({super.key, required this.roleFunction});

  @override
  State<RoleMenu> createState() => _RoleMenuState();
}

const List<String> list = <String>['User', 'Admin'];

class _RoleMenuState extends State<RoleMenu> {
  String role = list.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: role,
        dropdownColor: ElevationOverlay.applySurfaceTint(
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceTint,
            2),
        iconEnabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
        style: Theme.of(context).textTheme.labelLarge,
        onChanged: (String? value) {
          setState(() {
            role = value!;
            widget.roleFunction(role);
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
