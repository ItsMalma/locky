import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:locky/speech.dart';
import 'package:locky/switch.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? _bluetoothConnection;

  bool _useSpeech = false;

  Future<void> _handleBluetooth() async {
    if (await Permission.bluetooth.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      if (_bluetoothConnection == null) {
        if (await FlutterBluetoothSerial.instance.requestEnable() != true) {
          return;
        }
        BluetoothConnection.toAddress("00:22:06:01:BF:01").then((conn) {
          setState(() {
            _bluetoothConnection = conn;
          });
        });
      } else {
        if (await FlutterBluetoothSerial.instance.requestDisable() != true) {
          return;
        }
        setState(() {
          _bluetoothConnection = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    Permission.bluetooth.request().then((status) {
      if (status.isGranted) {
        FlutterBluetoothSerial.instance.state.then((state) {
          setState(() {
            _bluetoothState = state;
          });
        });

        FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
          print(state);
          setState(() {
            _bluetoothState = state;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "LOCKY",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 28,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.616,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleBluetooth,
            iconSize: 40,
            icon: Icon(
              Icons.bluetooth,
              color: _bluetoothConnection != null &&
                      _bluetoothConnection!.isConnected &&
                      _bluetoothState == BluetoothState.STATE_ON
                  ? Colors.blue
                  : Colors.black54,
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _useSpeech
                ? SpeechInput(
                    bluetoothConnection: _bluetoothConnection,
                  )
                : SwitchInput(
                    bluetoothConnection: _bluetoothConnection,
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _useSpeech = !_useSpeech;
          });
        },
        foregroundColor: _useSpeech ? Colors.blue : Colors.black54,
        backgroundColor: Colors.white,
        child: const Icon(Icons.mic),
      ),
    );
  }
}
