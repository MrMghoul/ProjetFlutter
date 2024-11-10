import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html; // Pour Flutter Web
import 'dart:io' show File; // Pour Flutter Mobile
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AjoutVetement extends StatefulWidget {
  @override
  _AjoutVetementState createState() => _AjoutVetementState();
}

class _AjoutVetementState extends State<AjoutVetement> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  String? _category;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  final List<String> categories = [
    "t-shirt", "robe", "longue robe", "costume", "manteau en fourrure",
    "manteau", "chapeau", "veste", "pull / chemise", "bottes", "chaussures",
    "chaussettes", "Echarpe", "casquette"
  ];

  Future<String?> predictCategory(Uint8List imageBytes) async {
    //final Uri url = Uri.parse('https://backfluttersimple.onrender.com/predict');
    final Uri url = Uri.parse('http://localhost:5000/predict');

    final request = http.MultipartRequest('POST', url);
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final Map<String, dynamic> json = jsonDecode(responseData);
        return json['category'];
      } else {
        print('Erreur de requête: ${response.statusCode}');
        return 'Erreur de prédiction';
      }
    } catch (e) {
      print('Erreur: $e');
      return 'Erreur de prédiction';
    }
  }

  Future<void> _chooseImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List imageBytes;

        if (kIsWeb) {
          imageBytes = await pickedFile.readAsBytes();
        } else {
          File imageFile = File(pickedFile.path);
          imageBytes = await imageFile.readAsBytes();
        }

        setState(() {
          String imageType = pickedFile.mimeType!.split('/').last;
          _base64Image = 'data:image/$imageType;base64,' + base64Encode(imageBytes);
        });

        String? category = await predictCategory(imageBytes);
        if (category != null) {
          setState(() {
            _category = category;
            _categoryController.text = category;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de sélection d\'image: $e')),
      );
    }
  }

  Future<void> _saveClothing() async {
    if (_titleController.text.isEmpty ||
        _sizeController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _category == null ||
        _base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('vetement').add({
      'titre': _titleController.text,
      'image': _base64Image,
      'categorie': _category,
      'taille': _sizeController.text,
      'marque': _brandController.text,
      'prix': double.tryParse(_priceController.text),
    });

    _titleController.clear();
    _sizeController.clear();
    _brandController.clear();
    _priceController.clear();
    _categoryController.clear();
    setState(() {
      _category = null;
      _base64Image = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vêtement ajouté avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Vêtement'),
        backgroundColor: const Color(0xFF8B4513),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: _chooseImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Ajouter une Image', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),

            if (_base64Image != null) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 8)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(_base64Image!.split(',').last),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildTextField(_titleController, 'Titre'),
                    buildTextField(_sizeController, 'Taille'),
                    buildTextField(_categoryController, 'Catégorie', readOnly: false),
                    buildTextField(_brandController, 'Marque'),
                    buildTextField(_priceController, 'Prix', isNumeric: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveClothing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Valider', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {bool readOnly = false, bool isNumeric = false}) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          readOnly: readOnly,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
