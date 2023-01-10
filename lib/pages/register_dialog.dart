import 'package:flutter/material.dart';

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  bool _visibility = true;
  bool visibility = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        title: const Text('Formulario de Registro'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Guardar"))
        ],
      ),
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
                  'Nombre Completo',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Nombres',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.badge,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Apellidos',
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
                  'Numero de Telefono',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    prefixText: '+58 4',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.phone,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Correo Electronico',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Ejemplo@mail.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.email,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Contraseña',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  obscureText: _visibility,
                  decoration: InputDecoration(
                    hintText: 'Introduzca su contraseña',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        icon: Icon(
                          _visibility ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              _visibility = !_visibility;
                            },
                          );
                        }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Confirmar contraseña',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  obscureText: visibility,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        icon: Icon(
                          visibility ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              visibility = !visibility;
                            },
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
