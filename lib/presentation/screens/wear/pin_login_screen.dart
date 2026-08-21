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
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.watch, color: Colors.blueAccent, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'HOTEL WEAR',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _pin.padRight(4, '·'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.4,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: [
                      for (var i = 1; i <= 9; i++)
                        _buildKey(i.toString()),
                      _buildKey(''),
                      _buildKey('0'),
                      InkWell(
                        onTap: _onBackspace,
                        customBorder: const CircleBorder(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.backspace, color: Colors.white70, size: 18),
                        ),
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
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
