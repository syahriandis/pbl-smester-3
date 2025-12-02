import 'dart:io';
import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:login_tes/widgets/main_layout_rt.dart';
import 'package:login_tes/widgets/info_card_widget_rt.dart';
import 'package:login_tes/widgets/info_detail_dialog_rt.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class InformasiPageRT extends StatefulWidget {
  const InformasiPageRT({super.key});

  @override
  InformasiPageRTState createState() => InformasiPageRTState();
}

class InformasiPageRTState extends State<InformasiPageRT> {
  final List<Map<String, String>> informasiList = [];

  void _showAddInfoDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController dayController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    String? imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Informasi"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Judul"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dayController,
                  decoration: const InputDecoration(labelText: "Hari"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: "Tanggal"),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: "Waktu"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: "Lokasi"),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        imagePath = pickedFile.path;
                      });
                    }
                  },
                  child: imagePath == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : Image.file(
                          File(imagePath!),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  informasiList.add({
                    'image': imagePath ?? 'assets/images/maulidd.jpg',
                    'title': titleController.text,
                    'day': dayController.text,
                    'date': dateController.text,
                    'time': timeController.text,
                    'location': locationController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan dialog edit informasi
  void _showEditInfoDialog(int index) {
    final Map<String, String> info = informasiList[index];
    final TextEditingController titleController = TextEditingController(
      text: info['title'],
    );
    final TextEditingController dayController = TextEditingController(
      text: info['day'],
    );
    final TextEditingController dateController = TextEditingController(
      text: info['date'],
    );
    final TextEditingController timeController = TextEditingController(
      text: info['time'],
    );
    final TextEditingController locationController = TextEditingController(
      text: info['location'],
    );
    String? imagePath = info['image'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Informasi"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Judul"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dayController,
                  decoration: const InputDecoration(labelText: "Hari"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: "Tanggal"),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: "Waktu"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: "Lokasi"),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        imagePath = pickedFile.path;
                      });
                    }
                  },
                  child: imagePath == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : Image.file(
                          File(imagePath!),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  informasiList[index] = {
                    'image': imagePath ?? 'assets/images/maulidd.jpg',
                    'title': titleController.text,
                    'day': dayController.text,
                    'date': dateController.text,
                    'time': timeController.text,
                    'location': locationController.text,
                  };
                });
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // Menghapus informasi
  void _deleteInfo(int index) {
    setState(() {
      informasiList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayoutRT(
      selectedIndex: 2,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logoputih.png', height: 50),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/avatar.jpg'),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Warga",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _showAddInfoDialog,
                    child: const Icon(Icons.add, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: informasiList.length,
                      itemBuilder: (context, index) {
                        final info = informasiList[index];
                        return GestureDetector(
                          onTap: () => showInfoDetailDialog(context, info),
                          child: InfoCardWidgetRT(
                            imagePath: info['image']!,
                            title: info['title']!,
                            subtitle: info['location']!,
                            onEdit: () => _showEditInfoDialog(index), // Edit
                            onDelete: () => _deleteInfo(index), // Delete
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
