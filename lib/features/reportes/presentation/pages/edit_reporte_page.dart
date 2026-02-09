import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../domain/entities/reporte.dart';
import '../bloc/reporte_bloc.dart';
import '../bloc/reporte_event.dart';
import '../bloc/reporte_state.dart';

/// Página de Editar Reporte
/// 
/// Permite modificar título, descripción, categoría e imagen
class EditReportePage extends StatefulWidget {
  final Reporte reporte;

  const EditReportePage({
    super.key,
    required this.reporte,
  });

  @override
  State<EditReportePage> createState() => _EditReportePageState();
}

class _EditReportePageState extends State<EditReportePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late CategoriaReporte _selectedCategoria;
  
  File? _newImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.reporte.titulo);
    _descripcionController = TextEditingController(text: widget.reporte.descripcion);
    _selectedCategoria = widget.reporte.categoria;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  /// Tomar nueva foto
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _newImageFile = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  /// Seleccionar foto de galería
  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _newImageFile = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar foto: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  /// Guardar cambios
  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Verificar si hubo cambios
    final bool tituloChanged = _tituloController.text.trim() != widget.reporte.titulo;
    final bool descripcionChanged = _descripcionController.text.trim() != widget.reporte.descripcion;
    final bool categoriaChanged = _selectedCategoria != widget.reporte.categoria;
    final bool hasNewImage = _newImageFile != null;

    if (!tituloChanged && !descripcionChanged && !categoriaChanged && !hasNewImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay cambios para guardar'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    // Actualizar reporte
    context.read<ReporteBloc>().add(
          UpdateReporteEvent(
            id: widget.reporte.id,
            titulo: tituloChanged ? _tituloController.text.trim() : null,
            descripcion: descripcionChanged ? _descripcionController.text.trim() : null,
            categoria: categoriaChanged ? _selectedCategoria.toString() : null,
            imagenPath: _newImageFile?.path,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReporteBloc, ReporteState>(
      listener: (context, state) {
        if (state is ReporteUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Reporte actualizado'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is ReporteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Reporte'),
          backgroundColor: AppTheme.primary,
        ),
        body: BlocBuilder<ReporteBloc, ReporteState>(
          builder: (context, state) {
            final isLoading = state is ReporteLoading;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Imagen actual o nueva
                        _buildImageSection(),

                        const SizedBox(height: 24),

                        // Título
                        CustomTextField(
                          controller: _tituloController,
                          label: 'Título del reporte',
                          hintText: 'Ej: Bache en Av. Principal',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El título es requerido';
                            }
                            if (value.trim().length < 5) {
                              return 'El título debe tener al menos 5 caracteres';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Descripción
                        CustomTextField(
                          controller: _descripcionController,
                          label: 'Descripción',
                          hintText: 'Describe el problema en detalle',
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La descripción es requerida';
                            }
                            if (value.trim().length < 10) {
                              return 'La descripción debe tener al menos 10 caracteres';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Categoría
                        DropdownButtonFormField<CategoriaReporte>(
                          value: _selectedCategoria,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: CategoriaReporte.values.map((categoria) {
                            return DropdownMenuItem(
                              value: categoria,
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoriaIcon(categoria),
                                    color: AppTheme.getColorForCategoria(
                                      categoria.toString(),
                                    ),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(categoria.displayName),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => _selectedCategoria = value);
                                  }
                                },
                        ),

                        const SizedBox(height: 32),

                        // Nota informativa
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.info.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.info,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No puedes modificar la ubicación ni el estado del reporte',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón guardar
                        CustomButton(
                          onPressed: isLoading ? null : _saveChanges,
                          text: 'Guardar Cambios',
                          icon: Icons.save,
                          backgroundColor: AppTheme.success,
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Sección de imagen
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preview de imagen
        if (_newImageFile != null)
          _buildNewImagePreview()
        else if (widget.reporte.hasImage)
          _buildCurrentImage()
        else
          _buildNoImage(),

        const SizedBox(height: 12),

        // Botones de cambiar imagen
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Cámara'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Galería'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Preview de nueva imagen
  Widget _buildNewImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _newImageFile!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.success,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fiber_new, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Nueva',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Imagen actual
  Widget _buildCurrentImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: widget.reporte.imagenUrl!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  /// Sin imagen
  Widget _buildNoImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Sin imagen',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoriaIcon(CategoriaReporte categoria) {
    switch (categoria) {
      case CategoriaReporte.baches:
        return Icons.construction;
      case CategoriaReporte.luminarias:
        return Icons.lightbulb;
      case CategoriaReporte.basura:
        return Icons.delete;
      case CategoriaReporte.otro:
        return Icons.more_horiz;
    }
  }
}