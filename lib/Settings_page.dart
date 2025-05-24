import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_settings/app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _sendSupportMessage(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF0F8FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                "Send Feedback",
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              content: TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Enter your message here...",
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel", style: TextStyle(color: Colors.blueAccent)),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Send"),
                  onPressed: () async {
                    final message = messageController.text.trim();
                    final user = FirebaseAuth.instance.currentUser;

                    if (message.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a message")),
                      );
                      return;
                    }

                    if (user != null) {
                      try {
                        await FirebaseFirestore.instance.collection('support_messages').add({
                          'userId': user.uid,
                          'message': message,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        Navigator.pop(context); // close the dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Feedback sent!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error sending message: $e")),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearCache(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cache cleared!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsTile(
            icon: Icons.cleaning_services,
            title: "Clear Cache",
            subtitle: "Reset image and text fields",
            onTap: () => _clearCache(context),
          ),
          _buildSettingsTile(
            icon: Icons.feedback,
            title: "Send Feedback",
            subtitle: "Let us know what you think",
            onTap: () => _sendSupportMessage(context),
          ),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: "Notification Settings",
            subtitle: "Manage app permissions",
            onTap: () => AppSettings.openAppSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.black54)) : null,
        onTap: onTap,
      ),
    );
  }
}
