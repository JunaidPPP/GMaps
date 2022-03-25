import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:pro_map/models.dart/directionResponce.dart';

class LocationServices {
  // final String key = "AIzaSyDuSPHzjDJuwaAxzvclvoLv8zvi_AK4XaM";
  final String key = "AIzaSyDi9yUMFZwpC90gb2DG0GaNns1iSFzOopw";

  Future getPlaceId(String input) async {
    final String url =
        //     "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key";
        'https://maps.googleapis.com/maps/api/place/textsearch/json?input=$input&key=$key';
    var responce = await http.get(Uri.parse(url));
    var json = await convert.jsonDecode(responce.body);

    // print(json["results"][0]["place_id"].toString());
    var placeId = json["results"][0]["place_id"].toString();
    return placeId;
  }

  Future getPlace(String input) async {
    var placeId = await getPlaceId(input);
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
    // 'https://maps.googleapis.com/maps/api/place/details/json?place_id=ChIJv0sdZQY-sz4RIwxaVUQv-Zw&key=AIzaSyDi9yUMFZwpC90gb2DG0GaNns1iSFzOopw';

    var responce = await http.get(Uri.parse(url));
    var json = await convert.jsonDecode(responce.body);

    var results = await json["result"];
    // print(results.toString());
    return await results;
  }

  Future<DirectionResponse> getDirictions(
      String origin, String destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    var responce = await http.get(Uri.parse(url));
    var json = await convert.jsonDecode(responce.body);

    // print(json);
    // var results = {
    //   "bounds_ne ": json['routes'][0]['bounds']["northeast"],
    //   "bounds_sw ": json['routes'][0]['bounds']["southwest"],
    //   "start_location ": json['routes'][0]['legs'][0]["start_location"],
    //   "end_location ": json['routes'][0]['legs'][0]["end_location"],
    //   "polyline ": json['routes'][0]['overview_polyline']["points"],
    //   "polyline_decoded ": PolylinePoints()
    //       .decodePolyline(json['routes'][0]['overview_polyline']["points"]),
    // };
    // print(json);
    return DirectionResponse.fromJson(json);
  }
}
