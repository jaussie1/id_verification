import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import 'web_camera_dialog.dart';

class IdVerificationScreen extends StatefulWidget {
  final String? flow; // 'business' or 'individual'
  const IdVerificationScreen({super.key, this.flow});

  @override
  State<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen> {
  XFile? _imageFile;
  bool _isVerifying = false;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? pickedFile;
      
      if (kIsWeb && source == ImageSource.camera) {
        pickedFile = await showDialog<XFile>(
          context: context,
          builder: (context) => const WebCameraDialog(),
        );
      } else {
        pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
      }

      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = pickedFile;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error picking image: $e');
      }
    }
  }

  Future<void> _verifyId() async {
    if (_imageFile == null) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      if (!mounted) return;
      
      final userProvider = context.read<UserProvider>();
      await userProvider.verifyId(bytes, _imageFile!.name);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID Verified successfully!')),
        );
        
        if (widget.flow == 'business') {
          context.go('/verify-business');
        } else {
          context.go('/marketplace');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _continueAsBuyer() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proceeding as Buyer. You can verify your identity later!')),
      );
      context.go('/marketplace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusinessFlow = widget.flow == 'business';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isBusinessFlow ? 'Business Verification - Step 1' : 'Identity Verification'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.verified_user, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              isBusinessFlow ? 'Step 1: ID Check' : 'Seller Identity Check',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'To ensure a safe marketplace, all sellers must verify their identity. Please upload a clear photo of your government-issued ID.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            if (_imageFile != null)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 350,
                        maxWidth: 500,
                      ),
                      child: kIsWeb 
                        ? Image.network(_imageFile!.path)
                        : Image.file(File(_imageFile!.path)),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No ID photo selected', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (!_isVerifying) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _imageFile == null ? null : _verifyId,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Verify My ID', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('OR', style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _continueAsBuyer,
                child: const Text('Proceed as Buyer Only', style: TextStyle(fontSize: 16)),
              ),
            ] else
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('AI Model is verifying your ID...'),
                  const Text('Please wait a moment.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            
            const SizedBox(height: 32),
            TextButton(
              onPressed: _isVerifying ? null : () => context.read<UserProvider>().logout(),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
