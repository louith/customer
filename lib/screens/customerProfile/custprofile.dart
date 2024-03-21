import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/form_container_widget.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/Homescreen/MainScreen.dart';
import 'package:customer/screens/Homescreen/my_profile.dart';
import 'package:customer/screens/customerProfile/components/user_model.dart';
import 'package:customer/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AfterSignup extends StatefulWidget {
  const AfterSignup({super.key});

  @override
  State<AfterSignup> createState() => _AfterSignupState();
}

class _AfterSignupState extends State<AfterSignup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: kPrimaryColor,
          leading: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: ((context) => MyProfile())));
              },
              icon: const Icon(Icons.arrow_back)),
          title: const Text(
            'My Profile',
          ),
        ),
        body: const CustProfile());
  }
}

class CustProfile extends StatefulWidget {
  const CustProfile({super.key});

  @override
  State<CustProfile> createState() => _CustProfileState();
}

class _CustProfileState extends State<CustProfile> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _middlename = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _gender = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _phonenum = TextEditingController();
  final TextEditingController _province = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _brgy = TextEditingController();
  final TextEditingController _extaddress = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();

  @override
  void dispose() {
    _firstname.dispose();
    _middlename.dispose();
    _lastname.dispose();
    _gender.dispose();
    _age.dispose();
    _phonenum.dispose();
    _province.dispose();
    _city.dispose();
    _brgy.dispose();
    _extaddress.dispose();
    _email.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> addDataToFirestore() async {
    try {
      // Collection reference
      var users =
          FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

      // Get data from text fields
      String firstName = _firstname.text;
      String middleName = _middlename.text;
      String lastName = _lastname.text;
      String gender = _gender.text;
      String age = _age.text;
      String phonenum = _phonenum.text;
      String prov = _province.text;
      String city = _city.text;
      String brgy = _brgy.text;
      String extAddress = _extaddress.text;
      String email = _email.text;
      String userName = _username.text;

      // Document data
      Map<String, dynamic> userData = {
        "First Name": firstName,
        "Middle Name": middleName,
        "Last Name": lastName,
        "Gender": gender,
        "Age": age,
        "Phone Number": phonenum,
        'Province': prov,
        'City': city,
        'Barangay': brgy,
        'Extended Address': extAddress,
        'Email': email,
        'Username': userName,
        'role': 'customer'
      };

      // Add document to the collection
      await users.set(userData);

      print('Data added successfully');
      showAlertDialog(context, 'SUCCESS', 'Customer data added successfully.');
      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => CustMainScreen())));
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  File? image;
  Widget buildButton({
    required String title,
    IconData? icon,
    Function()? onClicked,
  }) =>
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryColor),
            foregroundColor: MaterialStateProperty.all(kPrimaryLightColor)),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
            ),
            SizedBox(
              width: 16,
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onPressed: onClicked,
      );

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on Exception catch (e) {
      print('Failed to pick image: $e');
    }
  }

  String dropdownvalue = 'Male';
  List<String> items = ['Male', 'Female', 'Rather not say'];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight,
      width: screenWidth,
      child: Scrollbar(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(defaultPadding),
            child: Column(children: [
              Text(
                'Customer Profile'.toUpperCase(),
                // style: TextStyle(fontSize: defTitleFontSize),
              ),
              image != null
                  ? Image.file(
                      image!,
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                    )
                  : FlutterLogo(size: 160),
              buildButton(
                  title: 'Pick from Gallery',
                  icon: Icons.image_outlined,
                  onClicked: () => pickImage(ImageSource.gallery)),
              SizedBox(height: defaultformspacing),
              buildButton(
                  title: 'Pick from Camera',
                  icon: Icons.camera_alt_outlined,
                  onClicked: () => pickImage(ImageSource.camera)),
              Container(
                child: Form(
                    key: _formKey,
                    child: Column(children: [
                      SizedBox(
                        height: defaultformspacing,
                      ),
                      FormContainerWidget(
                        controller: _firstname,
                        hintText: 'First Name',
                      ),
                      SizedBox(
                        height: defaultformspacing,
                      ),
                      FormContainerWidget(
                        controller: _middlename,
                        hintText: 'Middle Name',
                      ),
                      SizedBox(
                        height: defaultformspacing,
                      ),
                      FormContainerWidget(
                        controller: _lastname,
                        hintText: 'Last Name',
                      ),
                      SizedBox(
                        height: defaultformspacing,
                      ),
                      DropdownButtonFormField(
                        // dropdownColor: kPrimaryColor.withOpacity(.35),
                        hint: Text("Gender"),
                        decoration: InputDecoration(
                            fillColor: kPrimaryColor.withOpacity(0.35),
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: kPrimaryColor,
                                width: 1,
                              ),
                            )),

                        style: TextStyle(color: Colors.black45),
                        value: dropdownvalue,
                        icon: Icon(Icons.keyboard_arrow_down),
                        items: items.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownvalue = newValue!;
                            _gender.text = newValue;
                          });
                        },
                      ),
                      SizedBox(
                        height: defaultformspacing,
                      ),
                      FormContainerWidget(
                        controller: _age,
                        hintText: 'Age',
                      ),
                      SizedBox(
                        height: defaultformspacing,
                      ),
                      FormContainerWidget(
                        controller: _phonenum,
                        hintText: 'Phone Number',
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        'Address'.toUpperCase(),
                        // style: TextStyle(fontSize: defTitleFontSize),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      FormContainerWidget(
                        controller: _province,
                        hintText: 'Province',
                      ),
                      SizedBox(
                        height: defaultformspacing,
                      ),
                      FormContainerWidget(
                        controller: _city,
                        hintText: 'City',
                      ),
                      SizedBox(
                        height: defaultformspacing,
                      ),
                      FormContainerWidget(
                        controller: _brgy,
                        hintText: 'Baranggay',
                      ),
                      SizedBox(
                        height: defaultformspacing,
                      ),
                      FormContainerWidget(
                        controller: _extaddress,
                        hintText: 'House No.,Street, Subdivision/Village',
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        'Login Information'.toUpperCase(),
                        // style: TextStyle(fontSize: defTitleFontSize),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      FormContainerWidget(
                        controller: _email,
                        hintText: 'Email Address',
                      ),
                      SizedBox(
                        height: defaultformspacing,
                      ),
                      FormContainerWidget(
                        controller: _username,
                        hintText: 'Username',
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            addDataToFirestore();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              textStyle: TextStyle(color: kPrimaryLightColor)),
                          child: Text('SUBMIT'))
                    ])),
              ),
            ])),
      ),
    );
  }
}
