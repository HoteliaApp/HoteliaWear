import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
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
      setState(() => _pin += value);
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
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
            SnackBar(
              content: const Text('PIN Incorrecto'),
              backgroundColor: AppStatusColors.of(context).danger,
            ),
          );
          setState(() => _pin = '');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.hotel_rounded,
                      color: AppColors.primary,
                      size: AppIconSize.sm,
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Text(
                      'HOTELIA WEAR',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _pin.padRight(4, '·'),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: cs.onSurface,
                    letterSpacing: 10,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    mainAxisSpacing: AppSpacing.xs,
                    crossAxisSpacing: AppSpacing.xs,
                    children: [
                      for (var i = 1; i <= 9; i++) _buildKey(i.toString()),
                      _buildKey(''),
                      _buildKey('0'),
                      InkWell(
                        onTap: _onBackspace,
                        customBorder: const CircleBorder(),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceDark,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.backspace_rounded,
                            color: cs.onSurfaceVariant,
                            size: AppIconSize.md,
                          ),
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
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _onKeypadTap(value),
      customBorder: const CircleBorder(),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
