import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps_maps/const.dart';
import 'package:gps_maps/models/location_data.dart';
import 'package:gps_maps/setup_locator.dart';
import 'package:gps_maps/states/mqtt_wrapper.dart';
import 'package:gps_maps/utils/google_maps_request.dart';

class AppState with ChangeNotifier {
  bool locationServiceActive = true;
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _speed = 0.0;
  double _altitude = 0.0;
  double _heading = 0.0;
  bool _isHide = true;
  String _mapStyle;
  String _distance = '0.0';
  List<LatLng> polylineCoordinates = [];

  static LatLng _initialPosition;
  Map<String, Marker> _markers = <String, Marker>{};
  final Set<Polyline> _polyLines = {};
  LatLng _lastPosition = _initialPosition;
  GoogleMapController _mapController;
  StreamSubscription<Position> positionStream;
  GoogleMapServices _googleMapsServices = GoogleMapServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  String get distance => _distance;
  double get lat => _latitude;
  double get lng => _longitude;
  double get spd => _speed * 3.6;
  double get alt => _altitude;
  double get head => _heading;
  bool get isHide => _isHide;
  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  GoogleMapServices get googleMapServices => _googleMapsServices;
  GoogleMapController get googleMapController => _mapController;
  Map<String, Marker> get markers => _markers;
  Set<Polyline> get polyLines => _polyLines;

  PolylinePoints polylinePoints = PolylinePoints();

  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDoatvCjV_WztUKGOplkDq5p9r-mwFyv_M');

  var mqttServices = locator<MqttWrapper>();

  StreamController<UserLocation> locationStream =
      StreamController<UserLocation>.broadcast();

  void disposeState() {
    positionStream.cancel();
  }

  Future<void> initializationProcess() async {
    mqttServices.prepareMqttClient();

    _getUserLocation();
    _changeMapStyle();
    _addGarageMarker();
  }

  void getStreamLocation() {
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.bestForNavigation);

    positionStream = geolocator.getPositionStream(locationOptions).listen(
      (Position position) async {
        locationStream.add(
          UserLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            altitude: position.altitude,
            heading: position.heading,
            speed: position.speed,
          ),
        );
      },
    );
  }

  // ! GET USER LOCATION
  Future _getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    LatLng pos = LatLng(position.latitude, position.longitude);
    var reverseGeocoding = await _googleMapsServices.getReverseGeocoding(pos);
    // List<Placemark> placemark = await Geolocator()
    //     .placemarkFromCoordinates(position.latitude, position.longitude);
    _initialPosition = LatLng(position.latitude, position.longitude);
    locationController.text = reverseGeocoding;
    print('reverse geocoding $reverseGeocoding');
    print('pos $pos');
    // var pos = LatLng(position.latitude, position.longitude);
    // _addCarMarker(pos);
    notifyListeners();
    _getStreamLocation();
  }

  void _getStreamLocation() {
    var geoLocator = Geolocator();
    var locationOptions = LocationOptions(
        accuracy: LocationAccuracy.bestForNavigation, timeInterval: 500);

    positionStream = geoLocator.getPositionStream(locationOptions).listen(
      (Position position) async {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _speed = position.speed;
        _altitude = position.altitude;
        _heading = position.heading;

        var tempSpeed = _speed * 3.6;

        if (tempSpeed >= 10) {
          print('masuk ke speed 10');

          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 19.0,
                tilt: 45.0,
                bearing: _heading,
              ),
            ),
          );
        }

        notifyListeners();

        var msg = "$_latitude#$_longitude#$_speed#$_altitude#$_heading";

        mqttServices.publishMessage(topicPosition, msg);
      },
    );
  }

  Future<void> drawRoute(double originLat, double originLong, double destLat,
      double destLong) async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        apiKey, originLat, originLong, destLat, destLong);

    if (result.isNotEmpty) {
      result.forEach(
        (point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        },
      );

      _polyLines.clear();

      _polyLines.add(
        Polyline(
          polylineId: PolylineId('polyLine'),
          width: 2,
          points: polylineCoordinates,
          color: Colors.yellow,
        ),
      );

      notifyListeners();
    }
  }

  // ! TO CREATE ROUTE
  void createRoute(String encodedPoly) {
    _polyLines.clear();

    _polyLines.add(
      Polyline(
        polylineId: PolylineId(_lastPosition.toString()),
        width: 6,
        points: _convertToLatLng(_decodePoly(encodedPoly)),
        color: Colors.yellow,
      ),
    );

    notifyListeners();
  }

  void clearAll() {
    _polyLines.clear();
    _markers.remove("location");
    destinationController.clear();
    _distance = '0.0KM';
    notifyListeners();
  }

  Future showNotification(BuildContext context) async {
    try {
      Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: 'AIzaSyDoatvCjV_WztUKGOplkDq5p9r-mwFyv_M',
        mode: Mode.fullscreen, // Mode.fullscreen
        language: "id",
        components: [new Component(Component.country, "id")],
        onError: (p) {
          Fluttertoast.showToast(
            msg: "ERROR ${p.errorMessage}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            fontSize: 16.0,
          );
        },
      );

      PlacesDetailsResponse response =
          await _places.getDetailsByPlaceId(p.placeId);

      var result =
          response.result.name + ', ' + response.result.formattedAddress;

      destinationController.text = result;

      sendRequest(result);
    } catch (e) {
      print('error $e');
      Fluttertoast.showToast(
        msg: "ERROR ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        fontSize: 16.0,
      );
    }
  }

  Future refreshMap() async {
    clearAll();

    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    LatLng pos = LatLng(position.latitude, position.longitude);
    var reverseGeocoding = await _googleMapsServices.getReverseGeocoding(pos);
    // List<Placemark> placemark = await Geolocator()
    //     .placemarkFromCoordinates(position.latitude, position.longitude);
    _initialPosition = LatLng(position.latitude, position.longitude);
    locationController.text = reverseGeocoding;
    // var pos = LatLng(position.latitude, position.longitude);
    // _addCarMarker(pos);
    notifyListeners();
    print('refresh the maps');
  }

  // ! ADD CAR MARKER
  Future _addGarageMarker() async {
    var pos = LatLng(-6.906854, 107.630900);
    final garageMarker = Marker(
      markerId: MarkerId('GarageMarker'),
      position: pos,
      infoWindow: InfoWindow(
        title: 'Pussenif BDG',
        snippet: 'Lat: ${pos.latitude} Lng: ${pos.longitude}',
      ),
    );

    _markers["GarageMarker"] = garageMarker;

    notifyListeners();
  }

  // ! ADD CAR MARKER
  // Future _addCarMarker(LatLng pos) async {
  //   final Uint8List markerIcon =
  //       await getBytesFromAsset('images/model.png', 80);

  //   final carMarker = Marker(
  //     markerId: MarkerId('CarMarker'),
  //     position: pos,
  //     icon: BitmapDescriptor.fromBytes(markerIcon),
  //     infoWindow: InfoWindow(
  //       title: 'Main Car',
  //       snippet: 'Lat: ${pos.latitude} Lng: ${pos.longitude}',
  //     ),
  //   );

  //   _markers["CarMarker"] = carMarker;

  //   notifyListeners();
  // }

  // Future _updateCarMarker(LatLng pos) async {
  //   Marker marker = _markers["CarMarker"];
  //   _markers["CarMarker"] = marker.copyWith(
  //     positionParam: pos,
  //     infoWindowParam: InfoWindow(
  //       title: 'Main Car',
  //       snippet: 'Lat: ${pos.latitude} Lng: ${pos.longitude}',
  //     ),
  //   );

  //   notifyListeners();
  // }

  // ! ADD A MARKER ON THE MAP
  Future _addMarker(LatLng location, String address) async {
    _markers.remove("location");

    Marker marker = Marker(
      markerId: MarkerId(_lastPosition.toString()),
      position: location,
      infoWindow: InfoWindow(
          title: address,
          snippet:
              'Latitude: ${location.latitude}, Longitude: ${location.longitude}'),
    );

    _markers["location"] = marker;

    notifyListeners();
  }

  // ! CREATE LatLng LIST
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];

    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }

    return result;
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;

    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negative then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /* adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    return lList;
  }

  // ! SEND REQUEST
  void sendRequest(String intendedLocation) async {
    LatLng destination = await getGeocoding(intendedLocation);
    String dest = intendedLocation.replaceAll(RegExp(' '), '+');
    String status =
        await _googleMapsServices.getRouteStatus(_initialPosition, dest);

    if (status == 'OK') {
      var distance =
          await _googleMapsServices.getDistance(_initialPosition, dest);

      _addMarker(destination, intendedLocation);

      String route =
          await _googleMapsServices.getRouteCoordinates(_initialPosition, dest);

      createRoute(route);

      Fluttertoast.showToast(
        msg: "RUTE ${intendedLocation.toUpperCase()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        fontSize: 16.0,
      );

      _distance = distance;

      notifyListeners();
    } else {
      Fluttertoast.showToast(
        msg: "${intendedLocation.toUpperCase()} TIDAK DI TEMUKAN",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        fontSize: 16.0,
      );
    }

    notifyListeners();
  }

  Future<LatLng> getGeocoding(String address) async {
    var value = address.replaceAll(RegExp(' '), '+');
    var latLng = await _googleMapsServices.getGeocoding(value);
    var lat = latLng['lat'];
    var lng = latLng['lng'];

    return LatLng(lat, lng);
  }

  // ! ON CAMERA MOVE
  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;

    // notifyListeners();
  }

  // ! ON CREATE
  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.setMapStyle(_mapStyle);

    notifyListeners();
  }

  void changeVisibility() {
    _isHide = !_isHide;
    SystemChrome.setEnabledSystemUIOverlays([]);
    notifyListeners();
  }

  // ! Function for convert jpeg into byte
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  // ! Function for change map style
  void _changeMapStyle() {
    rootBundle.loadString('assets/dark_theme.json').then((string) {
      _mapStyle = string;
    });
  }
}
