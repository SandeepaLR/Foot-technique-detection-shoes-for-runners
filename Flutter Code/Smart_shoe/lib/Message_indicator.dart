import 'package:flutter/material.dart';

class MessageIndicator extends StatelessWidget {
  final String? message_s;
  final Color? color;
  final String? _message;
  const MessageIndicator.connected({super.key, required this.message_s})
      : color = const Color.fromARGB(255, 70, 170, 107),
        _message = null;
  MessageIndicator.connecting({super.key})
      : message_s = null,
        _message = 'Connecting...',
        color = Colors.grey.shade300;
  const MessageIndicator.disconnected({super.key})
      : message_s = "1.0",
        _message = 'Disconnected',
        color = const Color.fromARGB(255, 131, 163, 141);
  const MessageIndicator.error({super.key})
      : message_s = "1.0",
        _message = 'Error',
        color = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 40, top: 10),
      child: Stack(
        children: [
          SizedBox(
              height: 300,
              width: 400,
              child: Card(
                color: color,
                child: Center(
                  child: Text(
                    _message != null
                        ? _message!
                        // : '${((message_s ?? 0) * 100).toStringAsFixed(0)}%',
                        : message_s.toString(),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              )),
          // Text((message_s).toString(), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
