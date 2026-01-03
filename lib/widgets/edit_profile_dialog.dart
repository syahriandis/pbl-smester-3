  import 'dart:convert';
  import 'dart:typed_data';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:image_picker/image_picker.dart';
  import 'package:login_tes/constants/colors.dart';

  class EditProfileDialog extends StatefulWidget {
    final String token;
    final Map<String, dynamic> currentData;

    const EditProfileDialog({
      super.key,
      required this.token,
      required this.currentData,
    });

    @override
    State<EditProfileDialog> createState() => _EditProfileDialogState();
  }

  class _EditProfileDialogState extends State<EditProfileDialog> {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _nikController = TextEditingController();
    final _phoneController = TextEditingController();
    final _addressController = TextEditingController();
    
    String? _selectedGender;
    Uint8List? _imageBytes;
    String? _imageFileName;
    bool _isLoading = false;

    final ImagePicker _picker = ImagePicker();

    @override
    void initState() {
      super.initState();
      _nameController.text = widget.currentData['name']?.toString() ?? '';
      _nikController.text = widget.currentData['nik']?.toString() ?? '';
      _phoneController.text = widget.currentData['phone']?.toString() ?? '';
      _addressController.text = widget.currentData['address']?.toString() ?? '';
      _selectedGender = widget.currentData['gender']?.toString();
    }

    @override
    void dispose() {
      _nameController.dispose();
      _nikController.dispose();
      _phoneController.dispose();
      _addressController.dispose();
      super.dispose();
    }

    Future<void> _pickImage(ImageSource source) async {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageBytes = bytes;
            _imageFileName = pickedFile.name;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memilih gambar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    void _showImageSourceDialog() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Pilih Sumber Foto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.camera_alt, color: primaryColor),
                    ),
                    title: const Text('Kamera'),
                    subtitle: const Text('Ambil foto baru'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.photo_library, color: secondaryColor),
                    ),
                    title: const Text('Galeri'),
                    subtitle: const Text('Pilih dari galeri'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
    }
  String _getPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) {
      return 'assets/images/avatar.jpg';
    }
    if (photo.startsWith('http')) {
      return photo;
    }
    
    // GANTI 127.0.0.1 jadi localhost biar konsisten
    return 'http://localhost:8000/storage/$photo';
  }

    Future<void> _updateProfile() async {
      if (!_formKey.currentState!.validate()) return;

      setState(() {
        _isLoading = true;
      });

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:8000/api/profile/update'), // ✅ Ganti ke localhost
        );
        request.headers['Authorization'] = 'Bearer ${widget.token}';
        request.headers['Accept'] = 'application/json';

        request.fields['name'] = _nameController.text.trim();
        request.fields['nik'] = _nikController.text.trim();
        request.fields['phone'] = _phoneController.text.trim();
        request.fields['address'] = _addressController.text.trim();
        
        if (_selectedGender != null) {
          request.fields['gender'] = _selectedGender!;
        }

        // Add image if selected - Compatible dengan Web & Mobile
        if (_imageBytes != null && _imageFileName != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'photo',
              _imageBytes!,
              filename: _imageFileName,
            ),
          );
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint("Update profile status: ${response.statusCode}");
        debugPrint("Update profile response: ${response.body}");

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Profil berhasil diperbarui'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Gagal memperbarui profil');
        }
      } catch (e) {
        debugPrint("Error update profile: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit, color: primaryColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Photo Section
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.3),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: _imageBytes != null
                                      ? MemoryImage(_imageBytes!)
                                      : (widget.currentData['photo'] != null &&
                                              widget.currentData['photo'].toString().isNotEmpty
                                          ? NetworkImage(
                                              _getPhotoUrl(widget.currentData['photo'].toString()),
                                            ) as ImageProvider
                                          : const AssetImage('assets/images/avatar.jpg')),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showImageSourceDialog,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [primaryColor, secondaryColor],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.5),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _imageBytes != null 
                                ? 'Foto baru dipilih' 
                                : 'Tap untuk ubah foto',
                            style: TextStyle(
                              color: _imageBytes != null ? Colors.green : Colors.grey,
                              fontSize: 12,
                              fontWeight: _imageBytes != null ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap',
                        prefixIcon: const Icon(Icons.person, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // NIK Field
                    TextFormField(
                      controller: _nikController,
                      decoration: InputDecoration(
                        labelText: 'NIK',
                        hintText: 'Masukkan 16 digit NIK',
                        prefixIcon: const Icon(Icons.badge, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'NIK tidak boleh kosong';
                        }
                        if (value.length != 16) {
                          return 'NIK harus 16 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Gender Field
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Jenis Kelamin',
                        prefixIcon: const Icon(Icons.wc, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: ['LAKI-LAKI', 'PEREMPUAN']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Row(
                                  children: [
                                    Icon(
                                      gender == 'LAKI-LAKI' ? Icons.male : Icons.female,
                                      size: 20,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(gender),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih jenis kelamin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon',
                        hintText: 'Contoh: 08123456789',
                        prefixIcon: const Icon(Icons.phone, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Alamat Lengkap',
                        hintText: 'Masukkan alamat lengkap',
                        prefixIcon: const Icon(Icons.home, color: primaryColor),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, color: whiteColor),
                                  SizedBox(width: 8),
                                  Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }