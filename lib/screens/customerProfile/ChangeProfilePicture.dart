import 'dart:io';
import 'package:customer/components/assets_strings.dart';
import 'package:customer/components/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ChangeCustomerProfilePicture extends StatefulWidget {
  const ChangeCustomerProfilePicture({super.key});

  @override
  State<ChangeCustomerProfilePicture> createState() =>
      _ChangeCustomerProfilePictureState();
}

class _ChangeCustomerProfilePictureState
    extends State<ChangeCustomerProfilePicture> {
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
      print('Failed to pick image: $e');
    }
  }

  Future<String> uploadProfPic() async {
    final path = 'customerProfilePics/${image!}';
    final file = File(image!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() => {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    return urlDownload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        foregroundColor: kPrimaryLightColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close)),
        actions: <Widget>[
          TextButton.icon(
              onPressed: uploadProfPic,
              icon: Icon(
                Icons.check,
                color: kPrimaryLightColor,
              ),
              label: Text(
                'SAVE',
                style: TextStyle(color: kPrimaryLightColor),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            image != null
                ? ClipOval(
                    child: Image.file(
                      image!,
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    DefaultProfilePic,
                    width: 130,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(
              height: 18,
            ),
            Text('Change Profile Picture'),
            const SizedBox(
              height: 24,
            ),
            TextButton.icon(
                onPressed: () => pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image_outlined),
                label: const Text('Pick from Gallery')),
            const SizedBox(
              height: 18,
            ),
            TextButton.icon(
                onPressed: () => pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_outlined),
                label: const Text('Pick from Camera'))
          ],
        ),
      ),
    );
  }
}
