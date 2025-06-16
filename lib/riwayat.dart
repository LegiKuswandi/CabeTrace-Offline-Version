import 'dart:io';
import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class RiwayatIdentifikasiPage extends StatefulWidget {
  final String username;

  const RiwayatIdentifikasiPage({super.key, required this.username});

  @override
  State<RiwayatIdentifikasiPage> createState() => _RiwayatIdentifikasiPageState();
}

class _RiwayatIdentifikasiPageState extends State<RiwayatIdentifikasiPage> {
  List<Map<String, dynamic>> riwayat = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    final data = await DBHelper().getAllHistory();
    setState(() {
      riwayat = data;
      isLoading = false;
    });
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
                  color: const Color(0xFF017A17),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Riwayat Identifikasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.history, color: Colors.white),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : riwayat.isEmpty
                          ? const Center(child: Text("Belum ada riwayat."))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: riwayat.length,
                              itemBuilder: (context, index) {
                                final item = riwayat[index];
                                final tanggal = item['timestamp'].toString().split('.')[0];
                                final confidence = (item['confidence'] * 100).toStringAsFixed(1) + '%';
                                final imagePath = item['image_path'];
                                return _riwayatCard(
                                  id: item['id'],
                                  tanggal: tanggal,
                                  jenis: item['result'],
                                  confident: confidence,
                                  gambarUrl: imagePath,
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _riwayatCard({
    required int id,
    required String tanggal,
    required String jenis,
    required String confident,
    required String gambarUrl,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: File(gambarUrl).existsSync()
            ? Image.file(
                File(gambarUrl),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.broken_image),
        ),
        title: Text(jenis, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tanggal),
            const SizedBox(height: 4),
            Text('Akurasi: $confident', style: const TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            await DBHelper().deleteHistory(id);
            fetchRiwayat(); // refresh list
          },
        ),
      ),
    );
  }
}
