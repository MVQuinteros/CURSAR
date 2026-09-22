import 'dart:io';
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

  static const Color _azulGradienteInicio = Color(0xFF1B74E4);
  static const Color _azulGradienteFin = Color(0xFF58B2FF);

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        _imageFile = File(pickedFile.path);
        _isLoadingImage = true;
      });

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(
            "No hay un usuario autenticado. Inicia sesión primero.");
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      // Ejecutar la subida y ESPERAR a que termine por completo
      final UploadTask uploadTask = storageRef.putFile(_imageFile!);
      final TaskSnapshot snapshot = await uploadTask;

      // Obtener la URL solo después de confirmar que se subió
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Actualizar el perfil del usuario en FirebaseAuth
      await user.updatePhotoURL(downloadUrl);

      // (Opcional) Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto actualizada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error subiendo imagen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
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
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: avatarRadius - 4,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          : (FirebaseAuth.instance.currentUser?.photoURL != null
                              ? NetworkImage(
                                  FirebaseAuth.instance.currentUser!.photoURL!)
                              : null),
                      child: _isLoadingImage
                          ? const CircularProgressIndicator(color: Colors.white)
                          : (_imageFile == null &&
                                  FirebaseAuth
                                      .instance.currentUser?.photoURL == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Colors.white,
                                )
                              : null,
                    ),
                  ),
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
            const Text(
              "Lola Lopez",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "lola12@gmail.com",
              style: TextStyle(color: Colors.grey, fontSize: 14),
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

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  Future<void> _abrirEditarPerfil() async {
    await Navigator.pushNamed(context, '/editar-perfil');
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