import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/assets_strings.dart';
import 'package:customer/components/form_container_widget.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/Homescreen/MainScreen.dart';
import 'package:customer/screens/Homescreen/my_profile.dart';
import 'package:customer/screens/customerProfile/ChangeProfilePicture.dart';
import 'package:customer/screens/customerProfile/components/user_model.dart';
import 'package:customer/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

final db = FirebaseFirestore.instance;

class AfterSignup extends StatefulWidget {
  final String email;
  final String username;
  final String password;
  const AfterSignup({
    super.key,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  State<AfterSignup> createState() => _AfterSignupState();
}

class _AfterSignupState extends State<AfterSignup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const MyProfile())));
              },
              icon: const Icon(Icons.arrow_back)),
          title: const Text(
            'My Profile',
          ),
        ),
        body: CustProfile(
          email: widget.email,
          username: widget.username,
          password: widget.password,
        ));
  }
}

class CustProfile extends StatefulWidget {
  final String email;
  final String username;
  final String password;

  const CustProfile({
    super.key,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  State<CustProfile> createState() => _CustProfileState();
}

class _CustProfileState extends State<CustProfile> {
  bool isDefaultAddress = false;
  File? image;
  UploadTask? uploadTask;
  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemporary = File(image.path);
      this.image = imageTemporary;
      setState(() {
        this.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: ${e}');
    }
  }

  Future<String> uploadProfPic() async {
    final Reference path = FirebaseStorage.instance.ref('customerProfilePics');
    final File file = File(image!.path);
    final Reference customerProfile =
        path.child(currentUser!.uid).child('image.jpg');
    await customerProfile.putFile(file);
    String urlDownload = await customerProfile.getDownloadURL();
    return urlDownload;
  }

  final FirebaseAuthService _auth = FirebaseAuthService();
  final currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _middlename = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _gender = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _phonenum = TextEditingController();
  final TextEditingController _addressName = TextEditingController();
  final TextEditingController _province = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _brgy = TextEditingController();
  final TextEditingController _extaddress = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();

  @override
  void initState() {
    super.initState();
    _email.text = widget.email;
    _username.text = widget.username;
  }

  Future<void> addDataToFirestore() async {
    String profpicURL = await uploadProfPic();
    if (_formKey.currentState!.validate()) {
      try {
        // Collection reference
        var users = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid);
        // Get data from text fields
        String firstName = _firstname.text;
        String middleName = _middlename.text;
        String lastName = _lastname.text;
        String gender = _gender.text;
        String age = _age.text;
        String phonenum = _phonenum.text;
        String addressName = _addressName.text;
        String prov = _province.text;
        String city = _city.text;
        String brgy = _brgy.text;
        String extAddress = _extaddress.text;
        String email = widget.email;
        String userName = widget.username;
        String password = widget.password;
        // Document data
        Map<String, dynamic> userData = {
          "First Name": firstName,
          "Middle Name": middleName,
          "Last Name": lastName,
          "Gender": gender,
          "Age": age,
          'Email': email,
          'Contact Number': phonenum,
          'Username': userName,
          'Password': password,
          'role': 'customer',
          'Profile Picture': profpicURL
        };
        // Add document to the collection
        await users.set(userData);
        var addressCol = db
            .collection('users')
            .doc(currentUser!.uid)
            .collection('addresses')
            .doc(addressName);
        Map<String, dynamic> addressData = {
          'Address Name': addressName,
          'Province': prov,
          'City': city,
          'Barangay': brgy,
          'Extended Address': extAddress,
          // 'Default Address': isDefaultAddress,
        };
        await addressCol.set(addressData);
        toastification.show(
            type: ToastificationType.success,
            context: context,
            icon: Icon(Icons.check_circle_outline_outlined),
            title: Text('Personal data added'),
            autoCloseDuration: const Duration(seconds: 3),
            showProgressBar: false,
            alignment: Alignment.topCenter,
            style: ToastificationStyle.fillColored);
        print('Data added successfully');
        Navigator.push(context,
            MaterialPageRoute(builder: ((context) => CustMainScreen())));
      } catch (e) {
        print('Error adding data: $e');
      }
    } else {
      print('Some error happened');
    }
  }

  @override
  void dispose() {
    _firstname.dispose();
    _middlename.dispose();
    _lastname.dispose();
    _gender.dispose();
    _age.dispose();
    _phonenum.dispose();
    _addressName.dispose();
    _province.dispose();
    _city.dispose();
    _brgy.dispose();
    _extaddress.dispose();
    _email.dispose();
    _username.dispose();
    super.dispose();
  }

  void _showBackDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Leaving this page will log you out',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Log Out'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  String dropdownvalue = 'Male';
  List<String> items = ['Male', 'Female', 'Rather not say'];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        _showBackDialog();
      },
      child: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Scrollbar(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(defaultPadding),
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
                    : Image.asset(
                        DefaultProfilePic,
                        width: 130,
                        fit: BoxFit.cover,
                      ),
                TextButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Pick from Gallery')),
                const SizedBox(
                  height: defaultformspacing,
                ),
                TextButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_outlined),
                    label: const Text('Pick from Camera')),
                const SizedBox(
                  height: defaultformspacing,
                ),
                TextButton(
                  onPressed: uploadProfPic,
                  child: Text('Upload New Picture'),
                ),
                Container(
                  child: Form(
                      key: _formKey,
                      child: Column(children: [
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'First Name',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                hintText: 'Juan',
                                controller: _firstname,
                                labelText: 'First Name',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Middle Name',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                hintText: 'Santos',
                                controller: _middlename,
                                labelText: 'Middle Name',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Name',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                hintText: 'dela Cruz',
                                controller: _lastname,
                                labelText: 'Last Name',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        DropdownButtonFormField(
                          // dropdownColor: kPrimaryColor.withOpacity(.35),
                          hint: const Text("Gender"),
                          decoration: InputDecoration(
                              fillColor: kPrimaryColor.withOpacity(0.35),
                              filled: true,
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: kPrimaryColor,
                                  width: 1,
                                ),
                              )),

                          style: const TextStyle(color: Colors.black45),
                          value: dropdownvalue,
                          icon: const Icon(Icons.keyboard_arrow_down),
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
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Age',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                hintText: '20',
                                controller: _age,
                                labelText: 'Age',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Number',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                hintText: '094738347',
                                controller: _phonenum,
                                labelText: 'Phone Number',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Text(
                          'Address'.toUpperCase(),
                          // style: TextStyle(fontSize: defTitleFontSize),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Address Name',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                hintText: 'Home',
                                controller: _city,
                                labelText: 'City',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Province',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                hintText: 'Davao del Sur',
                                controller: _province,
                                labelText: 'Province',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'City',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                hintText: 'Davao City',
                                controller: _city,
                                labelText: 'City',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Baranggay',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                hintText: 'Sasa',
                                controller: _brgy,
                                labelText: 'Baranggay',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'House No.,Street, Subdivision/Village',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                hintText:
                                    '100 Pisces Street, Vincent Heights Subdivision',
                                controller: _extaddress,
                                labelText:
                                    'House No.,Street, Subdivision/Village',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        // Row(
                        //   children: [
                        //     Checkbox(
                        //       value: isDefaultAddress,
                        //       onChanged: (val) {
                        //         setState(() {
                        //           isDefaultAddress = val!;
                        //         });
                        //       },
                        //       checkColor: kPrimaryLightColor,
                        //     ),
                        //     Text(
                        //       'Default Address',
                        //       style: TextStyle(color: kPrimaryColor),
                        //     )
                        //   ],
                        // ),
                        const SizedBox(
                          height: 25,
                        ),
                        Text(
                          'Login Information'.toUpperCase(),
                          // style: TextStyle(fontSize: defTitleFontSize),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                isDisabled: true,
                                controller: _email,
                                labelText: 'Email Address',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: defaultformspacing,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            FormContainerWidget(
                                isDisabled: true,
                                controller: _username,
                                labelText: 'Username',
                                validator: (value) => value!.isEmpty
                                    ? 'Field cannot be empty'
                                    : null),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              addDataToFirestore();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                            ),
                            child: Text(
                              'SUBMIT',
                              style: TextStyle(color: kPrimaryLightColor),
                            ))
                      ])),
                ),
              ])),
        ),
      ),
    );
  }
}
