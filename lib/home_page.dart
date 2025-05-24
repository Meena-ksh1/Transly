import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'history.dart';
import 'Settings_page.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sourceController = TextEditingController();
  final _translatedController = TextEditingController();
  File? _selectedImage;
  bool _isTranslating = false;
  String? _selectedFromLanguage = 'en';
  String? _selectedToLanguage = 'hi';

  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'Hindi'},
    {'code': 'bn', 'name': 'Bengali'},
    {'code': 'te', 'name': 'Telugu'},
    {'code': 'mr', 'name': 'Marathi'},
    {'code': 'pa', 'name': 'Punjabi'},
  ];

  Future<void> _translateText() async {
    final inputText = _sourceController.text.trim();
    if (inputText.isEmpty) return;

    final wordCount = inputText.split(RegExp(r'\s+')).length;
    if (wordCount > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Input text exceeds 150 words.')),
      );
      return;
    }

    setState(() => _isTranslating = true);

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(inputText)}&langpair=$_selectedFromLanguage|$_selectedToLanguage',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = data['responseData']['translatedText'];

        if (translated != null && translated.isNotEmpty) {
          setState(() => _translatedController.text = translated);

          try {
            await FirebaseFirestore.instance.collection('translations').add({
              'source': inputText,
              'translated': translated,
              'timestamp': FieldValue.serverTimestamp(),
              'user': FirebaseAuth.instance.currentUser?.uid,
            });
          } catch (e) {
            debugPrint('Firestore logging failed: $e');
            _showError('Translation succeeded but failed to log to database.');
          }
        } else {
          _showError('Translation API returned empty result.');
        }
      } else {
        _showError('Translation API error (status: ${response.statusCode}).');
      }
    } catch (e) {
      debugPrint('Translation exception: $e');
      _showError('Network or API failure. Please try again.');
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;

    final savedImage = await _saveFileLocally(picked.path);
    setState(() => _selectedImage = savedImage);
    await _performOCR(savedImage);
  }

  Future<File> _saveFileLocally(String path) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = p.basename(path);
    final newPath = p.join(directory.path, name);
    return File(path).copy(newPath);
  }

  Future<void> _performOCR(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await recognizer.processImage(inputImage);
    recognizer.close();

    final text = recognizedText.text;
    final truncatedText = text.length > 500 ? text.substring(0, 500) : text;

    setState(() => _sourceController.text = truncatedText);

    await FirebaseFirestore.instance.collection('translations').add({
      'imagePath': imageFile.path,
      'extractedText': truncatedText,
      'timestamp': FieldValue.serverTimestamp(),
      'user': FirebaseAuth.instance.currentUser?.uid,
    });
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final List<String> pages = await ReadPdfText.getPDFtextPaginated(filePath);
      final text = pages.join(' ');
      final truncatedText = text.length > 500 ? text.substring(0, 500) : text;

      setState(() => _sourceController.text = truncatedText);

      await FirebaseFirestore.instance.collection('translations').add({
        'pdfPath': filePath,
        'extractedText': truncatedText,
        'timestamp': FieldValue.serverTimestamp(),
        'user': FirebaseAuth.instance.currentUser?.uid,
      });
    }
  }

  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _clearText() {
    _sourceController.clear();
    _translatedController.clear();
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Colors.blue[400]!;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Translator", style: TextStyle(color: Colors.black87)),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logOut),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, height: 150),
                      )
                    else
                      const Text("No image selected", textAlign: TextAlign.center),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildImageButton(Icons.image, "Gallery", () => _pickImage(ImageSource.gallery), primaryBlue),
                        _buildImageButton(Icons.camera_alt, "Camera", () => _pickImage(ImageSource.camera), primaryBlue),
                        _buildImageButton(Icons.picture_as_pdf, "PDF", _pickPdf, primaryBlue),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: _buildDropdown("From", _selectedFromLanguage, (val) => setState(() => _selectedFromLanguage = val), primaryBlue)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown("To", _selectedToLanguage, (val) => setState(() => _selectedToLanguage = val), primaryBlue)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(_sourceController, "Text to Translate", false, maxLength: 500),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isTranslating ? null : _translateText,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isTranslating
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text("Translate", style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: _clearText,
                          icon: const Icon(Icons.clear),
                          color: Colors.red,
                          tooltip: "Clear Text",
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    _buildTextField(_translatedController, "Translated Text", true),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        backgroundColor: primaryBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, ValueChanged<String?> onChanged, Color color) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: languages.map((lang) {
        return DropdownMenuItem(value: lang['code'], child: Text(lang['name']!, style: const TextStyle(color: Colors.black87)));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool readOnly, {int? maxLength}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: 4,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildImageButton(IconData icon, String label, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.black),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}