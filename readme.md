# Comunicacion flutter y arduino

Funciona con los dispositivos bluetooth que ya tiene emparejados el dispositivo. Son los que apareceran en el listado cuando presiones "buscar dispositivos".

## Archivos

- En tu proyecto solo agrega el codigo del archivo **configuration_screen.dart**
- El **main** solo dirige a este archivo
- Agrega las dependecias del archivo **pubspec.yaml**

## Componentes electronicos

- Arduino mega
- Modulo HC-05

**Importante:** Cambia la version minima del SDK a 19
  **minSdkVersion 19** ruta: android/app/build.gradle

Tambien puedes modificar el AndroidManifest.xml para que la orientacion no cambien de portrait android:screenOrientation="portrait"

**Nota:** El codigo de dart esta actualizado contra el video de youtube. Se añadio un TextField para poder enviar texto personalizado. Agregare imagenes una vez las actualice contra este codigo.

## Funcionamiento del codigo dart

Explicare las funcines que tiene, agregue un numero al inicio que representa el numero de la fila en la que esta.

### configuration_screen.dart

- Variables a utilizar

```dart
15 final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;   
  late BluetoothConnection connection;
  late List<BluetoothDevice> _devicesList;
  List<Map<String, String>> inComingData=[];
  bool devicesLoad=false;
  bool get isConnected => connection.isConnected;
  String deviceMacAddress="";
  String textFieldText = "";
```

- Funcion para obtebner los dispositivos emparejados al dispositivo. Tienes que llamarla de manera asyncrona con un await.

```dart
24 Future<List<BluetoothDevice>> getPairedDevices() async {
    List<BluetoothDevice> getDevicesList = [];
    try {
      getDevicesList = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }
    return getDevicesList;
  }
```

- Genera una SnackBar, mensaje flotante. Tienes que pasarle una cadena de texto.

```dart
34 void showSnackBar(String value){
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
```

- Busca los dispositivos emparejados llamando a la funcion **getPairedDevices()** y los resultados los almacena en una lista para facil manejo dentro de la vista grafica con el **147- ListView.builder**.

```dart
46 void searchDevices()async{
    _devicesList = await getPairedDevices();
    setState(() {
      _devicesList;
      devicesLoad=true;
    });
  }
```

- Cuando se llama esta funcion ... desconecta el dispositivo que este activo actualmente. Se agrego un setState para que actualice la vista grafica cambia de color a como estaba antes de conectarse al dispositivo.

```dart
54 void disconnectDevice(){
    setState(() {
      deviceMacAddress='';
      inComingData=[];
    });
    connection.close();
  }
```

- Cuando se llama esta funcion intenta la conexion con el dispositivo, si tiene exito entonces asigna la mac address a nuestra variable. Igual podrias usar un bool. Pero uso la mac address para compararla contra los dispositivos de la lista y cambiar de color el nombre del que se conecto.\
Despues manda a llamar a **listenForData()**.

```dart
62  void connectDevice(String address){
    BluetoothConnection.toAddress(address).then((conn) {
      connection = conn;
      setState(() {
        deviceMacAddress=address;
      });
      listenForData();
    });
  }
```

- Al momento de hacer la conexion con el dispositivo actomaticamente va a recibir los datos no es necesaria esta funcion. Pero la uso ya que quiero modificar y verificar los datos entrantes sino no lograba manejar los datos entrantes por stream.
Solo la debes mandar a llamar una vez. Sino va a  estar mostrando el menasaje de que ya esta escuchando.\
Los datos que yo le enviaban eran flotantes y dados por otro dispositivo no solo pasaban por el arduino, por ello queria vrificar el tiempo que tardaba esa transmision.

```dart
72  void listenForData(){
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
```

- Con esta funcion enviamos datos a travez de la conexion se envia lo que este almacenado en la variable de texto **textFieldText**.

```dart
95 void sendMessageBluetooth() async {
    print('sending data');
    showSnackBar('Enviando datos');
    if(isConnected){
      connection.output.add(Uint8List.fromList(utf8.encode("$textFieldText" "\r\n")));
      await connection.output.allSent;
    }else{
      disconnectDevice();
    }
  }
```

- dispose conexion

```dart
  @override
107 void dispose() {
    if (isConnected) {
      connection.dispose();
    }
    super.dispose();
  }
```

## Widget Build

Esta seccion...
