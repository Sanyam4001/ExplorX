import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../login_directory/sign_in.dart';
// import 'favourite_screen.dart';
import 'favourite_screen.dart';
import 'result_screen.dart';

final _firestore = FirebaseFirestore.instance;

class LoadingScreen extends StatefulWidget {
  String userName;
  String userEmail;

  LoadingScreen({required this.userName, required this.userEmail});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String? selectedOption = "Tourist Place";
  TextEditingController textController = TextEditingController();
  String user_name = "";




  @override

  void initState() {
    super.initState();
    // Extract the user_name from the userEmail
    user_name = extractUserName(widget.userEmail);
  }


  String extractUserName(String userEmail) {
    List<String> parts = userEmail.split('@');
    if (parts.length == 2) {
      return parts[0];
    }
    return "";
  }


  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'ExplorX',
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF3A6AB1),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user_name),
              accountEmail: Text(widget.userEmail),
              currentAccountPicture: CircleAvatar(),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favorite Destinations'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoriteScreen(userEmail: widget.userEmail,),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {

                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          // Background Image
          Image.asset(
            "images/explorX_page-0001.jpg", // Replace with your background image path
            fit: BoxFit.cover,
            //width: double.infinity,
            height: double.infinity,
          ),
           Padding(
            padding: const EdgeInsets.only(top: 80.0, left: 20.0),
            child: Text('Hello,\n $user_name', textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                fontFamily: 'RobotoMono',
              ),),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center elements vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center elements horizontally
                children: [
                  SizedBox(height: 50),
                  TypeAheadField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: textController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        labelText: 'Enter City',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      const apiKey = 'AIzaSyADPMQI0jWhUgSE5ugm9QhJpl8w5uQMpbo';
                      final response = await http.get(Uri.parse(
                          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeQueryComponent(pattern)}&types=(cities)&key=$apiKey'));

                      if (response.statusCode == 200) {
                        final data = json.decode(response.body);
                        final predictions = data['predictions'] as List<dynamic>;
                        final suggestions = predictions
                            .where((prediction) {
                          final types = prediction['types'] as List<dynamic>;
                          return types.contains('locality');
                        })
                            .map<String>((prediction) => prediction['description'] as String)
                            .toList();
                        return suggestions;
                      } else {
                        print('Failed to load suggestions. Status code: ${response.statusCode}');
                        print('Response body: ${response.body}');
                        throw Exception('Failed to load suggestions');
                      }
                    },
                    itemBuilder: (context, suggestion) {
                      return Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(2.0),
                        child: ListTile(
                          title: Text(suggestion,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),),
                        ),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      setState(() {
                        textController.text = suggestion;
                      });
                    },
                  ),//City Field
                  SizedBox(height: 45.0),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: DropdownButton<String?>(
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      value: selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue;
                        });
                      },
                      icon: Theme(
                        data: ThemeData(
                          iconTheme: IconThemeData(color: Colors.black),
                        ),
                        child: Icon(Icons.arrow_drop_down),
                      ),
                      items: <String?>[
                        'Tourist Place',
                        'Temples',
                        'Sunset Point',
                        'lake',
                        'Ghat',
                        'Beach',
                        'Waterfall',
                        'Mall',
                        'Hill',
                        'Hotels',
                        'Bars',
                        'Pharmacy',
                        'Hospitals',
                      ].map<DropdownMenuItem<String?>>((String? value) {
                        return DropdownMenuItem<String?>(
                          value: value,
                          child: Container(
                            color: Colors.white,
                            child: Text(
                              value ?? '',
                              style: TextStyle(color: Colors.black, fontSize: 15),
                            ),
                          ),

                        );
                      }).toList(),
                    ),
                  ),//Dropdown Menu
                  SizedBox(height: 50.0),
                  Container(
                    height: 50,
                    width : 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0), // Border radius
                      border: Border.all(
                        color: Colors.white, // Border color
                        width: 1.0,         // Border width
                      ),
                    ),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.black26;
                          }
                          return Color(0xFF3A6AB1);
                        }),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      onPressed: () {
                        String text = textController.text;
                        String stateName = extractStateName(text);
                        print("Button Clicked with text: $text, selected option: $selectedOption, state_name: $stateName");

                        // setState(() {
                        //   _firestore.collection('${widget.userEmail}').add({
                        //     'city': text,
                        //     'state': stateName, // Use the extracted state name
                        //     'time': FieldValue.serverTimestamp(),
                        //     // 'user id': widget.userEmail,
                        //   });
                        // });


                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultScreen(

                              city: text,
                              selectedOption: selectedOption ?? "", userEmail: widget.userEmail,
                            ),
                          ),
                        );
                      },
                      child: Text('Get Data'),
                    ),
                  ),//Get Data Button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String extractStateName(String text) {
  List<String> parts = text.split(','); // Split the text by comma
  if (parts.length >= 2) {
    return parts[1].trim(); // Get the second part and remove leading/trailing spaces
  }
  return ""; // Return an empty string if not enough parts are found
}