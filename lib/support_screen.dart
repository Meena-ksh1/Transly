import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture and Name
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user?.photoURL ??
                        'https://www.example.com/default_avatar.png'),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${user?.displayName ?? 'Not Available'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Email: ${user?.email ?? 'Not Available'}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Change Photo Button (if required)
              ElevatedButton(
                onPressed: () {
                  // Logic to change profile photo (if required)
                },
                child: Text('Change Profile Photo'),
              ),
              SizedBox(height: 20),

              // Update Name Button (if required)
              ElevatedButton(
                onPressed: () async {
                  // Show a dialog to update name (you can use TextField to get input)
                  await showDialog(
                    context: context,
                    builder: (context) {
                      TextEditingController nameController =
                      TextEditingController();
                      return AlertDialog(
                        title: Text('Update Name'),
                        content: TextField(
                          controller: nameController,
                          decoration: InputDecoration(hintText: 'Enter new name'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (nameController.text.isNotEmpty) {
                                user?.updateDisplayName(nameController.text);
                                Navigator.pop(context);
                              }
                            },
                            child: Text('Update'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Update Name'),
              ),
              SizedBox(height: 20),

              // Logout Button
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
