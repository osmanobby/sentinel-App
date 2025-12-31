import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:myapp/web_filter_model.dart';
import 'package:myapp/web_filter_service.dart';

class WebFilterScreen extends StatefulWidget {
  final String childId;

  const WebFilterScreen({super.key, required this.childId});

  @override
  State<WebFilterScreen> createState() => _WebFilterScreenState();
}

class _WebFilterScreenState extends State<WebFilterScreen> {
  final WebFilterService _webFilterService = WebFilterService();
  late Future<WebFilterSettings> _settingsFuture;
  WebFilterSettings? _settings;

  final TextEditingController _allowedController = TextEditingController();
  final TextEditingController _blockedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settingsFuture = _webFilterService.getWebFilterSettings(widget.childId);
  }

  void _saveSettings() {
    if (_settings != null) {
      _webFilterService.updateWebFilterSettings(widget.childId, _settings!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Filtering'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<WebFilterSettings>(
          future: _settingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            _settings ??= snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildToggleCard(),
                  const SizedBox(height: 24),
                  _buildWebsiteListCard(
                    title: 'Allowed Websites',
                    controller: _allowedController,
                    websites: _settings!.allowedWebsites,
                    onAdd: () {
                      if (_allowedController.text.isNotEmpty) {
                        setState(() {
                          _settings!.allowedWebsites.add(_allowedController.text);
                          _allowedController.clear();
                        });
                      }
                    },
                    onRemove: (index) {
                      setState(() {
                        _settings!.allowedWebsites.removeAt(index);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildWebsiteListCard(
                    title: 'Blocked Websites',
                    controller: _blockedController,
                    websites: _settings!.blockedWebsites,
                    onAdd: () {
                      if (_blockedController.text.isNotEmpty) {
                        setState(() {
                          _settings!.blockedWebsites.add(_blockedController.text);
                          _blockedController.clear();
                        });
                      }
                    },
                    onRemove: (index) {
                      setState(() {
                        _settings!.blockedWebsites.removeAt(index);
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: FilledButton(
                      onPressed: _saveSettings,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 16),
                      ),
                      child: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassMorphicCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildToggleCard() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return _buildGlassMorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Block Adult Content', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
              value: _settings!.blockAdultContent,
              onChanged: (value) {
                setState(() {
                  _settings!.blockAdultContent = value;
                });
              },
              activeThumbColor: colorScheme.primary,
            ),
            SwitchListTile(
              title: Text('Block Social Media', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
              value: _settings!.blockSocialMedia,
              onChanged: (value) {
                setState(() {
                  _settings!.blockSocialMedia = value;
                });
              },
               activeThumbColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsiteListCard({
    required String title,
    required TextEditingController controller,
    required List<String> websites,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return _buildGlassMorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Enter a website',
                labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: colorScheme.primary,
                  onPressed: onAdd,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...websites.asMap().entries.map((entry) {
              int index = entry.key;
              String website = entry.value;
              return ListTile(
                title: Text(website, style: TextStyle(color: colorScheme.onSurface)),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                  onPressed: () => onRemove(index),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
