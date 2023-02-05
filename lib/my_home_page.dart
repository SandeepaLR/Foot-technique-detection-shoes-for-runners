import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smart_shoes/bluetooth_devices.dart';
import 'package:smart_shoes/Message_indicator.dart';

int button_state = 1;

enum BluetoothConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key, required this.title, required this.callBackfunction});
  final int callBackfunction;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    if (widget.callBackfunction == 1) {
      startTimmer();
    }
  }

  BluetoothConnectionState _btStatus = BluetoothConnectionState.disconnected;
  BluetoothConnection? connection;
  String _messageBuffer = '';
  String? messageValue;
  String? messageVal;
  bool _isWatering = false;
  String hourString = "00", minuteString = "00", secondString = "00";
  int hour = 0, minute = 0, second = 0;
  late Timer _timer;
  bool isTimerRunning = false;
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    var message = '';
    if (~index != 0) {
      message = backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString.substring(0, index);
      _messageBuffer = dataString.substring(index);
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    // analog 10 bit
    if (message.isEmpty) return; // to avoid fomrmat exception

    setState(() {
      messageValue = message.trim();
    });
  }

  showOverlay(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);

    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: 834,
              width: double.infinity,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Image(
                image: AssetImage("lib/assets/images/giphy.gif"),
              )),
        ],
      );
    });
    overlayState?.insert(overlayEntry);
    await Future.delayed(Duration(seconds: 6));
    startTimmer();
    overlayEntry.remove();
  }

  void _startSecond() {
    setState(() {
      if (second < 59) {
        second++;
        if (second < 10) {
          secondString = "0" + second.toString();
        } else {
          secondString = second.toString();
        }
      } else {
        _startMinute();
      }
    });
  }

  void _startMinute() {
    setState(() {
      second = 0;
      secondString = "00";
      if (minute < 59) {
        minute++;
        if (minute < 10) {
          minuteString = "0" + minute.toString();
        } else {
          minuteString = minute.toString();
        }
      } else {
        _startHour();
      }
    });
  }

  void _startHour() {
    setState(() {
      minute = 0;
      minuteString = "00";
      hour++;
      if (hour < 10) {
        hourString = "0" + hour.toString();
      } else {
        hourString = hour.toString();
      }
    });
  }

  void startTimmer() {
    setState(() {
      isTimerRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _startSecond();
    });
  }

  void stopTimmer() {
    setState(() {
      isTimerRunning = false;
      hourString = "00";
      minuteString = "00";
      secondString = "00";
      hour = 0;
      minute = 0;
      second = 0;
    });
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color.fromARGB(255, 4, 151, 58),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_bluetooth,
              color: Colors.white,
            ),
            onPressed: () async {
              BluetoothDevice? device = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BluetoothDevices()));

              if (device == null) return;

              print('Connecting to device...');
              setState(() {
                _btStatus = BluetoothConnectionState.connecting;
              });

              BluetoothConnection.toAddress(device.address).then((_connection) {
                print('Connected to the device');
                connection = _connection;
                setState(() {
                  _btStatus = BluetoothConnectionState.connected;
                });

                connection!.input!.listen(_onDataReceived).onDone(() {
                  setState(() {
                    _btStatus = BluetoothConnectionState.disconnected;
                  });
                });
              }).catchError((error) {
                print('Cannot connect, exception occured');
                print(error);

                setState(() {
                  _btStatus = BluetoothConnectionState.error;
                });
              });
            },
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Builder(
              builder: (context) {
                switch (_btStatus) {
                  case BluetoothConnectionState.disconnected:
                    return const MessageIndicator.disconnected();
                  case BluetoothConnectionState.connecting:
                    return MessageIndicator.connecting();
                  case BluetoothConnectionState.connected:
                    return isTimerRunning
                        ? MessageIndicator.connected(
                            message_s: messageValue,
                          )
                        : MessageIndicator.connected(
                            message_s: "Connected",
                          );

                  case BluetoothConnectionState.error:
                    return const MessageIndicator.error();
                }
              },
            ),
            const Spacer(),
            SizedBox(
              child: Text(
                "$hourString:$minuteString:$secondString",
                style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 4, 151, 58)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: isTimerRunning
                        ? Color.fromARGB(255, 255, 3, 3)
                        : Color.fromARGB(255, 4, 151, 58)),
                onPressed: () {
                  if (_btStatus == BluetoothConnectionState.disconnected) {
                    null;
                  } else {
                    if (isTimerRunning) {
                      stopTimmer();
                    } else {
                      showOverlay(context);
                    }
                  }
                },
                child: Text(
                  isTimerRunning ? 'STOP' : 'START',
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255), fontSize: 18),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
