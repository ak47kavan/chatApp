import 'dart:developer'; // For logging
import 'dart:io'; // For handling file input
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:kri_dhan/helper/dialogs.dart';
import 'package:kri_dhan/models/chat_user.dart';
import 'package:kri_dhan/screens/auth/login_screen.dart';
import '../api/apis.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile Screen"),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showProgressbar(context);
              try {
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const loginScreen()),
                );
              } catch (e) {
                log("Logout Error: $e");
                Dialogs.showSnackbar(context, "Error logging out: $e");
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: mq.height * .03),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image ?? 'https://example.com/default-image.png',
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(child: Icon(CupertinoIcons.person)),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: _showBottomSheet,
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 40, 219, 226),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mq.height * .03),
                  Text(
                    widget.user.email ?? 'No email available',
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(height: mq.height * .05),
                  TextFormField(
                    initialValue: widget.user.name ?? '',
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 40, 219, 226)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'e.g., A K Kavan',
                      hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                      labelText: "Name",
                      labelStyle: const TextStyle(color: Colors.grey),
                      floatingLabelStyle: const TextStyle(color: Color.fromARGB(255, 40, 219, 226)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color.fromARGB(255, 40, 219, 226), width: 2.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height * .02),
                  TextFormField(
                    initialValue: widget.user.about ?? '',
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.info_outline, color: Color.fromARGB(255, 40, 219, 226)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'e.g., Feeling Happy',
                      hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                      labelText: "About",
                      labelStyle: const TextStyle(color: Colors.grey),
                      floatingLabelStyle: const TextStyle(color: Color.fromARGB(255, 40, 219, 226)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color.fromARGB(255, 40, 219, 226), width: 2.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height * .05),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * .5, mq.height * .06),
                      backgroundColor: const Color.fromARGB(255, 40, 219, 226),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        try {
                          await APIs.updateUserInfo();
                          Dialogs.showSnackbar(context, 'Profile Updated Successfully');
                        } catch (e) {
                          Dialogs.showSnackbar(context, 'Failed to update profile: $e');
                        }
                      }
                    },
                    icon: const Icon(Icons.edit, size: 28, color: Colors.white),
                    label: const Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    final mq = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: mq.height * .03,
            bottom: mq.height * .05,
          ),
          children: [
            const Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: mq.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

                    if (image != null) {
                      final mimeType = lookupMimeType(image.path);
                      log('Image Path: ${image.path} -- MimeType: $mimeType');
                      setState(() {
                        _image = image.path;
                      });

                      // Convert the image path to a File
                      File imageFile = File(_image!);

                      // Extract file extension
                      String ext = imageFile.path.split('.').last;

                      try {
                        // Call your Cloudinary upload function here
                        String? imageUrl = await APIs.uploadToCloudinary(imageFile, ext);
                        if (imageUrl != null) {
                          setState(() {
                            widget.user.image = imageUrl;
                          });
                          await APIs.updateProfilePicture(imageFile);
                        }
                      } catch (e) {
                        log('Error uploading image: $e');
                        Dialogs.showSnackbar(context, 'Failed to upload image. Please try again.');
                      }
                      Navigator.pop(context);
                    } else {
                      log('No image selected.');
                    }
                  },
                  child: Image.asset('images/add-image.png'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);

                    if (image != null) {
                      final mimeType = lookupMimeType(image.path);
                      log('Image Path: ${image.path} -- MimeType: $mimeType');
                      setState(() {
                        _image = image.path;
                      });

                      // Convert the image path to a File
                      File imageFile = File(_image!);

                      // Extract file extension
                      String ext = imageFile.path.split('.').last;

                      try {
                        // Call your Cloudinary upload function here
                        String? imageUrl = await APIs.uploadToCloudinary(imageFile, ext);
                        if (imageUrl != null) {
                          setState(() {
                            widget.user.image = imageUrl;
                          });
                          await APIs.updateProfilePicture(imageFile);
                        }
                      } catch (e) {
                        log('Error uploading image: $e');
                        Dialogs.showSnackbar(context, 'Failed to upload image. Please try again.');
                      }
                      Navigator.pop(context);
                    } else {
                      log('No image captured.');
                    }
                  },
                  child: Image.asset('images/camera-lens.png'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
