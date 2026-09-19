import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UsuariosAdminScreen extends StatefulWidget {
  final int adminId;

  const UsuariosAdminScreen({super.key, required this.adminId});

  @override
  State<UsuariosAdminScreen> createState() => _UsuariosAdminScreenState();
}

class _UsuariosAdminScreenState extends State<UsuariosAdminScreen> {
  List<dynamic> _usuarios = [];
  bool _cargando = true;
  String _filtroRol = 'todos';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final respuesta = await http.post(
        Uri.parse('http://localhost/sereo/backend/public/usuarios_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({if (_filtroRol != 'todos') 'rol_filtro': _filtroRol}),
      );
      final datos = jsonDecode(respuesta.body);
      setState(() => _usuarios = datos['usuarios'] ?? []);
    } catch (e) {
      // deja como estaba
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarEstado(int id, bool nuevoEstado) async {
    try {
      final respuesta = await http.post(
        Uri.parse('http://localhost/sereo/backend/public/usuarios_cambiar_estado.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'activo': nuevoEstado, 'admin_id': widget.adminId}),
      );
      final datos = jsonDecode(respuesta.body);
      if (respuesta.statusCode != 200) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(datos['error'])));
        return;
      }
      await _cargar();
    } catch (e) {
      // silencioso
    }
  }

  Future<void> _abrirFormularioCrear() async {
    await showDialog(
      context: context,
      builder: (_) => _DialogoUsuario(
        onGuardar: (nombre, correo, contrasena, rol) async {
          final respuesta = await http.post(
            Uri.parse('http://localhost/sereo/backend/public/usuarios_crear.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombre_completo': nombre,
              'correo': correo,
              'contrasena': contrasena,
              'rol': rol,
            }),
          );
          final datos = jsonDecode(respuesta.body);
          if (respuesta.statusCode != 200) {
            throw Exception(datos['error']);
          }
          await _cargar();
        },
      ),
    );
  }

  Future<void> _abrirFormularioEditar(dynamic usuario) async {
    await showDialog(
      context: context,
      builder: (_) => _DialogoUsuario(
        nombreInicial: usuario['nombre_completo'],
        correoInicial: usuario['correo'],
        rolInicial: usuario['rol'],
        esEdicion: true,
        onGuardar: (nombre, correo, _, __) async {
          final respuesta = await http.post(
            Uri.parse('http://localhost/sereo/backend/public/usuarios_actualizar.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id': usuario['id'], 'nombre_completo': nombre, 'correo': correo}),
          );
          final datos = jsonDecode(respuesta.body);
          if (respuesta.statusCode != 200) {
            throw Exception(datos['error']);
          }
          await _cargar();
        },
      ),
    );
  }

  Color _colorRol(String rol) {
    switch (rol) {
      case 'estudiante':
        return Colors.blueGrey;
      case 'bienestar':
        return const Color(0xFF0F6E56);
      case 'admin':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  Widget _chipFiltro(String valor, String etiqueta) {
    final activo = _filtroRol == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(etiqueta),
        selected: activo,
        onSelected: (_) {
          setState(() => _filtroRol = valor);
          _cargar();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chipFiltro('todos', 'Todos'),
                    _chipFiltro('estudiante', 'Estudiantes'),
                    _chipFiltro('bienestar', 'Bienestar'),
                    _chipFiltro('admin', 'Admin'),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nueva cuenta'),
              onPressed: _abrirFormularioCrear,
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_cargando) const Expanded(child: Center(child: CircularProgressIndicator())),

        if (!_cargando && _usuarios.isEmpty)
          const Expanded(child: Center(child: Text('No hay usuarios en este filtro.'))),

        if (!_cargando && _usuarios.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _usuarios.length,
              itemBuilder: (context, i) {
                final u = _usuarios[i];
                final activo = u['activo'] == 1 || u['activo'] == true;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _colorRol(u['rol']),
                      child: Text(u['rol'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                    title: Text(u['nombre_completo']),
                    subtitle: Text(
                      '${u['correo']}${u['programa_academico'] != null ? ' · ${u['programa_academico']}' : ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: activo,
                          onChanged: (valor) => _cambiarEstado(u['id'], valor),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _abrirFormularioEditar(u),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Formulario reutilizado para crear y editar
class _DialogoUsuario extends StatefulWidget {
  final String? nombreInicial;
  final String? correoInicial;
  final String? rolInicial;
  final bool esEdicion;
  final Future<void> Function(String nombre, String correo, String contrasena, String rol) onGuardar;

  const _DialogoUsuario({
    this.nombreInicial,
    this.correoInicial,
    this.rolInicial,
    this.esEdicion = false,
    required this.onGuardar,
  });

  @override
  State<_DialogoUsuario> createState() => _DialogoUsuarioState();
}

class _DialogoUsuarioState extends State<_DialogoUsuario> {
  late final _nombreController = TextEditingController(text: widget.nombreInicial ?? '');
  late final _correoController = TextEditingController(text: widget.correoInicial ?? '');
  final _contrasenaController = TextEditingController();
  String _rol = 'bienestar';
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.rolInicial != null) _rol = widget.rolInicial!;
  }

  Future<void> _guardar() async {
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await widget.onGuardar(
        _nombreController.text.trim(),
        _correoController.text.trim(),
        _contrasenaController.text,
        _rol,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.esEdicion ? 'Editar usuario' : 'Nueva cuenta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: 'Correo institucional'),
            ),
            if (!widget.esEdicion) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña (mín. 8 caracteres)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _rol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'bienestar', child: Text('Bienestar')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (valor) => setState(() => _rol = valor!),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
