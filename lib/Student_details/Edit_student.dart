import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:untitled25/Utils/utils.dart';
import '../Appurl.dart';
import '../Homepage.dart';
import '../Login and signup/Login.dart';
import '../Model/StudentDetailsModel.dart';
import '../Widgets/text_field.dart';
import '../Widgets/buttons.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;

class EditStudent extends StatefulWidget {
  int stdId;
  EditStudent({required this.stdId,Key? key}) : super(key: key);

  @override
  State<EditStudent> createState() => _EditStudentState();
}

class _EditStudentState extends State<EditStudent> {
  File? _image;
  final stdName = TextEditingController();
  final schoolname = TextEditingController();
  final classCategory = TextEditingController();
  final locationName = TextEditingController();
  final vehicle = TextEditingController();

  bool isLoading = false;

  String? school_latitude;
  String? school_longitude;
  String? location_latitude;
  String? location_longitude;

  Map<String, dynamic>? userData;

  bool isEditing = false;

  Future<void> fetchUserData() async {
    isLoading = true;
    print('fetchUserData called');
    final url = Uri.parse(AppUrl.stdParentDetails);
    final requestBody = {
      "id": widget.stdId
      // int.parse(widget.stdId.toString())
    };

    try {
      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      // Inside fetchUserData function

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          isLoading = false;
          // Parse the user data
          final userDataMap = jsonResponse['data'][0];
          final userData = UserData.fromJson(userDataMap);

          // Now you can use userData in your Flutter widgets
          print('User ID: ${userData.id}');
          print('User Name: ${userData.name}');
          setState(() {
            stdName.text =  userData.name.toString();
            schoolname.text = userData.school.toString();
            classCategory.text = userData.classCategory.toString();
            locationName.text = userData.place.toString();
            vehicle.text = userData.vehicle.toString();
          });
          // Display other properties as needed
        } else {
          isLoading = true;
          print('API request was successful, but with an error: ${jsonResponse['message']}');
        }
      } else {
        print('HTTP request failed with status code: ${response.statusCode}');
      }

    } catch (error) {
      print('Error during HTTP request: $error');
    }
  }

  Future<void> savedetails(int stdID) async {
    final url = Uri.parse(AppUrl.editchild);
    final requestBody = {
      "student_id": stdID,
      "name": stdName.text,
      "photo":"https://thumbs.dreamstime.com/b/basic-rgb-basic-rgb-219903843.jpg",
      "school":schoolname.text,
      "class_category": classCategory.text,
      "parent_id":Utils.userLoggedId,
      "address":{
        'home_name':locationName.text,
        'latitude': location_latitude,
        'longitude':location_longitude
      },
      'vehicle':vehicle.text
    };

    try {
      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          final Map<String, dynamic> data = jsonDecode(response.body);
        });


        Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage(),));
        Fluttertoast.showToast(msg: 'Updated Successfully');

      } else {
        print('HTTP request failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during HTTP request: $error');
    }
  }

  @override
  void initState() {
    print('passsed id is:${widget.stdId}');
    super.initState();
    fetchUserData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // leading: Icon(Icons.menu, color: textColor1),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                );
              },
              child:CircleAvatar(
                child:Text('${stdName.text.toUpperCase().trim().substring(0,1)}',style: TextStyle(
                    fontWeight: FontWeight.bold,fontSize: 18
                ),)
              ),
            ),
          )
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child:isLoading == false ? Center(child: CircularProgressIndicator(),): Column(
            children: [
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(radius: 45,
                    backgroundImage: NetworkImage(Utils.photUrl == null ?
                    'https://images.unsplash.com/photo-1480455624313-e'
                        '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                        'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D':Utils.photUrl.toString(),
                    ),
                  ),
                  SizedBox(
                    width: 225,
                    child: MyTextFieldWidget(labelName: 'Name', controller: stdName, validator: () {}),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text('School'),
                  ),
                  Container(
                    width: 323.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      style: TextStyle(
                        color: scanColor,
                      ),
                      controller: schoolname,
                      onTap:() async {
                        var place = await PlacesAutocomplete.show(
                            logo: Text(''),
                            context: context,
                            apiKey: AppUrl.gKey,
                            mode: Mode.overlay,
                            types: [],
                            strictbounds: false,
                            components: [
                              Component(Component.country, 'ind'),
                            ],

                            //google_map_webservice package
                            onError: (err){
                              print('error');
                            }
                        );

                        if(place != null){
                          setState(() {
                            schoolname.text = place.description.toString();
                          });

                          //form google_maps_webservice package
                          final plist = GoogleMapsPlaces(apiKey:AppUrl.gKey,
                            apiHeaders: await GoogleApiHeaders().getHeaders(),
                            //from google_api_headers package
                          );
                          String placeid = place.placeId ?? "0";
                          final detail = await plist.getDetailsByPlaceId(placeid);
                          final geometry = detail.result.geometry!;
                          school_latitude = geometry.location.lat.toString();
                          school_longitude = geometry.location.lng.toString();
                          // pickupLatitude = geometry.location.lat;
                          // pickupLongitude = geometry.location.lng;
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'invalid data' : null,
                    ),
                  ),
                ],
              ),


              MyTextFieldWidget(labelName: 'Class', controller: classCategory, validator: () {}),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text('Location'),
                  ),
                  Container(
                    width: 323.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      style: TextStyle(
                        color: scanColor,
                      ),
                      controller: locationName,
                      onTap:() async {
                        var place = await PlacesAutocomplete.show(
                            logo: Text(''),
                            context: context,
                            apiKey: AppUrl.gKey,
                            mode: Mode.overlay,
                            types: [],
                            strictbounds: false,
                            components: [
                              Component(Component.country, 'ind'),
                            ],

                            //google_map_webservice package
                            onError: (err){
                              print('error');
                            }
                        );

                        if(place != null){
                          setState(() {
                            locationName.text = place.description.toString();
                          });

                          //form google_maps_webservice package
                          final plist = GoogleMapsPlaces(apiKey:AppUrl.gKey,
                            apiHeaders: await GoogleApiHeaders().getHeaders(),
                            //from google_api_headers package
                          );
                          String placeid = place.placeId ?? "0";
                          final detail = await plist.getDetailsByPlaceId(placeid);
                          final geometry = detail.result.geometry!;
                          location_latitude = geometry.location.lat.toString();
                          location_longitude = geometry.location.lng.toString();
                          print('picked latitude ;${location_longitude}');
                          print('picked latitude ;${location_latitude}');
                          // pickupLatitude = geometry.location.lat;
                          // pickupLongitude = geometry.location.lng;
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'invalid data' : null,
                    ),
                  ),
                ],
              ),
              MyTextFieldWidget(labelName: 'Vehicle', controller: vehicle, validator: () {}),
              SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 52,
                      width: 156,
                      child: OutlinedButton(
                        onPressed: () {

                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: pinkColor),
                        ),
                        child: Text('Edit', style: TextStyle(color: pinkColor)),
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      width: 156,
                      child: MyButtonWidget(
                        buttonName: "Save",
                        bgColor: openScanner,
                        onPressed: () {
                         savedetails(int.parse(userData!['id'].toString()));
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          ),
        ),
    );
  }
}
