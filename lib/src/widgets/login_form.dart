// login_form.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'privacy_checkbox.dart';

// --- Paleta de Colores (Coherente con HomePage) ---
const Color kPrimaryColor = Color(0xFF7E57C2);
const Color kSurfaceColor = Colors.white;
const Color kTextPrimary = Color(0xFF332F3D);
const Color kAccentLight = Color(0xFFEDE7F6);

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final auth = AuthService();

  bool isRegister = false;
  bool loading = false;
  String? error;
  bool accepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // -----------------------
  // Validadores / Saneamiento
  // -----------------------
  String sanitizeText(String? v, {int maxLen = 250}) {
    if (v == null) return '';
    var s = v.trim();
    if (s.length > maxLen) s = s.substring(0, maxLen);
    s = s.replaceAll(RegExp(r'<[^>]*>'), '');
    return s;
  }

  String? _validateName(String? v) {
    if (!isRegister) return null;
    if (v == null || v.trim().isEmpty) return 'Nombre requerido';
    final s = sanitizeText(v, maxLen: 80);
    if (s.length < 2) return 'Nombre muy corto';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Correo requerido';
    final email = v.trim();
    final re = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$");
    if (!re.hasMatch(email)) return 'Correo inválido';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Contraseña requerida';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    final re = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    if (!re.hasMatch(v)) return 'Usa Mayúscula, número y símbolo (!@#)';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (!isRegister) return null;
    if (v == null || v.isEmpty) return 'Confirma la contraseña';
    if (v != passCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  // -----------------------
  // Submit
  // -----------------------
  Future<void> _submit() async {
    setState(() => error = null);

    if (!_formKey.currentState!.validate()) {
      setState(() => error = 'Por favor, corrige los campos en rojo');
      return;
    }

    if (isRegister && !accepted) {
      setState(() => error = 'Debes aceptar la política de privacidad.');
      return;
    }

    setState(() => loading = true);
    try {
      final name = sanitizeText(nameCtrl.text, maxLen: 80);
      final email = emailCtrl.text.trim();
      final password = passCtrl.text;

      if (isRegister) {
        await auth.signUpWithEmail(email, password, name);
      } else {
        await auth.signInWithEmail(email, password);
      }
      // La navegación suele manejarse con un StreamBuilder en el padre,
      // o puedes hacer Navigator.pushReplacement aquí.
    } catch (e) {
      setState(() => error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('email-already-in-use') || msg.contains('already')) {
      return 'El correo ya está registrado';
    } else if (msg.contains('weak-password') || msg.contains('weak')) {
      return 'Contraseña demasiado débil';
    } else if (msg.contains('invalid-email') || msg.contains('invalid')) {
      return 'Formato de correo inválido';
    } else if (msg.contains('user-not-found') || msg.contains('credential')) {
      return 'Credenciales incorrectas';
    } else if (msg.contains('network-request-failed')) {
      return 'Sin conexión a internet';
    }
    return 'Ocurrió un error inesperado';
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  // -----------------------
  // Estilos Helpers
  // -----------------------
  InputDecoration _buildDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kPrimaryColor.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.grey[50], // Fondo muy sutil para el input
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none, // Sin borde por defecto (estilo flat)
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade200),
      ),
    );
  }

  // -----------------------
  // UI
  // -----------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de la marca (opcional)
            const Icon(Icons.pets, size: 48, color: kPrimaryColor),
            const SizedBox(height: 12),

            Text(
              'PetCare',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isRegister
                  ? 'Crea una cuenta para tu mascota'
                  : 'Bienvenido de nuevo',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),

            const SizedBox(height: 24),

            // Selector Login / Registro estilizado
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((
                    Set<MaterialState> states,
                  ) {
                    if (states.contains(MaterialState.selected)) {
                      return kAccentLight;
                    }
                    return Colors.transparent;
                  }),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>((
                    Set<MaterialState> states,
                  ) {
                    if (states.contains(MaterialState.selected)) {
                      return kPrimaryColor;
                    }
                    return Colors.grey;
                  }),
                  side: MaterialStateProperty.all(
                    BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Iniciar sesión'),
                    icon: Icon(Icons.login),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Registrarse'),
                    icon: Icon(Icons.person_add),
                  ),
                ],
                selected: {isRegister},
                onSelectionChanged: (v) => setState(() {
                  isRegister = v.first;
                  error = null;
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Campos del formulario
            if (isRegister) ...[
              TextFormField(
                controller: nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: _buildDecoration(
                  'Nombre completo',
                  Icons.person_outline,
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _buildDecoration(
                'Correo electrónico',
                Icons.email_outlined,
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: passCtrl,
              obscureText: _obscurePassword,
              textInputAction: isRegister
                  ? TextInputAction.next
                  : TextInputAction.done,
              decoration: _buildDecoration('Contraseña', Icons.lock_outline)
                  .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
              validator: _validatePassword,
            ),

            if (isRegister) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmCtrl,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                decoration:
                    _buildDecoration(
                      'Confirmar contraseña',
                      Icons.lock_reset,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                validator: _validateConfirm,
              ),
              const SizedBox(height: 16),
              PrivacyCheckbox(
                accepted: accepted,
                onChanged: (v) => setState(() {
                  accepted = v;
                  error = null;
                }),
              ),
            ],

            // Mensajes de error
            if (error != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Botón de acción
            SizedBox(
              width: double.infinity,
              height: 54, // Botón más alto para mejor tacto
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: kPrimaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isRegister ? 'Crear cuenta' : 'Ingresar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
