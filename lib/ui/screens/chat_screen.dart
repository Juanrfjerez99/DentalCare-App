import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _loading = true;

  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();
    _load();
    _escucharCambios();
  }

  // ---------------------------------------------------
  // ESCUCHAR CAMBIOS EN TIEMPO REAL
  // ---------------------------------------------------
  void _escucharCambios() {
    final supabase = Supabase.instance.client;

    supabase
        .channel('chat_listen')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'mensaje',
      callback: (payload) {
        _load();
      },
    )
        .subscribe();
  }

  // ---------------------------------------------------
  // CARGAR LISTA DE CHATS + ÚLTIMO MENSAJE + NO LEÍDOS
  // ---------------------------------------------------
  Future<void> _load() async {
    try {
      setState(() => _loading = true);

      final supabase = Supabase.instance.client;
      final miId = supabase.auth.currentUser!.id;

      // Obtener rol del usuario
      final usuarioRow = await supabase
          .from('usuario')
          .select('rol')
          .eq('id', miId)
          .maybeSingle();

      String? miRol;

      if (usuarioRow != null && usuarioRow['rol'] != null) {
        miRol = usuarioRow['rol'];
      } else {
        final dentistaRow = await supabase
            .from('dentista')
            .select('rol')
            .eq('id', miId)
            .maybeSingle();

        miRol = dentistaRow?['rol'];
      }

      if (miRol == null) {
        setState(() => _loading = false);
        return;
      }

      // Obtener lista de usuarios, según rol
      List<dynamic> lista = [];

      if (miRol == 'paciente') {
        lista = await supabase
            .from('dentista')
            .select('id, nombre')
            .order('nombre');
      } else if (miRol == 'dentista') {
        lista = await supabase
            .from('usuario')
            .select('id, nombre')
            .eq('rol', 'paciente')
            .order('nombre');
      }

      // Construir lista con último mensaje + no leídos
      List<Map<String, dynamic>> temp = [];

      for (final u in lista) {
        final otroId = u['id'];

        // Último mensaje, incluye leido + id_usuario
        final ultimo = await supabase
            .from('mensaje')
            .select('contenido, timestamp, leido, id_usuario')
            .or(
            'and(id_usuario.eq.$miId,receptor_id.eq.$otroId),'
                'and(id_usuario.eq.$otroId,receptor_id.eq.$miId)'
        )
            .order('timestamp', ascending: false)
            .limit(1)
            .maybeSingle();

        // Contar mensajes NO leídos
        final noLeidos = await supabase
            .from('mensaje')
            .select('id_mensaje')
            .eq('id_usuario', otroId)
            .eq('receptor_id', miId)
            .eq('leido', false);

        // Comprobar si mostrar el punto azul
        final ultimoEsDelOtro = ultimo != null && ultimo['id_usuario'] == otroId;
        final ultimoNoLeido = ultimo != null && ultimo['leido'] == false;
        final hayNoLeidos = ultimoEsDelOtro && ultimoNoLeido;

        temp.add({
          'id': otroId,
          'name': u['nombre'],
          'message': ultimo?['contenido'] ?? 'Pulsa para chatear',
          'time': ultimo?['timestamp'] != null
              ? ultimo!['timestamp'].toString().substring(11, 16)
              : '',
          'timestampReal': ultimo?['timestamp'] != null
              ? DateTime.parse(ultimo!['timestamp'])
              : DateTime.fromMillisecondsSinceEpoch(0),
          'noLeidos': noLeidos.length,
          'hayNoLeidos': hayNoLeidos,
        });
      }

      // Ordenar por timestamp real
      temp.sort((a, b) => b['timestampReal'].compareTo(a['timestampReal']));

      setState(() {
        _patients = temp;
        _loading = false;
      });
    } catch (e) {
      print("ERROR EN _load(): $e");
      setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------
  // UI
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.blue.shade50,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Text(
                "Chat",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                  children: _patients.map((p) {
                    return _chatTile(
                      context: context,
                      id: p['id'],
                      nombre: p['name'],
                      mensaje: p['message'],
                      hora: p['time'],
                      noLeidos: p['noLeidos'],
                      hayNoLeidos: p['hayNoLeidos'],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // TARJETA DE CHAT
  // ---------------------------------------------------
  Widget _chatTile({
    required BuildContext context,
    required String id,
    required String nombre,
    required String mensaje,
    required String hora,
    required int noLeidos,
    required bool hayNoLeidos,
  }) {
    return Card(
      elevation: hayNoLeidos ? 5 : 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade700,
          child: Text(
            nombre[0],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // NOMBRE
        title: Text(
          nombre,
          style: TextStyle(
            fontWeight: hayNoLeidos ? FontWeight.bold : FontWeight.w600,
          ),
        ),

        // ÚLTIMO MENSAJE
        subtitle: Text(
          mensaje,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: hayNoLeidos ? FontWeight.bold : FontWeight.normal,
          ),
        ),

        // HORA + PUNTO AZUL
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hora,
              style: TextStyle(
                color: hayNoLeidos ? Colors.blue : Colors.grey.shade600,
                fontSize: 13,
                fontWeight: hayNoLeidos ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hayNoLeidos)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),

        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                nombre: nombre,
                otroId: id,
              ),
            ),
          );

          _load();
        },
      ),
    );
  }
}