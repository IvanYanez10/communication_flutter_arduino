import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);
  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {

  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  late BluetoothConnection connection;
  late List<BluetoothDevice> _devicesList;
  List<Map<String, String>> inComingData=[];
  bool devicesLoad=false;
  bool get isConnected => connection.isConnected;
  String deviceMacAddress="";
  String textFieldText = "";

  Future<List<BluetoothDevice>> getPairedDevices() async {
    List<BluetoothDevice> getDevicesList = [];
    try {
      getDevicesList = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }
    return getDevicesList;
  }

  void showSnackBar(String value){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        margin: const EdgeInsets.all(50),
        elevation: 1,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void searchDevices()async{
    _devicesList = await getPairedDevices();
    setState(() {
      _devicesList;
      devicesLoad=true;
    });
  }

  void disconnectDevice(){
    setState(() {
      deviceMacAddress='';
      inComingData=[];
    });
    connection.close();
  }

  void connectDevice(String address){
    BluetoothConnection.toAddress(address).then((conn) {
      connection = conn;
      setState(() {
        deviceMacAddress=address;
      });
      listenForData();
    });
  }

  void listenForData(){
    connection.input!.listen((Uint8List data) {
      String serialData = ascii.decode(data);
      serialData=serialData.substring(0,serialData.indexOf('.')+2);
      showSnackBar('Recibiendo datos');
      setState(() {
        inComingData.insert(0,
          {
            "time": DateFormat('hh:mm:ss:S').format(DateTime.now()),
            "data": serialData
          });
      });
      print('Data incoming: $serialData');
      connection.output.add(data);
      if (ascii.decode(data).contains('!')) {
        connection.finish();
        print('Disconnecting by local host');
      }
    }).onDone(() {
      print('Disconnected by remote request');
    });
  }

  void sendMessageBluetooth() async {
    print('sending data');
    showSnackBar('Enviando datos');
    if(isConnected){
      connection.output.add(Uint8List.fromList(utf8.encode("$textFieldText" "\r\n")));
      await connection.output.allSent;
    }else{
      disconnectDevice();
    }
  }

  @override
  void dispose() {
    if (isConnected) {
      connection.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var widthScreen = MediaQuery.of(context).size.width * 0.9;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text('Comunicacion datos serie'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: widthScreen,
                child: ElevatedButton(
                  onPressed: ()=> searchDevices(),
                  child: const Text('Buscar dispositivos')
                )
              ),
              if(devicesLoad && _devicesList.isNotEmpty) Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                ),
                height: 200,
                width: widthScreen,
                child:
                ListView.builder(
                  physics: _devicesList.length < 3 ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                  itemCount: _devicesList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => deviceMacAddress!=_devicesList[index].address.toString() ? connectDevice(_devicesList[index].address.toString()) : disconnectDevice(),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _devicesList[index].name.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: deviceMacAddress!=_devicesList[index].address.toString() ? Colors.blue : Colors.green
                            ),
                          ),
                          Text(
                              _devicesList[index].address.toString(),
                              style: const TextStyle(fontWeight: FontWeight.w300)
                          )
                        ],
                      ),
                      subtitle: deviceMacAddress!=_devicesList[index].address.toString() ? const Text("Clic para conectar") : const Text('Clic para desconectar'),
                    );
                  },
                )
              ),
              if(deviceMacAddress.isNotEmpty) Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  maxLength: 40,
                  onChanged: (value){
                    if(value.isNotEmpty){
                      textFieldText = value;
                    }else{
                      textFieldText = 'rawData';
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Envia texto personalizado'
                  )
                ),
              ),
              SizedBox(
                width: widthScreen,
                child: ElevatedButton(
                  onPressed: deviceMacAddress.isNotEmpty ? () => sendMessageBluetooth() : null,
                  child: const Text('Enviar texto')
                ),
              ),
              if(deviceMacAddress.isNotEmpty)const Padding(
                padding: EdgeInsets.only(top:10.0),
                child: Text('Datos entrantes'),
              ),
              if(deviceMacAddress.isNotEmpty)Container(
                width: widthScreen,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                ),
                child: ListView.builder(
                  physics: inComingData.length < 4 ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  itemCount: inComingData.length,
                  itemBuilder: (ctx, i){
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                      child: RichText(
                        text: TextSpan(
                          text: '${inComingData[i]['time']}   ',
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                          children: <TextSpan>[
                            TextSpan(
                              text: inComingData[i]['data'],
                              style: const TextStyle(color: Colors.black, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    );
                  }),
              ),
              Center(
                child: RichText(
                  text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'github.com/',
                      style: TextStyle(
                        color: Colors.black26,
                        fontSize: 10
                      ),
                    ),
                    TextSpan(
                      text: 'IvanYanez10/',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11
                      ),
                    ),
                  ],
                ),
              )
            )],
          ),
        ),
      ),
    );
  }
}
