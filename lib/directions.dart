import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pro_map/location_services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:pro_map/models.dart/directionResponce.dart' hide Polyline;

class DirectionsScreens extends StatefulWidget {
  const DirectionsScreens({Key? key}) : super(key: key);

  @override
  _DirectionsScreensState createState() => _DirectionsScreensState();
}

class _DirectionsScreensState extends State<DirectionsScreens> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
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
      fillColor: Colors.transparent,
      strokeWidth: 2,
    ));
  }

  setPolylines(List<PointLatLng> points) {
    final String polylineIdValue = "polyline$polylineIdCounter";
    polylineIdCounter++;
    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdValue),
        width: 2,
        color: Colors.black,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLng = <LatLng>[];
  int polygonIdCounter = 1;
  int polylineIdCounter = 1;

  Future _goToPlace(dynamic lat, dynamic lng, dynamic boundNElat,
      dynamic boundNElng, dynamic boundSWlat, dynamic boundSWlng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 12,
        ),
      ),
    );
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(boundNElat, boundNElng),
          southwest: LatLng(boundSWlat, boundSWlng),
          // northeast: LatLng(boundNE['lat'], boundNE['lng']),
          // southwest: LatLng(boundSW['lat'], boundSW['lng']),
        ),
        25));

    setMarker(LatLng(lat, lng));
  }

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
                child: Column(
                  children: [
                    TextFormField(
                      controller: originController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: "from?"),
                      onChanged: (value) {},
                    ),
                    TextFormField(
                      controller: destinationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: "destination!"),
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  DirectionResponse dirictions =
                      await LocationServices().getDirictions(
                    originController.text,
                    destinationController.text,
                  );

                  print(dirictions.routes![0].legs![0].startLocation!.lat);
                  print(dirictions.routes![0].legs![0].startLocation!.lng);

                  await _goToPlace(
                    dirictions.routes![0].legs![0].startLocation!.lat,
                    dirictions.routes![0].legs![0].startLocation!.lat,
                    dirictions.routes![0].bounds!.northeast!.lat,
                    dirictions.routes![0].bounds!.northeast!.lng,
                    dirictions.routes![0].bounds!.southwest!.lat,
                    dirictions.routes![0].bounds!.southwest!.lng,
                  );
                  setPolylines(PolylinePoints().decodePolyline(dirictions
                      .routes![0].overviewPolyline!.points
                      .toString()));
                  // print(dirictions);
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
              polylines: _polylines,
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
}
