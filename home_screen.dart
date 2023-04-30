import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  BluetoothConnection? connection;
  bool isConnecting = true;

  bool get isConnected => connection != null && connection!.isConnected;

  void sendOnMessageToBluetooth() async {
    connection?.output.add(Uint8List.fromList(utf8.encode("1" "\r\n")));
    await connection?.output.allSent;
  }

  @override
  void dispose() {
    if (isConnected) {
      connection!.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var widthScreen = MediaQuery.of(context).size.width * 0.9;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Indicador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: RichText(
                text: const TextSpan(
                  text: '0.0',
                  style: TextStyle(fontSize: 100, color: Colors.black, fontWeight: FontWeight.normal),
                  children: <TextSpan>[
                    TextSpan(text: ' kg', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: widthScreen,
              child: ElevatedButton(
                onPressed: (){},
                child: const Text('Imprimir')
              ),
            )
          ],
        ),
      ),
    );
  }
}
