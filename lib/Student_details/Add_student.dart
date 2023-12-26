import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';

import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled25/Utils/utils.dart';
import 'package:uuid/uuid.dart';
import '../Appurl.dart';
import '../Homepage.dart';
import '../Widgets/text_field.dart';
import '../Widgets/buttons.dart';
import '../constants.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({Key? key}) : super(key: key);

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  File? _image;
  final stdName = TextEditingController();
  final schoolname = TextEditingController();
  final classCategory = TextEditingController();
  final locationName = TextEditingController();
  final vehicle = TextEditingController();
  final searchingController = TextEditingController();
  var uuid= const Uuid();
  String sessionToken = '1234567890';
  List<dynamic> placeList = [];
  String? school_latitude;
  String? school_longitude;
  String? place_latitude;
  String? place_longitude;

  initSearching(){
    searchingController.addListener(() {onChangeController();});
  }
  onChangeController(){
    if(sessionToken == null){
      sessionToken = uuid.v4();
      debugPrint(sessionToken);
    }
    getSuggestion(searchingController.text);
  }

  getSuggestion(String input) async {
    try {
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseURL?input=$input&key=${AppUrl.gKey}&sessiontoken=$sessionToken&components=country:${'ind'}';
      debugPrint(request);
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        placeList = data['predictions'];
        setState(() {

        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // toastMessage('success');
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> addStudent(context) async {
    final apiUrl = AppUrl.std_register;

    final data = {
      "name": stdName.text,
      "photo": _image != null ? _image!.path : "",
      "school": {
        "school_name": schoolname.text,
        "place": locationName.text,
        "latitude":school_latitude.toString(),
        "longitude":school_longitude.toString()
      },
      "class_category": classCategory.text,
      "parent_id": Utils.userLoggedId,
      "address":{
        "home_name":locationName.text,
        "place":locationName.text,
        "latitude":place_latitude.toString(),
        "longitude":place_longitude.toString()
      },
      "vehicle":vehicle.text
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    print(jsonEncode(data));

    if (response.statusCode == 200) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage(),));
      Fluttertoast.showToast(msg: 'Child Added Successfully');
      print('API Response: ${response.body}');

    } else {
      print('Error - Status Code: ${response.statusCode}');
      print('Error - Response Body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.menu, color: textColor1),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage(),));
              },
              child:CircleAvatar(
                backgroundImage: NetworkImage(Utils.photUrl == null ?
                'https://images.unsplash.com/photo-1480455624313-e'
                    '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                    'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D':Utils.photUrl.toString(),
                ),
              ),
            ),
          )
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_back,color: Colors.black,),
                  Text("Add Student",style: TextStyle(color: Colors.black,fontSize: 18),)
                ],
              ),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(radius: 45),
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
                          place_latitude = geometry.location.lat.toString();
                          place_longitude = geometry.location.lng.toString();
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 52,
                      width: 156,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Homepage()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: pinkColor),
                        ),
                        child: Text('Cancel', style: TextStyle(color: pinkColor)),
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      width: 156,
                      child: MyButtonWidget(
                        buttonName: "Save",
                        bgColor: openScanner,
                        onPressed: () {
                          addStudent(context);
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
