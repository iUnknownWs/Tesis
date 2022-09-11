import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tesis/pages/add_product.dart';
import 'package:tesis/widgets/qr_cards.dart';

class QRScanner extends StatefulWidget {
  final Function showTab2;
  const QRScanner({Key? key, required this.showTab2}) : super(key: key);

  @override
  State<StatefulWidget> createState() => QRScannerState();
}

class QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  int index = 1;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  callback(int confirm) {
    setState(() {
      setState(() {
        index = confirm;
      });
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: buildQrView(context)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.center,
              height: 100,
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: ElevatedButton(
                        onPressed: () async {
                          await controller?.toggleFlash();
                          setState(() {});
                        },
                        child: FutureBuilder(
                          future: controller?.getFlashStatus(),
                          builder: (context, snapshot) {
                            if (snapshot.data == true) {
                              return const Icon(Icons.flash_on);
                            } else {
                              return const Icon(Icons.flash_off);
                            }
                            // Text('Flash: ${snapshot.data}');
                          },
                        )),
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(37, 0, 0, 0)),
                  if (result != null)
                    Text('ID:${result!.code}')
                  else
                    const Text('Escanee el QR del producto'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.white,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => onPermissionSet(context, ctrl, p),
    );
  }

  void onQRViewCreated(QRViewController controller) {
    index = 1;
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      controller.pauseCamera();
      Stream<List<Products>> readProducts() => FirebaseFirestore.instance
          .collection('products')
          .where('id', isEqualTo: result!.code)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Products.fromJson(doc.data()))
              .toList());

      Future<bool> onWillPop() async {
        return false;
      }

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => WillPopScope(
          onWillPop: () async => false,
          child: WillPopScope(
            onWillPop: onWillPop,
            child: Dialog(
              insetPadding: const EdgeInsets.all(8),
              child: StreamBuilder<List<Products>>(
                  stream: readProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Algo ha ocurrido! ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final products = snapshot.data!;
                      return Container(
                        margin: const EdgeInsets.all(8),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: products
                                .map((p) => BuildQRCards(
                                      products: p,
                                      controller: controller,
                                      callback: callback,
                                    ))
                                .toList()),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
          ),
        ),
      ).then((value) => widget.showTab2(index));
    });
  }

  void onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
