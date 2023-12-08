import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';

class SwitchInput extends StatefulWidget {
  final BluetoothConnection? bluetoothConnection;

  const SwitchInput({super.key, this.bluetoothConnection});

  @override
  State<StatefulWidget> createState() {
    return _SwitchInputState();
  }
}

class _SwitchInputState extends State<SwitchInput> {
  bool _unlocked = false;

  Future<void> _handleSwitch(bool value) async {
    if (widget.bluetoothConnection != null &&
        widget.bluetoothConnection!.isConnected) {
      if (value) {
        widget.bluetoothConnection!.output
            .add(Uint8List.fromList(utf8.encode("2")));
        await widget.bluetoothConnection!.output.allSent;
      } else {
        widget.bluetoothConnection!.output
            .add(Uint8List.fromList(utf8.encode("1")));
        await widget.bluetoothConnection!.output.allSent;
      }
      setState(() {
        _unlocked = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _unlocked ? "Unlocked" : "Locked",
          style: GoogleFonts.poppins(
              color: _unlocked ? Colors.green : Colors.red,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: 1),
        ),
        FlutterSwitch(
          value: _unlocked,
          onToggle: _handleSwitch,
          activeColor: Colors.green,
          inactiveColor: Colors.red,
        ),
      ],
    );
  }
}
