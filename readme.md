# Comunicacion flutter y arduino

Funciona con los dispositivos bluetooth que ya tiene emparejados el dispositivo. Son los que apareceran en el listado cuando presiones "buscar dispositivos".
- Arduino mega
- Modulo HC-05

Cambia la version minima del SDK a 19
    minSdkVersion 19
    ruta: android/app/build.gradle

dependencies  pubspec.yaml
    flutter_bluetooth_serial: ^0.4.0

Tambien puedes modificar el AndroidManifest.xml para que la orientacion no cambien de portrait
    android:screenOrientation="portrait"
