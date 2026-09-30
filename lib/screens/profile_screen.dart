import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/preferencias_model.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingImage = false;
  PreferenciasModel _preferencias = const PreferenciasModel();
  final int _selectedIndex = 3;

  String _userName = '';
  String _userEmail = '';

  static const Color _azulGradienteInicio = Color(0xFF1B74E4);
  static const Color _azulGradienteFin = Color(0xFF58B2FF);

  @override
  void initState() {
    super.initState();
    _sembrarDesdeAuth();
    _cargarDatosUsuario();
  }

  void _sembrarDesdeAuth() {
    final user = FirebaseAuth.instance.currentUser;
    _userName = user?.displayName?.trim() ?? '';
    _userEmail = user?.email ?? '';
  }

  Future<void> _cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      final datos = doc.data() ?? {};

      var nombre = _userName;
      if (nombre.isEmpty) {
        final completo =
            '${datos['nombre']?.toString() ?? ''} '
            '${datos['apellido']?.toString() ?? ''}'.trim();
        if (completo.isNotEmpty) nombre = completo;
      }
      final email = _userEmail.isNotEmpty
          ? _userEmail
          : datos['email']?.toString() ?? '';

      if (!mounted) return;
      setState(() {
        _userName = nombre;
        _userEmail = email;
        _preferencias = PreferenciasModel.fromMap(datos);
      });
    } catch (e) {
      debugPrint('Error cargando datos del usuario: $e');
    }
  }

  /// Bucket de Storage. Tiene que coincidir con "storage_bucket" de
  /// android/app/google-services.json.
  static const String _bucket = 'proyecto-app-a77c8.firebasestorage.app';

  /// Pide la URL de descarga reintentando.
  ///
  /// Recién terminado el upload, el endpoint de descarga puede tardar un
  /// instante en resolver y responder 404. Es una carrera de propagacion, no
  /// un dato roto, asi que se reintenta con espera creciente. Ojo: si la causa
  /// real es un permiso denegado, el retry no la arregla, solo suma ~1,2 s antes
  /// de fallar. Por eso el log marca cada paso por separado.
  Future<String> _downloadUrlConReintentos(Reference ref) async {
    const intentos = 3;
    var intento = 0;
    while (true) {
      try {
        return await ref.getDownloadURL();
      } catch (_) {
        intento++;
        if (intento >= intentos) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 400 * intento));
      }
    }
  }

  Future<void> _pickImage() async {
    // Solo se libera la previsualizacion local si la foto quedo de verdad
    // publicada. Si algo falla, el avatar sigue mostrando lo que elegiste.
    var publicada = false;

    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final archivo = File(pickedFile.path);
      setState(() {
        _imageFile = archivo;
        _isLoadingImage = true;
      });

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(
            "No hay un usuario autenticado. Inicia sesión primero.");
      }

      // instanceFor y no instance: deja el bucket explicito y con el nombre
      // que declara android/app/google-services.json, sin depender de cual
      // inicializacion haya quedado activa primero.
      final ref = FirebaseStorage.instanceFor(bucket: _bucket)
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      debugPrint('[PERFIL] bucket=${ref.bucket} path=${ref.fullPath}');

      final TaskSnapshot snapshot = await ref.putFile(archivo);
      debugPrint('[PERFIL] putFile OK  bytes=${snapshot.totalBytes}');

      final String downloadUrl = await _downloadUrlConReintentos(ref);
      debugPrint('[PERFIL] getDownloadURL OK  $downloadUrl');

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({'fotoURL': downloadUrl}, SetOptions(merge: true));
      debugPrint('[PERFIL] Firestore OK  usuarios/${user.uid}.fotoURL');

      await user.updatePhotoURL(downloadUrl);
      publicada = true;
      debugPrint('[PERFIL] Auth OK  photoURL actualizado');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto actualizada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, st) {
      debugPrint('[PERFIL] FALLO tipo=${e.runtimeType}  $e');
      debugPrint('[PERFIL] stack: $st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo subir la foto. Intentá de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
          if (publicada) _imageFile = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double avatarRadius = 55.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      bottomNavigationBar: _buildBottomNav(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. ENCABEZADO (Estilo Favoritos: centrado y sin solapamientos)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: 28,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_azulGradienteInicio, _azulGradienteFin],
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Mi perfil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Gestioná tu cuenta y preferencias',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // 2. AVATAR Y CÁMARA (en el flujo normal, debajo del encabezado)
            const SizedBox(height: 25),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildAvatar(avatarRadius),
                  // Botón de cámara
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. DATOS DEL USUARIO
            const SizedBox(height: 15),
            Text(
              _userName.isEmpty ? 'Usuario' : _userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              _userEmail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),

            // 4. MENÚ
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMenu(),
            ),

            // 5. BOTÓN CERRAR SESIÓN
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Cerrar sesión",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _cerrarSesion,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Avatar con el anillo blanco y la imagen del usuario adentro.
  ///
  /// La foto de red se arma con `Image.network` y no con `NetworkImage` como
  /// `backgroundImage` del `CircleAvatar`. La diferencia es el `errorBuilder`:
  /// un `ImageProvider` no lo tiene, asi que con `NetworkImage` una URL vencida
  /// deja el avatar vacio o rompe el build en silencio. Con `Image.network` una
  /// foto que no carga cae al ícono de persona, que es lo que se quiere ver.
  Widget _buildAvatar(double radius) {
    final archivo = _imageFile;
    final url = FirebaseAuth.instance.currentUser?.photoURL;
    final lado = (radius - 4) * 2;
    const fallback = Icon(Icons.person, size: 55, color: Colors.white);

    Widget imagen;
    if (archivo != null) {
      imagen = Image.file(archivo, width: lado, height: lado, fit: BoxFit.cover);
    } else if (url != null && url.isNotEmpty) {
      imagen = Image.network(
        url,
        width: lado,
        height: lado,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    } else {
      imagen = fallback;
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: radius - 4,
        backgroundColor: Colors.grey[300],
        child: _isLoadingImage
            ? const CircularProgressIndicator(color: Colors.white)
            : ClipOval(child: imagen),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  Future<void> _abrirEditarPerfil() async {
    final cambios = await Navigator.pushNamed(context, '/editar-perfil');
    if (cambios == true) {
      await FirebaseAuth.instance.currentUser?.reload();
      if (mounted) setState(_sembrarDesdeAuth);
      await _cargarDatosUsuario();
    }
  }

  void _abrirNotificaciones() {
    Navigator.pushNamed(context, '/notificaciones');
  }

  void _abrirAyudaSoporte() {
    Navigator.pushNamed(context, '/soporte');
  }

  void _mostrarTerminos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y condiciones'),
        content: const Text(
          'Al usar CursAR aceptás que tus datos se utilicen únicamente para '
          'personalizar tu experiencia de búsqueda educativa. '
          'No compartimos tu información con terceros.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.borderSubtle, width: 1),
          ),
          child: _buildMenuItem(
            icono: Icons.edit_outlined,
            titulo: 'Editar perfil',
            onTap: _abrirEditarPerfil,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.borderSubtle, width: 1),
          ),
          child: _buildMenuItem(
            icono: Icons.notifications_outlined,
            titulo: 'Notificaciones',
            onTap: _abrirNotificaciones,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.borderSubtle, width: 1),
          ),
          child: _buildMenuItem(
            icono: Icons.radar,
            titulo: 'Radio de búsqueda',
            valor: '${_preferencias.radioBusqueda} km',
            onTap: _abrirEditarPerfil,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.borderSubtle, width: 1),
          ),
          child: _buildMenuItem(
            icono: Icons.help_outline,
            titulo: 'Ayuda y soporte',
            onTap: _abrirAyudaSoporte,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.borderSubtle, width: 1),
          ),
          child: _buildMenuItem(
            icono: Icons.description_outlined,
            titulo: 'Términos y condiciones',
            onTap: _mostrarTerminos,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icono,
    required String titulo,
    String? valor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icono, size: 22, color: context.colors.accentPrimary),
      title: Text(
        titulo,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: context.colors.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (valor != null) ...[
            Text(
              valor,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(
            Icons.chevron_right,
            size: 20,
            color: context.colors.iconNormal,
          ),
        ],
      ),
    );
  }

  void _navegar(int index) {
    if (index == _selectedIndex) return;
    if (index == 1) {
      Navigator.pushNamed(context, '/test');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/favoritos');
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildBottomNav() {
    const items = [
      _NavItemData(Icons.home_outlined, 'Inicio'),
      _NavItemData(Icons.explore_outlined, 'Test'),
      _NavItemData(Icons.favorite_outline, 'Favoritos'),
      _NavItemData(Icons.person, 'Perfil'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => _navegar(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[i].icon,
                          color: i == _selectedIndex
                              ? context.colors.iconActive
                              : context.colors.iconNormal,
                          size: 26,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: i == _selectedIndex
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: i == _selectedIndex
                                ? context.colors.iconActive
                                : context.colors.iconNormal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData(this.icon, this.label);

  final IconData icon;
  final String label;
}