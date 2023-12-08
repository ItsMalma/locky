import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechInput extends StatefulWidget {
  final BluetoothConnection? bluetoothConnection;

  const SpeechInput({super.key, this.bluetoothConnection});

  @override
  State<StatefulWidget> createState() {
    return _SpeechInputState();
  }
}

class _SpeechInputState extends State<SpeechInput> {
  String _recognizedWords = "";
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();

    _speechToText.initialize().then((value) {
      setState(() {
        _speechEnabled = value;
      });
    });
  }

  Future<void> _handleListen() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    } else {
      await _speechToText.listen(onResult: _onSpeechResult, localeId: "in_ID");
    }
  }

  Future<void> _onSpeechResult(
    SpeechRecognitionResult speechRecognitionResult,
  ) async {
    setState(() {
      _recognizedWords = speechRecognitionResult.recognizedWords;
    });
    if (widget.bluetoothConnection != null &&
        widget.bluetoothConnection!.isConnected) {
      switch (speechRecognitionResult.recognizedWords.toLowerCase()) {
        case "buka":
        case "unlock":
        case "open":
          widget.bluetoothConnection!.output
              .add(Uint8List.fromList(utf8.encode("2")));
          await widget.bluetoothConnection!.output.allSent;
          break;
        case "tutup":
        case "lock":
        case "close":
          widget.bluetoothConnection!.output
              .add(Uint8List.fromList(utf8.encode("1")));
          await widget.bluetoothConnection!.output.allSent;
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black87, width: 2),
            color: Colors.transparent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: _handleListen,
            icon: Icon(
              Icons.mic,
              color: _speechToText.isListening ? Colors.blue : Colors.black87,
            ),
            color: _speechToText.isListening ? Colors.blue : Colors.black87,
          ),
        ),
        Text(
          _recognizedWords,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        if (!_speechEnabled)
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text(
              "Speech not allowed",
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }
}
