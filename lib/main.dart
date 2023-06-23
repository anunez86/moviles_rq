//import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'QR Scanner App',
    theme: ThemeData(
      primaryColor: Colors.greenAccent,
      accentColor: Colors.greenAccent,
    ),
    home: QRScannerApp(),
  ));
}

class QRScannerApp extends StatefulWidget {
  @override
  _QRScannerAppState createState() => _QRScannerAppState();
}

class _QRScannerAppState extends State<QRScannerApp> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  bool scanning = true;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Escanear código QR'),
      ),
      body: Stack(
        children: [
          _buildQRView(context),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 5.0),
                borderRadius: BorderRadius.circular(60.0),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            scanning = !scanning;
            if (scanning) {
              controller.resumeCamera();
            } else {
              controller.pauseCamera();
            }
          });
        },
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(scanning ? Icons.stop : Icons.play_arrow),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      _launchURL(scanData.code);
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('No se pudo lanzar la URL: $url');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
