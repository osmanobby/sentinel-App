import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/user_service.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _codeController = TextEditingController();
  final _userService = UserService();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _linkChild() async {
    final code = _codeController.text.trim().toUpperCase();
    final parentUid = _auth.currentUser?.uid;

    if (code.isEmpty || parentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid code.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await _userService.linkChild(parentUid: parentUid, childCode: code);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child linked successfully!')),
      );
      Navigator.pop(context, true); // Pass true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to link child. Please check the code and try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Child'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Enter the unique code from your child\'s device to link their account.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Child\'s Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _linkChild,
                    child: const Text('Link Child Account'),
                  ),
          ],
        ),
      ),
    );
  }
}
