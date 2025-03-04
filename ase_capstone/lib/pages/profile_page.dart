import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;
  File? _image;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _getUser();
    _getProfilePicture();
  }

  // get user from firestore db
  Future<void> _getUser() async {
    try {
      Map<String, dynamic> data =
          await firestoreService.getUser(userId: user?.uid);
      setState(() {
        userData = data;
      });
    } on FirebaseException catch (e) {
      setState(() {
        Utils.displayMessage(
          context: context,
          message: 'Error: ${e.toString()}',
        );
      });
    }
  }

  Future<void> _getProfilePicture() async {
    try {
      final profilePicturePath =
          await firestoreService.getProfilePicture(userId: user!.uid);
      setState(() {
        _image = File(profilePicturePath);
      });
    } on FirebaseException catch (e) {
      setState(() {
        Utils.displayMessage(
          context: context,
          message: 'Error: ${e.toString()}',
        );
      });
    }
  }

  Future<void> changeProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // upload image to firebase storage
      try {
        firestoreService.uploadProfilePicture(
          userId: user!.uid,
          filePath: _image!.path,
        );
      } catch (e) {
        setState(() {
          Utils.displayMessage(
            context: context,
            message: 'Error: ${e.toString()}',
          );
        });
      }
    }
  }

  void editProfile() {
    TextEditingController nameController =
        TextEditingController(text: user?.displayName);
    TextEditingController emailController =
        TextEditingController(text: user?.email);
    TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (nameController.text.isNotEmpty) {
                    await user?.updateDisplayName(nameController.text);
                  }

                  if (emailController.text.isNotEmpty &&
                      emailController.text != user?.email) {
                    await user?.verifyBeforeUpdateEmail(emailController.text);
                  }

                  if (mounted) {
                    setState(() {});
                  }
                } catch (e) {
                  setState(() {
                    Utils.displayMessage(
                      context: context,
                      message: 'Error: ${e.toString()}',
                    );
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: changeProfilePicture,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : NetworkImage(user?.photoURL ?? '') as ImageProvider,
                      child: _image == null && user?.photoURL == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData['username'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Username: @${userData['username']}',
                    style:
                        const TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  Text(user?.email ?? 'No Email',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Profile'),
                    onTap: editProfile,
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Change Profile Picture'),
                    onTap: changeProfilePicture,
                  ),
                ],
              ),
      ),
    );
  }
}
