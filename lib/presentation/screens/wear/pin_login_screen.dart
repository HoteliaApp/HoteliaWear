import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wear_main_screen.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _pin = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('linkedUserId') != null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WearMainScreen()),
        );
      }
    }
  }

  void _onKeypadTap(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
      });
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('wearablePin', isEqualTo: _pin)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userId = snapshot.docs.first.id;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('linkedUserId', userId);
        
        // Limpiar el pin
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'wearablePin': FieldValue.delete(),
        });

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WearMainScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN Incorrecto')),
          );
          setState(() {
            _pin = '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ingresa tu PIN',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  _pin.padRight(4, '-'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    letterSpacing: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (var i = 1; i <= 9; i++)
                        _buildKey(i.toString()),
                      _buildKey(''),
                      _buildKey('0'),
                      IconButton(
                        icon: const Icon(Icons.backspace, color: Colors.white),
                        onPressed: _onBackspace,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildKey(String value) {
    if (value.isEmpty) return const SizedBox();
    return InkWell(
      onTap: () => _onKeypadTap(value),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
