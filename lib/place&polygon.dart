import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pro_map/location_services.dart';

class PlaceAndPolygonScreen extends StatefulWidget {
  const PlaceAndPolygonScreen({Key? key}) : super(key: key);

  @override
  _PlaceAndPolygonScreenState createState() => _PlaceAndPolygonScreenState();
}

class _PlaceAndPolygonScreenState extends State<PlaceAndPolygonScreen> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController searchController = TextEditingController();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
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
}
