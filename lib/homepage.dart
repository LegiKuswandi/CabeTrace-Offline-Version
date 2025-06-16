import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../helper/image_classification_helper.dart';
import '../db/db_helper.dart';
import 'riwayat.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, this.username = "Legi"});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;
  img.Image? _image;
  Map<String, double>? _classification;
  bool _isLoading = false;

  late final ImageClassificationHelper _imageClassificationHelper;

  @override
  void initState() {
    super.initState();
    _imageClassificationHelper = ImageClassificationHelper();
    _imageClassificationHelper.initHelper();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isLoading = true;
        _classification = null;
      });

      final imageData = await _selectedImage!.readAsBytes();
      _image = img.decodeImage(imageData);
      if (_image != null) {
        _classification =
            await _imageClassificationHelper.inferenceImage(_image!);
      }

      _isLoading = false;
      setState(() {});

      if (_classification != null) {
        final top = _classification!.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final prediction = top.first.key;
        final confidence = top.first.value;

        final now = DateTime.now().toIso8601String();
        await DBHelper().insertHistory({
          'image_path': _selectedImage!.path,
          'result': prediction,
          'confidence': confidence,
          'timestamp': now,
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hasil Identifikasi'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImage != null)
                  Image.file(_selectedImage!, height: 120),
                const SizedBox(height: 12),
                Text("Hasil: $prediction"),
                Text("Akurasi: ${(confidence * 100).toStringAsFixed(2)}%"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _imageClassificationHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/bawahm.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  color: const Color(0xFF008705),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selamat Datang',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Center(child: Image.asset('assets/images/logow.png', height: 100)),
                const SizedBox(height: 60),
                const Center(
                  child: Text(
                    'Mulai Identifikasi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(
                        icon: Icons.camera_alt,
                        label: 'Ambil Gambar',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      _actionButton(
                        icon: Icons.upload,
                        label: 'Unggah Gambar',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    'Ambil dan unggah gambar daun saja',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RiwayatIdentifikasiPage(username: widget.username),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Riwayat Identifikasi',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF008705),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
