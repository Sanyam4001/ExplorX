import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoriteScreen extends StatefulWidget {
  final String userEmail; // Pass the user's email when navigating to this screen

  FavoriteScreen({required this.userEmail});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  Future<Map<String, dynamic>> fetchPlaceDetails(String placeName) async {
    final apiKey = 'AIzaSyADPMQI0jWhUgSE5ugm9QhJpl8w5uQMpbo';
    final query = Uri.encodeQueryComponent(placeName);

    final response = await http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final place = data['results'][0];
        final placeId = place['place_id'];
        final address = place['formatted_address'];
        final photoReference = place['photos'][0]['photo_reference'];

        return {
          'placeId': placeId,
          'address': address,
          'photoReference': photoReference,
        };
      }
    }

    // Handle errors or no results found
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Destinations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userEmail)
            .collection('places')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data!.docs;

          // Display the favorite places in a ListView.builder
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;
              final placeName = data['name']; // Adjust the field name as per your Firestore structure

              // Use FutureBuilder to handle asynchronous fetching of place details
              return FutureBuilder<Map<String, dynamic>>(
                future: fetchPlaceDetails(placeName),
                builder: (context, placeDetailsSnapshot) {
                  if (placeDetailsSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (placeDetailsSnapshot.hasError) {
                    return Text('Error: ${placeDetailsSnapshot.error}');
                  } else {
                    final placeDetails = placeDetailsSnapshot.data!;

                    return ListTile(
                      contentPadding: EdgeInsets.all(16.0), // Add padding around the ListTile
                      title: Text(
                        placeName,
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), // Increase the font size
                      ),
                      subtitle: Text(
                        placeDetails['address'],
                        style: TextStyle(fontSize: 16.0), // Customize the subtitle font size
                      ),
                      leading: placeDetails['photoReference'] != null
                          ? Container(
                        width: 80.0, // Increase the width of the leading image container
                        height: 80.0, // Increase the height of the leading image container
                        child: Image.network(
                          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${placeDetails['photoReference']}&key=AIzaSyADPMQI0jWhUgSE5ugm9QhJpl8w5uQMpbo',
                          fit: BoxFit.cover,
                        ),
                      )
                          : null,
                      // Add other widgets to display additional information if needed
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}


