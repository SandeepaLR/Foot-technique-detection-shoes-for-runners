import 'dart:async';
import 'package:flutter/material.dart';
import 'my_home_page.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Countdown extends StatefulWidget {
  const Countdown({super.key});

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  @override
  void initState() {
    super.initState();
    _countdown();
  }

  int timerLeft = 5;
  double presentage = 0.00;
  void _countdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timerLeft > 0) {
          timerLeft--;
          presentage = (timerLeft / 5);
        } else {
          timer.cancel();
          Navigator.of(context).pushNamed("/myhome");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: new CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 10.0,
            percent: presentage,
            center: timerLeft == 0
                ? Text(
                    "Run!",
                    style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 8, 162, 6)),
                  )
                : Text(
                    timerLeft.toString(),
                    style: TextStyle(fontSize: 54, fontWeight: FontWeight.w600),
                  ),
            progressColor: Color.fromARGB(255, 8, 162, 6),
          ),
        )
      ],
    ));
  }
}
