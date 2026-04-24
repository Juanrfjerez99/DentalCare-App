import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String nombre;
  final String otroId;

  const ChatDetailScreen({
    super.key,
    required this.nombre,
    required this.otroId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _mensajes = [];
  late String miId;

  @override
  void initState() {
    super.initState();
    miId = Supabase.instance.client.auth.currentUser!.id;

    _marcarComoLeidos();
    _cargarMensajes();
    _escucharMensajes();
  }

  // ---------------------------------------------------
  // MARCAR COMO LEÍDOS AL ENTRAR
  // ---------------------------------------------------
  void _marcarComoLeidos() async {
    final supabase = Supabase.instance.client;

    await supabase
        .from('mensaje')
        .update({'leido': true})
        .eq('id_usuario', widget.otroId)
        .eq('receptor_id', miId)
        .eq('leido', false);
  }

  // ---------------------------------------------------
  // CARGAR HISTORIAL
  // ---------------------------------------------------
  void _cargarMensajes() async {
    final mensajes = await _chatService.obtenerMensajes(
      miId: miId,
      otroId: widget.otroId,
    );

    setState(() {
      _mensajes = mensajes;
    });

    _scrollAbajo();
  }

  // ---------------------------------------------------
  // ESCUCHAR MENSAJES EN TIEMPO REAL
  // ---------------------------------------------------
  void _escucharMensajes() {
    final supabase = Supabase.instance.client;

    supabase
        .channel('chat_${miId}_${widget.otroId}')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'mensaje',
      callback: (payload) async {
        final msg = payload.newRecord;

        // Filtrar SOLO mensajes entre estos dos usuarios
        final esEntreAmbos =
            (msg['id_usuario'] == miId && msg['receptor_id'] == widget.otroId) ||
                (msg['id_usuario'] == widget.otroId && msg['receptor_id'] == miId);

        if (!esEntreAmbos) return;

        // Marcar como leído si el mensaje es de otro usuario
        if (msg['id_usuario'] == widget.otroId) {
          await supabase
              .from('mensaje')
              .update({'leido': true})
              .eq('id_mensaje', msg['id_mensaje']);
        }

        setState(() {
          // Evitar duplicados
          if (!_mensajes.any((m) => m['id_mensaje'] == msg['id_mensaje'])) {
            _mensajes.add(msg);
          }

          // Ordenar por fecha
          _mensajes.sort((a, b) =>
              DateTime.parse(a['timestamp'])
                  .compareTo(DateTime.parse(b['timestamp'])));
        });

        _scrollAbajo();
      },
    )
        .subscribe();
  }

  // ---------------------------------------------------
  // ENVIAR MENSAJE
  // ---------------------------------------------------
  void _enviar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    // Crear mensaje local para mostrarlo inmediatamente
    final nuevoMensaje = {
      'id_mensaje': DateTime.now().millisecondsSinceEpoch.toString(),
      'id_usuario': miId,
      'receptor_id': widget.otroId,
      'contenido': texto,
      'timestamp': DateTime.now().toIso8601String(),
    };

    setState(() {
      _mensajes.add(nuevoMensaje);
    });

    _scrollAbajo();

    // Enviar a Supabase
    _chatService.enviarMensaje(
      emisorId: miId,
      receptorId: widget.otroId,
      contenido: texto,
    );

    _controller.clear();
  }

  // ---------------------------------------------------
  // SCROLL AUTOMÁTICO
  // ---------------------------------------------------
  void _scrollAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ---------------------------------------------------
  // LIMPIAR CANALES
  // ---------------------------------------------------
  @override
  void dispose() {
    _chatService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------
  // UI
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.nombre,
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.blue.shade700),
      ),

      body: Container(
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
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _mensajes.length,
                itemBuilder: (context, index) {
                  final msg = _mensajes[index];
                  final esMio = msg['id_usuario'] == miId;

                  return _messageBubble(
                    texto: msg['contenido'],
                    enviadoPorMi: esMio,
                  );
                },
              ),
            ),

            // CAJA DE TEXTO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Escribe un mensaje...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _enviar,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.blue.shade700,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // BURBUJA DE MENSAJE
  // ---------------------------------------------------
  Widget _messageBubble({
    required String texto,
    required bool enviadoPorMi,
  }) {
    return Align(
      alignment: enviadoPorMi ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enviadoPorMi ? Colors.blue.shade700 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: enviadoPorMi ? const Radius.circular(14) : const Radius.circular(0),
            bottomRight: enviadoPorMi ? const Radius.circular(0) : const Radius.circular(14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: enviadoPorMi ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
