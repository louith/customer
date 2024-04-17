import 'package:customer/components/constants.dart';
import 'package:customer/screens/Booking/EditEventComponents/event_provider.dart';
import 'package:customer/screens/SignupLogin/Login.dart';
import 'package:customer/screens/WelcomeScreen/CustWelcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '.env';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PampHere',
        theme: ThemeData(
          textTheme: TextTheme(
              displayMedium: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, color: kPrimaryLightColor),
              bodyLarge: GoogleFonts.inter()),
          fontFamily: 'Inter',
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: kPrimaryColor,
            shape: const StadiumBorder(),
            maximumSize: const Size(double.infinity, 56),
            minimumSize: const Size(double.infinity, 56),
          )),
          inputDecorationTheme: const InputDecorationTheme(
            errorStyle: TextStyle(color: Colors.red),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none),
          ),
        ),

        //legit first page
        // home: '/',
        initialRoute: '/',
        routes: {
          '/': (context) => CustWelcome(),
          '/login': (context) => LoginScreen(),
        },
      ),
    );
  }
}
