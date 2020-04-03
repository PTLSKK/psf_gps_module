import 'package:flutter/material.dart';

import '../const.dart';

class BottomInformationWidget extends StatelessWidget {
  final double lat;
  final double lng;
  final String jarak;
  final Function refreshFunction;
  final Function clearMapFunction;

  BottomInformationWidget(
      {this.jarak,
      this.refreshFunction,
      this.clearMapFunction,
      this.lat,
      this.lng});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60.0,
      right: 0.0,
      left: 0.0,
      child: Container(
        color: Color(0xff333739),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Jarak',
              style: kTitleStyle,
            ),
            Text(
              '$jarak',
              style: kContentStyle,
            ),
            Text(
              'Koordinat',
              style: kTitleStyle,
            ),
            Text(
              '${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)}',
              style: kContentStyle,
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: refreshFunction,
            ),
            IconButton(
              icon: Icon(Icons.clear),
              tooltip: 'Clear Map',
              onPressed: clearMapFunction,
            ),
          ],
        ),
      ),
    );
  }
}
