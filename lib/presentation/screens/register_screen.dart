import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';
import '../../core/config/app_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+237 ');
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final auth = context.read<AuthProvider>();
    final ok = await auth.registerWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      displayName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = ok ? null : (auth.lastError ?? 'Inscription échouée.');
    });
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B1727)),
        title: const Text(
          'Créer un compte',
          style: TextStyle(
            color: Color(0xFF0B1727),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              const Text(
                'Quelques infos pour personnaliser votre expérience Civio.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              _field(
                label: 'Nom complet',
                child: TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoration('Ex. Marie Ngono'),
                  validator: (v) =>
                      (v == null || v.trim().length < 2)
                          ? 'Nom trop court.'
                          : null,
                ),
              ),
              const SizedBox(height: 14),
              _field(
                label: 'E-mail',
                child: TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: _decoration('vous@exemple.com'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'E-mail requis.';
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'E-mail invalide.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 14),
              _field(
                label: 'Téléphone',
                child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _decoration('+237 6XX XX XX XX'),
                  validator: (v) {
                    if (v == null || v.trim().length < 8) {
                      return 'Numéro de téléphone requis.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 14),
              _field(
                label: 'Mot de passe',
                child: TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: _decoration('').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF6B7280),
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return '6 caractères minimum.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 14),
              _field(
                label: 'Confirmer le mot de passe',
                child: TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure,
                  decoration: _decoration(''),
                  validator: (v) =>
                      v != _passwordCtrl.text ? 'Ne correspond pas.' : null,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                _errorBox(_error!),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: (_submitting || AppConfig.isDemoMode)
                    ? null
                    : _doRegister,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0B6B4A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Créer mon compte'),
              ),
              if (AppConfig.isDemoMode) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: const Text(
                    'Mode démo : l\'inscription est désactivée car Firebase n\'est pas configuré.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
        child,
      ],
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0B6B4A), width: 1.4),
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              size: 18, color: Color(0xFFB91C1C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFB91C1C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
