import 'package:flutter/material.dart';
import '../const.dart';

class BottomPositionedWidget extends StatelessWidget {
  final double lat;
  final double lng;
  final double spd;
  final double head;
  final double alt;

  BottomPositionedWidget({
    this.lat,
    this.lng,
    this.spd,
    this.head,
    this.alt,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      right: 0.0,
      left: 0.0,
      child: Container(
        color: Color(0xff333739),
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Garis Lintang',
              style: kTitleStyle,
            ),
            Text(
              '${lat.toStringAsFixed(4)}',
              style: kContentStyle,
            ),
            Text(
              'Garis Bujur',
              style: kTitleStyle,
            ),
            Text(
              '${lng.toStringAsFixed(4)}',
              style: kContentStyle,
            ),
            Text(
              'Kecepatan',
              style: kTitleStyle,
            ),
            Text(
              '${spd.toStringAsFixed(2)} km/jam',
              style: kContentStyle,
            ),
            Text(
              'Arah',
              style: kTitleStyle,
            ),
            Text(
              '${head.toStringAsFixed(2)}°',
              style: kContentStyle,
            ),
            Text(
              'Ketinggian',
              style: kTitleStyle,
            ),
            Text(
              '${alt.toStringAsFixed(2)} M',
              style: kContentStyle,
            ),
          ],
        ),
      ),
    );
  }
}
