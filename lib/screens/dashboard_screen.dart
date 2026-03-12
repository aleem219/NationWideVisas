import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'file_viewer_screen.dart';
import 'phone_login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? loginMode;
  final String? loginValue;

  const DashboardScreen({
    super.key,
    this.loginMode,
    this.loginValue,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _uploadedFile;
  String? _uploadedFileName;
  bool _isLoading = false;
  bool _isDataSaved = false;

  static const _keyName = 'dashboard_name';
  static const _keyEmail = 'dashboard_email';
  static const _keyPhone = 'dashboard_phone';
  static const _keyFilePath = 'dashboard_file_path';
  static const _keyFileName = 'dashboard_file_name';
  static const _keySubmitted = 'dashboard_submitted';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedName = prefs.getString(_keyName) ?? '';
    final savedEmail = prefs.getString(_keyEmail) ?? '';
    final savedPhone = prefs.getString(_keyPhone) ?? '';
    final savedPath = prefs.getString(_keyFilePath);
    final savedFile = prefs.getString(_keyFileName);
    final wasSubmitted = prefs.getBool(_keySubmitted) ?? false;

    final effectivePhone = savedPhone.isNotEmpty
        ? savedPhone
        : (widget.loginMode == 'phone' ? widget.loginValue ?? '' : '');

    final effectiveEmail = savedEmail.isNotEmpty
        ? savedEmail
        : (widget.loginMode == 'email' ? widget.loginValue ?? '' : '');

    File? restoredFile;
    String? restoredFileName;

    if (savedPath != null && savedFile != null) {
      final f = File(savedPath);
      if (f.existsSync()) {
        restoredFile = f;
        restoredFileName = savedFile;
      }
    }

    setState(() {
      _nameController.text = savedName;
      _emailController.text = effectiveEmail;
      _phoneController.text = effectivePhone;
      _uploadedFile = restoredFile;
      _uploadedFileName = restoredFileName;
      _isDataSaved = wasSubmitted;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyName, _nameController.text.trim());
    await prefs.setString(_keyEmail, _emailController.text.trim());
    await prefs.setString(_keyPhone, _phoneController.text.trim());
    await prefs.setBool(_keySubmitted, true);

    if (_uploadedFile != null && _uploadedFileName != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final destPath = '${appDir.path}/$_uploadedFileName';

      if (_uploadedFile!.path != destPath) {
        await _uploadedFile!.copy(destPath);
      }

      await prefs.setString(_keyFilePath, destPath);
      await prefs.setString(_keyFileName, _uploadedFileName!);
    }
  }

  Future<void> _clearData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyName);
  await prefs.remove(_keyEmail);
  await prefs.remove(_keyPhone);
  await prefs.remove(_keyFilePath);
  await prefs.remove(_keyFileName);
  await prefs.remove(_keySubmitted);

  setState(() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _uploadedFile = null;
    _uploadedFileName = null;
    _isDataSaved = false;
  });

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Data is removed"),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _uploadedFile = File(result.files.single.path!);
        _uploadedFileName = result.files.single.name;
      });
    }
  }

  void _removeFile() async {
  setState(() {
    _uploadedFile = null;
    _uploadedFileName = null;
  });

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyFilePath);
  await prefs.remove(_keyFileName);
}

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await _saveData();

    setState(() {
      _isLoading = false;
      _isDataSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved successfully!'),
        backgroundColor: Color(0xFFD32F2F),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 20,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFD32F2F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.dashboard_rounded,
                      color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            const Text(
                              'Your Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildTextField(
                              controller: _nameController,
                              label: 'Name',
                              icon: Icons.person_outline,
                              validator: (v) =>
                                  v!.isEmpty ? 'Enter name' : null,
                            ),

                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              validator: (v) =>
                                  v!.isEmpty ? 'Enter email' : null,
                            ),

                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: _phoneController,
                              label: 'Phone',
                              icon: Icons.phone_outlined,
                              validator: (v) =>
                                  v!.isEmpty ? 'Enter phone' : null,
                            ),

                            const SizedBox(height: 24),

                            OutlinedButton.icon(
  onPressed: _pickFile,
  icon: const Icon(
    Icons.upload_file_rounded,
    size: 20,
  ),
  label: Text(
    _uploadedFile == null ? 'Upload Document' : 'Change File',
  ),
  style: OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFFD32F2F),
    side: const BorderSide(
      color: Color(0xFFD32F2F),
      width: 1.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 14),
  ),
),

if (_uploadedFile != null) ...[
  const SizedBox(height: 16),

  GestureDetector(
    onTap: () {
      final ext =
          _uploadedFileName?.split('.').last.toLowerCase() ?? '';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FileViewerScreen(
            file: _uploadedFile!,
            fileName: _uploadedFileName ?? 'Document',
            fileExt: ext,
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                (_uploadedFileName
                        ?.split('.')
                        .last
                        .toUpperCase() ??
                    'FILE'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _uploadedFileName ?? 'Document',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Tap to preview',
                  style: TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.visibility_outlined,
            color: Color(0xFFD32F2F),
            size: 18,
          ),

          const SizedBox(width: 4),

          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF9E9E9E),
              size: 20,
            ),
            onPressed: _removeFile,
          ),
        ],
      ),
    ),
  ),
],

                            if (_isDataSaved)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _clearData,
                                  child: const Text("Clear Data"),
                                ),
                              ),

                            const SizedBox(height: 24),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD32F2F),
                                  foregroundColor: Colors.white,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text("Submit"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFD32F2F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}