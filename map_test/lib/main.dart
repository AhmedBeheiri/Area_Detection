import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:framy_annotation/framy_annotation.dart';
import 'package:geodesy/geodesy.dart' as g;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:maptest/maps_model.dart';

import 'custom_marker.dart';

void main() {
  runApp(MyApp());
}

@FramyApp()
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _polygonCount = 1;
  List<LatLng> latlngPoints = List();
  Set<Polygon> _polygons = Set();
  g.Geodesy geodesy = g.Geodesy();
  List<Marker> markers = [];

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(25.774, -80.190),
    zoom: 7,
  );

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: GoogleMap(
                initialCameraPosition: _kGooglePlex,
                mapType: MapType.normal,
                polygons: _polygons,
                markers: markers.toSet(),
                onTap: (point) {
                  print('Clicked2');
                  findarea(g.LatLng(point.latitude, point.longitude));
                },
              ),
            ),
          ],
        ),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void addPolygon() {
    String polygonId = 'polygon_Id$_polygonCount';
    _polygonCount++;
    _polygons.add(Polygon(
        polygonId: PolygonId(polygonId),
        fillColor: Colors.blueAccent.withOpacity(0.53),
        points: latlngPoints,
        strokeWidth: 2,
        strokeColor: Colors.black,
        onTap: () {
          print('Clicked');
        }));
    var middle = geodesy.midPointBetweenTwoGeoPoints(
      g.LatLng(latlngPoints[0].latitude, latlngPoints[0].longitude),
      g.LatLng(latlngPoints[1].latitude, latlngPoints[1].longitude),
    );

    MarkerGenerator([
      Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: Colors.green, borderRadius: BorderRadius.circular(20.0)),
          child: Text(polygonId))
    ], (bitmaps) {
      setState(() {
        markers = mapBitmapsToMarkers(bitmaps, polygonId, middle);
      });
    }).generate(context);
    setState(() {});
  }

  List<Marker> mapBitmapsToMarkers(
      List<Uint8List> bitmaps, String id, g.LatLng middle) {
    List<Marker> markersList = [];
    bitmaps.asMap().forEach((i, bmp) {
      markersList.add(
        Marker(
          position: LatLng(middle.latitude, middle.longitude),
          icon: BitmapDescriptor.fromBytes(bmp),
          markerId: MarkerId(id),
        ),
      );
    });
    return markersList;
  }

  void getData() async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
    };
    Response response = await get('http://matlob.elmotahda.site/api/cities',
        headers: headers);
    if (response.statusCode == 200) {
      MapsModel model = MapsModel.fromJson(jsonDecode(response.body));
      latlngPoints.add(LatLng(
        25.774,
        -80.190,
      ));
      latlngPoints.add(LatLng(
        18.466,
        -66.118,
      ));
      latlngPoints.add(LatLng(
        32.321,
        -64.757,
      ));
      latlngPoints.add(LatLng(
        25.774,
        -80.190,
      ));

      setState(() {
        addPolygon();
      });

//      latlngPolygons.add(LatLng(
//        double.parse(model.data[1].lat),
//        double.parse(model.data[1].lng),
//      ));
    }
  }

  void findarea(g.LatLng point) {
    int position = 0;
    for (int i = 0; i < _polygons.length; i++) {
      bool isGeoPointInPolygon = geodesy.isGeoPointInPolygon(
        point,
        latlngPoints.map((e) => g.LatLng(e.latitude, e.longitude)).toList(),
      );
      if (isGeoPointInPolygon) {
        position = i;
        Polygon element = _polygons.elementAt(position);
        Polygon newElement = element.copyWith(fillColorParam: Colors.grey);
        var list = _polygons.toList();
        list[position] = newElement;
        setState(() {
          _polygons = list.toSet();
        });
        print('Founded');
        break;
      }
    }

//    print(_polygons.elementAt(position).fillColor.toString());
  }
}
