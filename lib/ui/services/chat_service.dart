import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final supabase = Supabase.instance.client;

  // STREAM CONTROLLER PARA MENSAJES EN TIEMPO REAL
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  RealtimeChannel? _canal;

  // -------------------------------------------------------------
  // ENVIAR MENSAJE
  // -------------------------------------------------------------
  Future<void> enviarMensaje({
    required String emisorId,
    required String receptorId,
    required String contenido,
  }) async {
    await supabase.from('mensaje').insert({
      'id_usuario': emisorId,
      'receptor_id': receptorId,
      'contenido': contenido,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // -------------------------------------------------------------
  // OBTENER HISTORIAL DE MENSAJES ENTRE DOS USUARIOS
  // -------------------------------------------------------------
  Future<List<Map<String, dynamic>>> obtenerMensajes({
    required String miId,
    required String otroId,
  }) async {
    final respuesta = await supabase
        .from('mensaje')
        .select()
        .or(
        'and(id_usuario.eq.$miId,receptor_id.eq.$otroId),'
            'and(id_usuario.eq.$otroId,receptor_id.eq.$miId)'
    )
        .order('timestamp', ascending: true);

    return respuesta;
  }

  // -------------------------------------------------------------
  // ESCUCHAR MENSAJES EN TIEMPO REAL (DESACTIVADO)
  // Lo gestiona chat_details.
  // -------------------------------------------------------------
  Stream<Map<String, dynamic>> escucharMensajes({
    required String miId,
    required String otroId,
  }) {
    return const Stream.empty();
  }

  // -------------------------------------------------------------
  // CERRAR STREAM Y CANAL
  // -------------------------------------------------------------
  void dispose() {
    _controller.close();
    if (_canal != null) {
      supabase.removeChannel(_canal!);
    }
  }
}
