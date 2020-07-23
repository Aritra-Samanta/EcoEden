import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:ecoeden/services/map_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ecoeden/main.dart';
//import 'package:location/location.dart';

class MapPage extends StatefulWidget {

  @override
  _MapPageState createState() => _MapPageState();

}
class _MapPageState extends State<MapPage>{

  GoogleMapController _controller;
  List<Placemark> placemark;
  List<LatLng> latlng = List();
  final Set<Marker> _markers = {};
  final Set<Polyline>_polyline={};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void getData() async {
    await fetchData();
    showRoute();
  }

  Future<void> fetchData() async{
    await getCurrentLocation();
    await getDestinationLocation();
  }

  Future<String> getAddress(double latitude,double longitude) async {
    print("In get address " +  latitude.toString() + longitude.toString());
    placemark = await Geolocator().placemarkFromCoordinates(latitude.toDouble(), longitude.toDouble());
    String address = placemark[0].name.toString() + ", " +
        placemark[0].locality.toString() + ", Postal Code:" +
        placemark[0].postalCode.toString();
    return address;
  }

  Future<void> getCurrentLocation() async {
    print("In current location");
    Position res = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    String ad = await getAddress(res.latitude, res.longitude);
    setState(() {
      print("In ss1");
      latlng.add(LatLng(res.latitude,res.longitude));
      _markers.add(Marker(
        markerId: MarkerId('2'),
        position: LatLng(res.latitude,res.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'Home' ,snippet: ad ),//snippet: _address
      ),);
    });
    print("Got current location" + latlng.toString());
  }

  Future<void> getDestinationLocation() async {
    print("In end location "  + global_store.state.lat + global_store.state.lng  );

    String ad = await getAddress(double.parse(global_store.state.lat),double.parse(global_store.state.lng));
    setState(() {
      print("In ss2");
      latlng.add(LatLng(double.parse(global_store.state.lat),double.parse(global_store.state.lng)));
      _markers.add(Marker(
        markerId: MarkerId('1'),
        position: LatLng(double.parse(global_store.state.lat),double.parse(global_store.state.lng)),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'Trash' ,snippet: ad ),//snippet: _address
      ),);
    });
    print("Got end location" + latlng.toString());
  }

  void showRoute() {
    print("I am coming bitch.");
    setState(() {
      print("In ss3");
      _polyline.add(Polyline(
        polylineId: PolylineId("Our Route"),
        width: 6,
        visible: true,
        //latlng is List<LatLng>
        points: latlng,
        color: Colors.blue,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    //getAddress(double.parse(lat),double.parse(lng))
    return GoogleMap(
      mapType: MapType.normal,
      polylines: _polyline,
      markers: _markers,
      initialCameraPosition: CameraPosition(
        target: LatLng(double.parse(global_store.state.lat),double.parse(global_store.state.lng)),
        zoom: 12.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
    );
  }
}