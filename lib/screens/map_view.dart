import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps_maps/states/app_state.dart';
import 'package:gps_maps/widgets/bottom_information_widget.dart';
import 'package:gps_maps/widgets/bottom_positioned_widget.dart';
import 'package:gps_maps/widgets/positioned_widget.dart';
import 'package:provider/provider.dart';

import '../const.dart';

class MapsView extends StatefulWidget {
  @override
  _MapsViewState createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: appState.initialPosition == null
              ? Center(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 12.0,
                        ),
                        Text(
                          'Loading',
                          style: kContentStyle,
                        )
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: <Widget>[
                    GoogleMap(
                      onMapCreated: appState.onCreated,
                      markers: Set<Marker>.of(appState.markers.values),
                      polylines: appState.polyLines,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      myLocationEnabled: true,
                      onTap: (position) {
                        appState.changeVisibility();
                      },
                      initialCameraPosition: CameraPosition(
                        target: appState.initialPosition,
                        zoom: 18.0,
                      ),
                    ),
                    Positioned(
                      top: 30.0,
                      right: MediaQuery.of(context).size.width * 0.8,
                      left: 0.0,
                      child: Image.asset(
                        'images/lskk_logo.png',
                        width: 70.0,
                        height: 70.0,
                      ),
                    ),
                    Positioned(
                      top: 30.0,
                      right: 0.0,
                      left: MediaQuery.of(context).size.width * 0.8,
                      child: Image.asset(
                        'images/pussen.png',
                        width: 70.0,
                        height: 70.0,
                      ),
                    ),
                    PositionedWidget(
                      isHide: appState.isHide,
                      appState: appState.locationController,
                      top: 25.0,
                      hintText: 'Asal',
                      icon: Icon(
                        Icons.location_on,
                        color: Colors.black,
                      ),
                    ),
                    PositionedWidget(
                      isHide: appState.isHide,
                      appState: appState.destinationController,
                      top: 85.0,
                      hintText: 'Tujuan',
                      icon: Icon(
                        Icons.local_taxi,
                        color: Colors.black,
                      ),
                      onTapFunction: () async {
                        await appState.showNotification(context);
                      },
                      onSubmitFunction: (value) {
                        print('we got submitted');
                        appState.sendRequest(value);
                      },
                    ),
                    BottomInformationWidget(
                      jarak: appState.distance,
                      refreshFunction: appState.refreshMap,
                      clearMapFunction: appState.clearAll,
                      lat: appState.lat,
                      lng: appState.lng,
                    ),
                    BottomPositionedWidget(
                      alt: appState.alt,
                      lat: appState.lat,
                      lng: appState.lng,
                      head: appState.head,
                      spd: appState.spd,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
