import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

const apiKey = 'AIzaSyDoatvCjV_WztUKGOplkDq5p9r-mwFyv_M';

class GoogleMapServices {
  Future<String> getRouteCoordinates(LatLng l1, String destination) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=$destination&key=$apiKey";

      http.Response response = await http.get(url);

      Map values = jsonDecode(response.body);
      return values["routes"][0]["overview_polyline"]["points"];
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> getRouteStatus(LatLng l1, String destination) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=$destination&key=$apiKey";

      http.Response response = await http.get(url);

      Map values = jsonDecode(response.body);

      return values["status"];
    } catch (e) {
      return null;
    }
  }

  Future<String> getDistance(LatLng l1, String destination) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=$destination&key=$apiKey";

      http.Response response = await http.get(url);

      Map values = jsonDecode(response.body);

      return values["routes"][0]["legs"][0]["distance"]["text"];
    } catch (e) {
      return null;
    }
  }

  getReverseGeocoding(LatLng position) async {
    try {
      String url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

      var response = await http.get(url);

      Map values = jsonDecode(response.body);

      return values["results"][0]["formatted_address"];
    } catch (e) {
      print('[getReverseGeocoding] error with mesg [$e]');
      return null;
    }
  }

  getGeocoding(String address) async {
    try {
      String url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey';

      var response = await http.get(url);

      Map values = jsonDecode(response.body);

      return values["results"][0]["geometry"]["location"];
    } catch (e) {
      return null;
    }
  }
}
