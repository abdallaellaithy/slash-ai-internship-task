import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nn/Respones.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? choice;
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton(
                dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                value: choice,
                onChanged: (value_) {
                  setState(() {
                    choice = value_.toString();
                  });
                },
                items: List_item.map((valueItem) {
                  return DropdownMenuItem(
                    value: valueItem,
                    child: Text(valueItem, style: const TextStyle(fontSize: 9, color: Colors.black)),
                  );
                }).toList(),
              ),
              const Padding(padding: EdgeInsets.all(30)),
              MaterialButton(
                color: Colors.red,
                child: const Text('Open Gallery', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  _pickImageFromGallery();
                },
              ),
              const Padding(padding: EdgeInsets.all(10)),
              MaterialButton(
                color: Colors.red,
                child: const Text('Open Camera', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  _pickImageFromCamera();
                },
              ),
              const SizedBox(height: 10, width: 10),
              selectedImage != null ? Image.file(selectedImage!) : const Text('Please select an image')
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final File file = File(image.path);

    setState(() {
      selectedImage = file;
    });

    await _sendImageToAPI(file);
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    final File file = File(image.path);

    setState(() {
      selectedImage = file;
    });

    await _sendImageToAPI(file);
  }

  Future<void> _sendImageToAPI(File image) async {
    try {
      final Uri apiUrl = Uri.parse('http://localhost:8000/predict');
      final http.MultipartRequest request = http.MultipartRequest('POST', apiUrl);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      final http.StreamedResponse response = await request.send();
      final String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Response("Prediction: $responseBody")),
        );
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}