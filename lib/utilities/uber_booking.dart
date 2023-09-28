import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class UberBookingPage extends StatefulWidget {
  final double dropoffLatitude;
  final double dropoffLongitude;
  final double pickupLatitude;
  final double pickupLongitude;

  UberBookingPage({
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.pickupLatitude,
    required this.pickupLongitude,
  });

  @override
  _UberBookingPageState createState() => _UberBookingPageState();
}

class _UberBookingPageState extends State<UberBookingPage> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController dropoffController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pickupController.text = '${widget.pickupLatitude}, ${widget.pickupLongitude}';
    dropoffController.text = '${widget.dropoffLatitude}, ${widget.dropoffLongitude}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uber Booking'),
        centerTitle: true,
        backgroundColor: Color(0xFF3A6AB1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: pickupController,
              decoration: InputDecoration(
                labelText: 'Pickup Location',
              ),
              readOnly: true,
            ),
            TextField(
              controller: dropoffController,
              decoration: InputDecoration(
                labelText: 'Dropoff Location',
              ),
              readOnly: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3A6AB1),
              ),
              onPressed: () {
                _launchUber(
                  widget.dropoffLatitude,
                  widget.dropoffLongitude,
                  widget.pickupLatitude,
                  widget.pickupLongitude,
                );
              },
              child: Text('Book Uber'),
            ),
          ],
        ),
      ),
    );
  }

  void _launchUber(
      double endLatitude,
      double endLongitude,
      double startLatitude,
      double startLongitude,
      ) async {
    final uberAppUrl =
        'https://m.uber.com/ul/?action=setPickup&pickup[latitude]=$startLatitude&pickup[longitude]=$startLongitude&dropoff[latitude]=$endLatitude&dropoff[longitude]=$endLongitude';

    final Uri launchUri = Uri.parse(uberAppUrl);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Uber app is not installed.');
    }
  }
}
