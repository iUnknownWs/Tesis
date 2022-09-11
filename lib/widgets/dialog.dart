import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis/theme/theme_provider.dart';

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
                        'Tema',
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
                )
              ],
            ),
          ),
        ),
      ),
    );
