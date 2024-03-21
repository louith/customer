import 'dart:io';
import 'package:customer/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImgSubmission extends StatefulWidget {
  const ImgSubmission({super.key});

  @override
  State<ImgSubmission> createState() => _ImgSubmissionState();
}

class _ImgSubmissionState extends State<ImgSubmission> {
  File? image;

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

  Widget buildButton({
    required String title,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: kPrimaryColor,
          minimumSize: Size.fromHeight(56),
          backgroundColor: kPrimaryLightColor,
          textStyle: TextStyle(fontSize: 20),
        ),
        child: Row(children: [
          Icon(icon, size: 28),
          const SizedBox(
            width: 16,
          ),
          Text(title)
        ]),
        onPressed: onClicked,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Spacer(),
          image != null
              ? Image.file(
                  image!,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                )
              : FlutterLogo(size: 160),
          SizedBox(height: 24),
          buildButton(
              title: 'Pick from Gallery',
              icon: Icons.image_outlined,
              onClicked: () => pickImage(ImageSource.gallery)),
          SizedBox(height: 20),
          buildButton(
              title: "Open Camera",
              icon: Icons.camera_alt_outlined,
              onClicked: () => pickImage(ImageSource.camera))
        ],
      ),
    );
  }
}
