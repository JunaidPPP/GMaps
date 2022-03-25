import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pro_map/directions.dart';
import 'package:pro_map/location_services.dart';
import 'package:pro_map/place&polygon.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Google Maps Demo',
        home:
            // PlaceAndPolygonScreen(),
            DirectionsScreens()
        // MapSample(),
        );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController searchController = TextEditingController();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
//
  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);
//
  // static final Marker _markerOne = Marker(
  //   markerId: MarkerId('firstMarker'),
  //   infoWindow: InfoWindow(title: "Phli Position"),
  //   icon: BitmapDescriptor.defaultMarker,
  //   position: LatLng(37.42796133580664, -122.085749655962),
  // );
  // static final Marker _markerTwo = Marker(
  //   markerId: MarkerId('secondMarker'),
  //   infoWindow: InfoWindow(title: "Dusri Position"),
  //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //   position: LatLng(37.43296265331129, -122.08832357078792),
  // );
  // //build line between Markers
  // static final Polyline _polyline = Polyline(
  //     polylineId: PolylineId('_polyline1'),
  //     points: [
  //       LatLng(37.42796133580664, -122.085749655962),
  //       LatLng(37.43296265331129, -122.08832357078792),
  //     ],
  //     width: 5,
  //     color: Colors.yellow);
  // static final Polygon _polygon = Polygon(
  //   polygonId: PolygonId('_polygonId1'),
  //   points: [
  //     LatLng(37.42796133580664, -122.085749655962),
  //     LatLng(37.43296265331129, -122.08832357078792),
  //     LatLng(37.422962653319, -122.08832357),
  //     LatLng(37.41253319, -122.08857),
  //   ],
  //   strokeWidth: 5,
  //   fillColor: Colors.transparent,
  // );

  @override
  initState() {
    super.initState();
    setMarker(LatLng(37.42796133580664, -122.085749655962));
  }

  setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    });
  }

  setPolygon() {
    final String polygonIdValue = "polygon$polygonIdCounter";
    polygonIdCounter++;
    _polygons.add(Polygon(
      polygonId: PolygonId(polygonIdValue),
      points: polygonLatLng,
      strokeColor: Colors.transparent,
      strokeWidth: 2,
    ));
  }

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  List<LatLng> polygonLatLng = <LatLng>[];
  int polygonIdCounter = 1;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(" G Maps"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: searchController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: "Search City"),
                  onChanged: (value) {},
                ),
              ),
              IconButton(
                onPressed: () async {
                  var place =
                      await LocationServices().getPlace(searchController.text);
                  _goToPlace(place);
                },
                icon: Icon(Icons.search),
              )
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              polygons: _polygons,

              // markers: {
              //   _markerOne,
              //    _markerTwo
              // },
              // polylines: {_polyline},
              // polygons: {_polygon},
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (points) {
                setState(() {
                  polygonLatLng.add(points);
                  setPolygon();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place["geometry"]["location"]["lat"];
    final double lng = place["geometry"]["location"]["lng"];
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 12,
        ),
      ),
    );
    setMarker(LatLng(lat, lng));
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }
}
