class Validators {
  static String? name(String value) {
    if (value.trim().length < 3) return 'Nombre inválido';
    return null;
  }

  static String? email(String value) {
    final email = value.trim();
    const pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$';
    if (!RegExp(pattern).hasMatch(email)) return 'Correo inválido';
    return null;
  }

  static String? phone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) return 'Teléfono inválido';
    return null;
  }

  static String? password(String value) {
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Incluye una mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Incluye una minúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Incluye un número';
    return null;
  }
}
