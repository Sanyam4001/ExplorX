import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'; // Import the 'location' package
import 'package:url_launcher/url_launcher.dart';
import 'package:ExplorX/utilities/uber_booking.dart';

class OptionsPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String place;

  OptionsPage({required this.latitude, required this.longitude, required this.place});

  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  final Location location = Location();

  double currentLatitude = 0.0; // Provide initial values
  double currentLongitude = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationData = await location.getLocation();
      setState(() {
        currentLatitude = locationData.latitude!;
        currentLongitude = locationData.longitude!;
      });
    } catch (e) {
      print('Error getting current location: $e');
      // Handle the case where location retrieval failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place),
        backgroundColor: Color(0xFF3A6AB1),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 450, // Set the height for the map
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
                zoom: 15.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('location'),
                  position: LatLng(widget.latitude, widget.longitude),
                ),
              },
            ),
          ),
          SizedBox(height: 40,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(300, 48),
              backgroundColor: Color(0xFF3A6AB1),
            ),
            onPressed: () {
              if (currentLatitude != null && currentLongitude != null) {
                // Replace these coordinates with your source and destination coordinates
                final sourceLatitude = currentLatitude!;
                final sourceLongitude = currentLongitude!;
                final destinationLatitude = widget.latitude;
                final destinationLongitude = widget.longitude;

                final url = 'https://www.google.com/maps/dir/?api=1&origin=$sourceLatitude,$sourceLongitude&destination=$destinationLatitude,$destinationLongitude';
                final Uri launchUri3 = Uri.parse(url);
                launchUrl(launchUri3).then((result) {
                  if (result != null && result) {
                    // The URL was successfully launched
                  } else {
                    // Cannot launch the URL
                    // Handle the error as needed
                  }
                });
              } else {
                // Handle the case where current location is not available
              }
            },
            child: Text(
              'Get Direction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3A6AB1),
              minimumSize: Size(300, 48),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UberBookingPage(
                    dropoffLatitude: widget.latitude,
                    dropoffLongitude: widget.longitude,
                    pickupLatitude: currentLatitude,
                    pickupLongitude: currentLongitude,
                  ),
                ),
              );
            },
            child: const Text(
              'Uber',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(300, 48),
              backgroundColor: Color(0xFF3A6AB1),
            ),
            onPressed: () async {
              final destinationLatitude = widget.latitude;
              final destinationLongitude = widget.longitude;


              final bookingUrl = 'https://www.booking.com/searchresults.en-gb.html?latitude=$destinationLatitude&longitude=$destinationLongitude&ss=hotels';

              final Uri launchUri = Uri.parse(bookingUrl);

              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              } else {
                // If the Booking.com app or website cannot be opened, you can handle the error accordingly.
                print('Unable to open Booking.com.');
              }
            },
            child: Text(
              'Hotels near ${widget.place}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),


          SizedBox(height: 20,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(300, 48),
              backgroundColor: Color(0xFF3A6AB1),
            ),
            onPressed: () async {
              // Launch the Zomato app to show all restaurants
              final zomatoUrl = 'zomato://restaurants';
              final Uri launchUri = Uri.parse(zomatoUrl);
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              } else {
                // If the Zomato app is not installed, you can open the Zomato website instead
                final webUrl = 'https://www.zomato.com';
                final Uri launchUri2 = Uri.parse(webUrl);
                if (await canLaunchUrl(launchUri2)) {
                  await launchUrl(launchUri2);
                } else {
                  print('Unable to open Zomato.');
                }
              }
            },
            child: const Text(
              'Zomato',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
