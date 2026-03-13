import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';

class ConfigDialog extends ConsumerStatefulWidget {
  const ConfigDialog({super.key});

  @override
  ConsumerState<ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends ConsumerState<ConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _apiSecretController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _apiKeyController = TextEditingController();
    _apiSecretController = TextEditingController();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    const storage = FlutterSecureStorage();
    final url = await storage.read(key: AppConstants.keyBaseUrl);
    final key = await storage.read(key: AppConstants.keyApiKey);
    final secret = await storage.read(key: AppConstants.keyApiSecret);

    if (mounted) {
      setState(() {
        _urlController.text = url ?? '';
        _apiKeyController.text = key ?? '';
        _apiSecretController.text = secret ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    const textColor = Color(0xFF1E293B);
    const labelColor = Color(0xFF334155);
    const buttonColor = Color(0xFF171717);
    const borderColor = Color(0xFFE2E8F0);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Server Configuration',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your ERPNext credentials below',
                textAlign: TextAlign.center,
                style: TextStyle(color: labelColor, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // URL Field
              const Text(
                'ERPNext URL',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://erp.yoursite.com',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(Icons.language, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF1F41BB),
                    ), // AppTheme primary approx
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'URL required' : null,
              ),
              const SizedBox(height: 20),

              // API Key
              const Text(
                'API Key',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  hintText: 'Enter API Key',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(
                    Icons.vpn_key_outlined,
                    color: Colors.black54,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // API Secret
              const Text(
                'API Secret',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _apiSecretController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.black54,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await ref
                        .read(authProvider.notifier)
                        .saveConfig(
                          baseUrl: _urlController.text.trim(),
                          apiKey: _apiKeyController.text.trim(),
                          apiSecret: _apiSecretController.text.trim(),
                        );
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Configuration',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }
}
