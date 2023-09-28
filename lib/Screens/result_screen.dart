import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'OptionsPage.dart';

final _firestore = FirebaseFirestore.instance;

class ResultScreen extends StatefulWidget {
  final String city;
  final String selectedOption;
  final String userEmail;

  ResultScreen({
    required this.userEmail,
    required this.city,
    required this.selectedOption,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<dynamic> placesData = [];
  bool isLoading = true;
  String? temperature;
  int? weatherCondition;

  // Create a map to track liked places
  Map<String, bool> likedPlaces = {};

  @override
  void initState() {
    super.initState();
    fetchDataFromPlacesAPI();
    fetchTemperature(widget.city, '07b2621048afbc5c621905471591005d').then((temp) {
      setState(() {
        temperature = temp;
      });
    });
  }

  Future<void> fetchDataFromPlacesAPI() async {
    const apiKey = 'AIzaSyADPMQI0jWhUgSE5ugm9QhJpl8w5uQMpbo';

    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json'
            '?query=${Uri.encodeQueryComponent(widget.selectedOption)} in ${Uri.encodeQueryComponent(widget.city)}'
            '&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        setState(() {
          placesData = data['results'];
          isLoading = false;
        });
      } else {
        print('Failed to load data from Places API. Status: ${data['status']}');
        isLoading = false;
      }
    } else {
      print('Failed to fetch data from Places API. Status code: ${response.statusCode}');
      isLoading = false;
    }
  }

  Widget buildStarRating(dynamic ratingData) {
    final double rating = (ratingData ?? 0).toDouble();
    final int starCount = 5;
    List<Widget> stars = [];
    for (int i = 1; i <= starCount; i++) {
      IconData starIcon = i <= rating ? Icons.star : Icons.star_border;
      Color starColor = i <= rating ? Colors.yellow : Colors.grey;
      stars.add(
        Icon(
          starIcon,
          size: 16.0,
          color: starColor,
        ),
      );
    }
    return Row(children: stars);
  }

  void sortPlacesByRatings() {
    placesData.sort((a, b) {
      final ratingA = a['rating'] ?? 0.0;
      final ratingB = b['rating'] ?? 0.0;
      return ratingB.compareTo(ratingA);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> parts = widget.city.split(',');
    String modifiedCity = parts.first.trim();

    sortPlacesByRatings();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedOption} in $modifiedCity'),
        backgroundColor: Color(0xFF3A6AB1),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
                : ListView.builder(
              itemCount: placesData.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        image: const DecorationImage(
                          image: AssetImage('images/img.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(25.0),
                        title: Text(
                          'Temperature: ${temperature ?? 'Loading...'}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.wb_sunny,
                          color: Colors.yellow,
                          size: 30.0,
                        ),
                      ),
                    ),
                  );
                } else {
                  final place = placesData[index - 1];
                  final placeId = place['place_id'];
                  final isLiked = likedPlaces.containsKey(placeId) ? likedPlaces[placeId]! : false;

                  String? photoReference = '';
                  if (place['photos'] != null && place['photos'].isNotEmpty) {
                    photoReference = place['photos'][0]['photo_reference'];
                  }

                  String imageUrl = '';
                  if (photoReference != null && photoReference.isNotEmpty) {
                    imageUrl = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=AIzaSyADPMQI0jWhUgSE5ugm9QhJpl8w5uQMpbo';
                  }

                  return Container(
                    padding: EdgeInsets.all(0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(20.0),
                          title: Text(
                            place['name'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(place['formatted_address'] ?? ''),
                              SizedBox(height: 10),
                              Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 250.0,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 15,),
                              Row(
                                children: [
                                  buildStarRating(place['rating']),
                                  SizedBox(width: 210,),
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () {
                                      final latitude =
                                      place['geometry']['location']['lat'];
                                      final longitude =
                                      place['geometry']['location']['lng'];
                                      setState(() {
                                        if (isLiked) {
                                          likedPlaces.remove(placeId);
                                        } else {
                                          likedPlaces[placeId] = true;
                                        }
                                        final user =
                                            FirebaseAuth.instance.currentUser;

                                        if (user != null) {
                                          final userEmail =
                                              user.email; // Get the user's email
                                          final placeName = place[
                                          'name']; // Replace with the name of the place you want to add

                                          // Reference to the Firestore instance
                                          final firestore =
                                              FirebaseFirestore.instance;

                                          // Reference to the user's document
                                          final userDocumentReference = firestore
                                              .collection('users')
                                              .doc(userEmail);

                                          // Reference to the "places" subcollection within the user's document
                                          final placesCollectionReference =
                                          userDocumentReference
                                              .collection('places');

                                          // Add a new document to the "places" subcollection
                                          placesCollectionReference.add({
                                            'name': placeName,
                                            // Add other place-related data as needed
                                          });

                                          print(
                                              'Place added to Firestore for user $userEmail: $placeName');
                                        } else {
                                          // User is not authenticated, handle the case accordingly
                                          print('User is not authenticated.');
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            final latitude = place['geometry']['location']['lat'];
                            final longitude = place['geometry']['location']['lng'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OptionsPage(
                                  latitude: latitude,
                                  longitude: longitude,
                                  place: place['name'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> fetchTemperature(String city, String apiKey) async {
    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
            '?q=${Uri.encodeQueryComponent(city)}'
            '&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final temperature = data['main']['temp'];
      setState(() {
        weatherCondition = data['weather'][0]['id'];
      });
      return '$temperature °C';
    } else {
      print('Failed to fetch temperature data. Status code: ${response.statusCode}');
      return null;
    }
  }
}

// AIzaSyADPMQI0jWhUgSE5ugm9QhJpl8w5uQMpbo //places api
// 07b2621048afbc5c621905471591005d

