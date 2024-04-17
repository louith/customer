import 'package:customer/components/constants.dart';
import 'package:customer/screens/WelcomeScreen/CustWelcomeScreen.dart';
import 'package:flutter/material.dart';

TextFormField textField(
  String text,
  IconData icon,
  bool isPasswordType,
  TextEditingController controller,
) {
  return TextFormField(
    validator: (value) {
      if (value == null || value.isEmpty) return 'This field cannot be empty';
      return null;
    },
    controller: controller,
    obscureText: isPasswordType,
    style: const TextStyle(
      fontSize: 13,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
    ),
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.next,
    cursorColor: kPrimaryColor,
    decoration: InputDecoration(
        hintText: text,
        prefixIcon: Padding(
            padding: const EdgeInsets.all(defaultPadding), child: Icon(icon))),
  );
}

TextField flatTextField(String text, TextEditingController controller,
    {void Function(String)? onchanged}) {
  return TextField(
    onChanged: onchanged,
    style: const TextStyle(
      fontSize: 13,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
    ),
    cursorColor: kPrimaryColor,
    decoration: InputDecoration(
      hintText: text,
    ),
  );
}

Container nextButton(BuildContext context, Function onTap, String text) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Container backButton(BuildContext context, Function onTap, String text) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Container addImage(BuildContext context, String label) {
  return Container(
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(90),
      color: kPrimaryLightColor,
    ),
    child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: kPrimaryColor,
          padding: const EdgeInsets.all(defaultPadding),
        ),
        onPressed: () {},
        child: Text(
          label,
          style: const TextStyle(color: Colors.black),
        )),
  );
}

SizedBox logOutButton(BuildContext context) {
  return SizedBox(
    child: InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Theme(
                  data: ThemeData(
                      canvasColor: Colors.transparent,
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: kPrimaryColor,
                            background: Colors.white70,
                            secondary: kPrimaryLightColor,
                          )),
                  child: AlertDialog(
                    title: const Text("Confirm Logout?"),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        onPressed: () async {
                          try {
                            // await FirebaseAuth.instance.signOut();
                            print("logged out");
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const CustWelcome();
                            }));
                          } catch (e) {
                            print('error: $e');
                          }
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ));
            });
      },
      child: const Icon(
        Icons.logout,
        color: kPrimaryColor,
      ),
    ),
  );
}

Row RowDetails(List<Widget> children) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: children,
  );
}

Container ServiceCard(String service) {
  return Container(
    margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
    decoration: const BoxDecoration(
        color: kPrimaryLightColor,
        borderRadius: BorderRadius.all(Radius.circular(30))),
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    child: Text(
      service,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

Container bookingCard(Widget child) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
        vertical: defaultPadding, horizontal: defaultPadding * 2),
    margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 8,
          offset: Offset(8, 8),
        )
      ],
    ),
    child: child,
  );
}

//Loys' constant elevated button

Widget elevButton({
  required String title,
  // IconData? icon,
  required Function()? onClicked,
}) =>
    ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: kPrimaryColor,
          shape: const StadiumBorder(),
          maximumSize: const Size(double.infinity, 56),
          minimumSize: const Size(double.infinity, 56),
        ),
        onPressed: onClicked,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ));
