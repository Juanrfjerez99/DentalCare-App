import 'package:supabase_flutter/supabase_flutter.dart';

class CitasService {
  final supabase = Supabase.instance.client;

  // UUID del dentista genérico
  static const String dentistaGlobalId = "b742d2cf-bf9a-4a27-87a8-478b1bb86d05";

  // ---------------------------------------------------
  // CREAR UNA CITA
  // ---------------------------------------------------
  Future<void> crearCita({
    required DateTime fecha,
    required String hora,
    required String userId,
  }) async {
    await supabase.from('cita').insert({
      'fecha': fecha.toIso8601String().split('T').first,
      'hora': "$hora:00",
      'estado': 'pendiente',
      'id_usuario': userId,
      'id_dentista': dentistaGlobalId,
    });
  }

  // ---------------------------------------------------
  // OBTENER HORAS OCUPADAS DE UN DÍA
  // ---------------------------------------------------
  Future<List<String>> getHorasOcupadas(DateTime fecha) async {
    final response = await supabase
        .from('cita')
        .select('hora')
        .eq('fecha', fecha.toIso8601String().split('T').first)
        .eq('id_dentista', dentistaGlobalId)
        .neq('estado', 'cancelada');

    return response.map<String>((row) {
      final time = row['hora'];
      return time.toString().substring(0, 5);
    }).toList();
  }

  // ---------------------------------------------------
  // SABER SI UN DÍA ESTÁ COMPLETO
  // ---------------------------------------------------
  Future<bool> diaCompleto(DateTime fecha) async {
    final horas = await getHorasOcupadas(fecha);
    return horas.length >= 7;
  }

  // ---------------------------------------------------
  // OBTENER CITAS DEL USUARIO (CLIENTE)
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getCitasUsuario(String userId) async {
    final response = await supabase
        .from('cita')
        .select()
        .eq('id_usuario', userId)
        .order('fecha', ascending: true)
        .order('hora', ascending: true);

    return response;
  }

  // ---------------------------------------------------
  // OBTENER CITAS DE UN DÍA (AGENDA DEL DENTISTA)
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getCitasPorDia(DateTime fecha) async {
    final response = await supabase
        .from('cita')
        .select('id_cita, fecha, hora, motivo, estado, usuario: id_usuario (nombre)')
        .eq('id_dentista', dentistaGlobalId)
        .eq('fecha', fecha.toIso8601String().split('T').first)
        .order('hora', ascending: true);

    return response;
  }

  // ---------------------------------------------------
  // OBTENER TODAS LAS CITAS (HISTORIAL DENTISTA)
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getTodasLasCitas() async {
    final response = await supabase
        .from('cita')
        .select('id_cita, fecha, hora, motivo, estado, usuario: id_usuario (nombre)')
        .order('fecha', ascending: false)
        .order('hora', ascending: false);

    return response;
  }

  // ---------------------------------------------------
  // NO SE USA, Lo dejamos por compatibilidad
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getCitasDentista() async {
    return await getTodasLasCitas();
  }

  // ---------------------------------------------------
  // OBTENER DÍAS DEL MES CON CITAS
  // ---------------------------------------------------
  Future<List<DateTime>> getDiasConCitas({
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);

    final response = await supabase
        .from('cita')
        .select('fecha')
        .eq('id_dentista', dentistaGlobalId)
        .gte('fecha', start.toIso8601String().split('T').first)
        .lte('fecha', end.toIso8601String().split('T').first);

    return response
        .map<DateTime>((row) => DateTime.parse(row['fecha']))
        .toList();
  }
}