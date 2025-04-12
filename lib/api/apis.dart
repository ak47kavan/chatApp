import 'dart:developer'; // For logging
import 'dart:io'; // For handling file input
import 'dart:convert'; // For JSON parsing
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kri_dhan/models/chat_user.dart';
import 'package:kri_dhan/models/message.dart';

class APIs {
  // Firebase Auth instance
  static FirebaseAuth auth = FirebaseAuth.instance;

  // Firebase Firestore instance
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Current user information
  static late ChatUser me;

  // Current Firebase user
  static User get user => auth.currentUser!;

  // Cloudinary configuration
  static const String cloudName = 'dwdo7ojfz'; // Replace with your Cloudinary Cloud Name
  static const String uploadPreset = 'profileimage'; // Replace with your Cloudinary upload preset

  /// Check if the user document exists in Firestore
  static Future<bool> userExists() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

  /// Get the logged-in user's information
  static Future<void> getSelfInfo() async {
    try {
      final userDoc = await firestore.collection("users").doc(user.uid).get();

      if (userDoc.exists) {
        // Parse user data from Firestore
        me = ChatUser.fromJson(userDoc.data()!);

        // Log the data for debugging
        log('MY Data: ${userDoc.data().toString()}');
      } else {
        // If user does not exist, create a new user and retry fetching
        await createUser().then((value) => getSelfInfo());
      }
    } catch (e) {
      log('Error in getSelfInfo: $e');
    }
  }

  /// Create a new user document in Firestore
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // Create a new ChatUser object
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName ?? 'Anonymous', // Handle null display name
      email: user.email ?? 'No Email', // Handle null email
      about: "Hey, I'm using AK Chat!",
      image: user.photoURL ?? '', // Handle null photo URL
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );

    try {
      // Save the ChatUser object to Firestore
      await firestore.collection("users").doc(user.uid).set(chatUser.toJson());
    } catch (e) {
      log('Error in createUser: $e');
    }
  }

  /// Fetch all users except the current user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection("users")
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  /// Update user info in Firestore
  static Future<void> updateUserInfo() async {
    await firestore.collection("users").doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  /// Upload profile picture to Cloudinary and update the URL in Firestore
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last; // Get file extension
    log('File extension: $ext');
    
    try {
      // Step 1: Upload file to Cloudinary
      String? imageUrl = await uploadToCloudinary(file, ext);

      if (imageUrl != null) {
        // Step 2: Update Firestore with the new image URL
        await firestore.collection("users").doc(user.uid).update({
          'image': me.image,
        });
        log('Profile picture updated in Firestore');

       
        
        
      } else {
        log('Error uploading image to Cloudinary');
      }
    } catch (e) {
      log('Error in updateProfilePicture: $e');
    }
  }

  /// Function to upload image to Cloudinary
  static Future<String?> uploadToCloudinary(File file, String ext) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add the upload preset and file
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send the request
      var response = await request.send();

      // Handle response
      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = json.decode(res.body);
        final imageUrl = data['secure_url'];  // Get the image URL from the response
        log('Image uploaded to Cloudinary: $imageUrl');
        return imageUrl;
      } else {
        log('Error uploading image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error in uploadToCloudinary: $e');
      return null;
    }
  }

  static String getConversationID(String? id) {
  // Provide a fallback value for null IDs (e.g., an empty string or "unknown")
  final safeId = id ?? 'unknown';
  return user.uid.hashCode <= safeId.hashCode
      ? '${user.uid}_$safeId'
      : '${safeId}_${user.uid}';
}



  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .snapshots();
  }


  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
  final time = DateTime.now().millisecondsSinceEpoch.toString();
  final Message message = Message(
    msg: msg,
    read: '',
    told: chatUser.id ?? 'unknown', // Provide a default value for null `id`
    type: Type.text,
    fromId: user.uid,
    sent: time,
  );
    final ref  = 
    firestore.collection("chats/${getConversationID(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson());
  }
}
