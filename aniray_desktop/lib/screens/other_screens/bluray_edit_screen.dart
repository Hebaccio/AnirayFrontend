import 'package:aniray_desktop/models/basic_entities/basic_entities.dart';
import 'package:aniray_desktop/models/bluray/bluray_models.dart';
import 'package:aniray_desktop/providers/entity_providers/audio_format_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/bluray_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/video_format_provider.dart';
import 'package:aniray_desktop/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BluRayEditScreen extends StatefulWidget {
  const BluRayEditScreen({
    super.key,
    this.bluRayId,
    required this.movieId,
    this.onBack,
  });

  final int? bluRayId;
  final int movieId;
  final VoidCallback? onBack;

  @override
  State<BluRayEditScreen> createState() => _BluRayEditScreenState();
}

class _BluRayEditScreenState extends State<BluRayEditScreen> {
  final BluRayProvider _bluRayProvider = BluRayProvider();
  final VideoFormatProvider _videoFormatProvider = VideoFormatProvider();
  final AudioFormatProvider _audioFormatProvider = AudioFormatProvider();

  final _formKey = GlobalKey<FormState>();

  final _imageController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _discCountController = TextEditingController();
  final _runtimeController = TextEditingController();
  final _inStockController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? _releaseDate;

  // ---------------------------------------------------------------------------
  // FORMATS
  // ---------------------------------------------------------------------------

  List<BaseClassME> _videoFormats = [];
  List<BaseClassME> _audioFormats = [];

  BaseClassME? _selectedVideoFormat;
  BaseClassME? _selectedAudioFormat;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isDeleted = false;

  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // LOCAL BLURAY STATE
  // ---------------------------------------------------------------------------

  late bool _isEditMode;
  int? _currentBluRayId;

  @override
  void initState() {
    super.initState();

    _isEditMode = widget.bluRayId != null;
    _currentBluRayId = widget.bluRayId;

    _loadData();
  }

  @override
  void dispose() {
    _imageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();

    _discCountController.dispose();
    _runtimeController.dispose();
    _inStockController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOAD
  // ---------------------------------------------------------------------------

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final formatsLoaded = await _loadFormats();

      if (!formatsLoaded) {
        return;
      }

      if (_isEditMode) {
        await _loadBluRay();
      } else {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'An unexpected error occurred while loading the BluRay.';
      });
    }
  }

  Future<bool> _loadFormats() async {
    final videoResult = await _videoFormatProvider.getPagedEntityForEmployees(
      const BaseClassSOE(page: 0, pageSize: 100, isDeleted: false),
    );

    if (!mounted) return false;

    if (videoResult.data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = videoResult.message ?? 'Unable to load video formats.';
      });

      return false;
    }

    final audioResult = await _audioFormatProvider.getPagedEntityForEmployees(
      const BaseClassSOE(page: 0, pageSize: 100, isDeleted: false),
    );

    if (!mounted) return false;

    if (audioResult.data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = audioResult.message ?? 'Unable to load audio formats.';
      });

      return false;
    }

    setState(() {
      _videoFormats = videoResult.data!.resultList;
      _audioFormats = audioResult.data!.resultList;
    });

    return true;
  }

  Future<void> _loadBluRay() async {
    final bluRayId = _currentBluRayId;

    if (bluRayId == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      return;
    }

    final result = await _bluRayProvider.entityGetByIdForEmployees(bluRayId);

    if (!mounted) return;

    if (result.data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message ?? 'Unable to load the BluRay.';
      });

      return;
    }

    final bluRay = result.data!;

    _imageController.text = bluRay.image;
    _titleController.text = bluRay.title;
    _descriptionController.text = bluRay.description;

    _discCountController.text = bluRay.discCount.toString();
    _runtimeController.text = bluRay.runtime.toString();
    _inStockController.text = bluRay.inStock.toString();
    _priceController.text = bluRay.price.toString();

    _releaseDate = bluRay.releaseDate;
    _isDeleted = bluRay.isDeleted;

    // -------------------------------------------------------------------------
    // MATCH EXISTING FORMAT IDs WITH FETCHED EMPLOYEE FORMAT OBJECTS
    // -------------------------------------------------------------------------

    _selectedVideoFormat = _findFormatById(
      _videoFormats,
      bluRay.videoFormat.id,
    );

    _selectedAudioFormat = _findFormatById(
      _audioFormats,
      bluRay.audioFormat.id,
    );

    setState(() {
      _isLoading = false;
    });
  }

  BaseClassME? _findFormatById(List<BaseClassME> formats, int id) {
    for (final format in formats) {
      if (format.id == id) {
        return format;
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // SAVE
  // ---------------------------------------------------------------------------

  Future<void> _saveBluRay() async {
    if (_isSaving || _isDeleting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_releaseDate == null) {
      _showError('Please select a release date.');
      return;
    }

    if (_selectedVideoFormat == null) {
      _showError('Please select a video format.');
      return;
    }

    if (_selectedAudioFormat == null) {
      _showError('Please select an audio format.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditMode) {
        await _updateBluRay();
      } else {
        await _insertBluRay();
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showError('An unexpected error occurred while saving the BluRay.');
    }
  }

  // ---------------------------------------------------------------------------
  // INSERT
  // ---------------------------------------------------------------------------

  Future<void> _insertBluRay() async {
    final request = BluRayIRE(
      image: _imageController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      releaseDate: _releaseDate!,

      // Movie ID comes directly from MovieDetailsScreen.
      movieId: widget.movieId,

      videoFormatId: _selectedVideoFormat!.id,

      audioFormatId: _selectedAudioFormat!.id,

      discCount: int.parse(_discCountController.text.trim()),

      runtime: int.parse(_runtimeController.text.trim()),

      inStock: int.parse(_inStockController.text.trim()),

      price: double.parse(_priceController.text.trim()),
    );

    final result = await _bluRayProvider.insertEntityForEmployees(request);

    if (!mounted) return;

    if (result.data != null) {
      final createdBluRay = result.data!;

      setState(() {
        _isSaving = false;
        _isEditMode = true;
        _currentBluRayId = createdBluRay.id;
        _isDeleted = false;
      });

      _showSuccess('BluRay added successfully.');

      return;
    }

    setState(() {
      _isSaving = false;
    });

    _showError(result.message ?? 'Unable to add the BluRay.');
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------

  Future<void> _updateBluRay() async {
    final bluRayId = _currentBluRayId;

    if (bluRayId == null) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }

      _showError('BluRay ID is missing.');
      return;
    }

    final request = BluRayURE(
      image: _nullableText(_imageController.text),

      title: _nullableText(_titleController.text),

      description: _nullableText(_descriptionController.text),

      releaseDate: _releaseDate,

      videoFormatId: _selectedVideoFormat!.id,

      audioFormatId: _selectedAudioFormat!.id,

      discCount: int.tryParse(_discCountController.text.trim()),

      runtime: int.tryParse(_runtimeController.text.trim()),

      inStock: int.tryParse(_inStockController.text.trim()),

      price: double.tryParse(_priceController.text.trim()),

      isDeleted: _isDeleted,
    );

    final result = await _bluRayProvider.updateEntityForEmployees(
      bluRayId,
      request,
    );

    if (!mounted) return;

    if (result.data != null) {
      setState(() {
        _isSaving = false;
      });

      _showSuccess('BluRay updated successfully.');

      return;
    }

    setState(() {
      _isSaving = false;
    });

    _showError(result.message ?? 'Unable to update the BluRay.');
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  Future<void> _deleteBluRay() async {
    final bluRayId = _currentBluRayId;

    if (bluRayId == null || _isDeleting || _isSaving) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundPrimary,
          title: const Text(
            'Delete BluRay',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to delete this BluRay?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.textError),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final result = await _bluRayProvider.softDelete(bluRayId);

      if (!mounted) return;

      if (result.statusCode == 200) {
        setState(() {
          _isDeleting = false;
          _isDeleted = true;
        });

        _showSuccess('BluRay deleted successfully.');

        return;
      }

      setState(() {
        _isDeleting = false;
      });

      _showError(result.message ?? 'Unable to delete the BluRay.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showError('An unexpected error occurred while deleting the BluRay.');
    }
  }

  // ---------------------------------------------------------------------------
  // RESTORE
  // ---------------------------------------------------------------------------

  Future<void> _restoreBluRay() async {
    final bluRayId = _currentBluRayId;

    if (bluRayId == null || _isDeleting || _isSaving) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final request = BluRayURE(isDeleted: false);

      final result = await _bluRayProvider.updateEntityForEmployees(
        bluRayId,
        request,
      );

      if (!mounted) return;

      if (result.data != null) {
        setState(() {
          _isDeleting = false;
          _isDeleted = false;
        });

        _showSuccess('BluRay restored successfully.');

        return;
      }

      setState(() {
        _isDeleting = false;
      });

      _showError(result.message ?? 'Unable to restore the BluRay.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showError('An unexpected error occurred while restoring the BluRay.');
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  String? _nullableText(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  // ---------------------------------------------------------------------------
  // DATE
  // ---------------------------------------------------------------------------

  Future<void> _selectReleaseDate() async {
    final initialDate = _releaseDate ?? DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1800),
      lastDate: DateTime(2100),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _releaseDate = selected;
    });
  }

  // ---------------------------------------------------------------------------
  // FORMAT PICKERS
  // ---------------------------------------------------------------------------

  Future<void> _showVideoFormatSelector() async {
    final selected = await showDialog<BaseClassME>(
      context: context,
      builder: (context) {
        return _FormatSelectionDialog(
          title: 'Select Video Format',
          formats: _videoFormats,
          selectedFormatId: _selectedVideoFormat?.id,
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _selectedVideoFormat = selected;
    });
  }

  Future<void> _showAudioFormatSelector() async {
    final selected = await showDialog<BaseClassME>(
      context: context,
      builder: (context) {
        return _FormatSelectionDialog(
          title: 'Select Audio Format',
          formats: _audioFormats,
          selectedFormatId: _selectedAudioFormat?.id,
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _selectedAudioFormat = selected;
    });
  }

  // ---------------------------------------------------------------------------
  // VALIDATORS
  // ---------------------------------------------------------------------------

  String? _requiredIntegerValidator(
    String? value, {
    required String fieldName,
    bool allowZero = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    final parsed = int.tryParse(value.trim());

    if (parsed == null) {
      return '$fieldName must be a whole number.';
    }

    if (!allowZero && parsed <= 0) {
      return '$fieldName must be greater than zero.';
    }

    if (allowZero && parsed < 0) {
      return '$fieldName cannot be negative.';
    }

    return null;
  }

  String? _priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required.';
    }

    final parsed = double.tryParse(value.trim());

    if (parsed == null) {
      return 'Price must be a valid number.';
    }

    if (parsed < 0) {
      return 'Price cannot be negative.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // MESSAGES
  // ---------------------------------------------------------------------------

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textError,
        ),
      );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return _buildContent();
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------

  Widget _buildErrorState() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textError,
              ),

              const SizedBox(height: 16),

              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary),
              ),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 20),

                    // ----------------------------------------------------------------
                    // TITLE
                    // ----------------------------------------------------------------
                    _buildLabel('Title'),

                    const SizedBox(height: 6),

                    _buildTextField(
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // ----------------------------------------------------------------
                    // IMAGE
                    // ----------------------------------------------------------------
                    _buildLabel('Image'),

                    const SizedBox(height: 6),

                    _buildImageSection(),

                    const SizedBox(height: 12),

                    // ----------------------------------------------------------------
                    // DESCRIPTION
                    // ----------------------------------------------------------------
                    _buildLabel('Description'),

                    const SizedBox(height: 6),

                    _buildDescriptionField(),

                    const SizedBox(height: 12),

                    // ----------------------------------------------------------------
                    // METADATA
                    // ----------------------------------------------------------------
                    if (isWide)
                      _buildWideMetadata()
                    else
                      _buildNarrowMetadata(),

                    const SizedBox(height: 12),

                    // ----------------------------------------------------------------
                    // INVENTORY
                    // ----------------------------------------------------------------
                    if (isWide)
                      _buildWideInventory()
                    else
                      _buildNarrowInventory(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.onBack != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Back',
              onPressed: (_isSaving || _isDeleting) ? null : widget.onBack,
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),

        Expanded(
          child: Row(
            children: [
              Text(
                _isEditMode ? 'Edit BluRay' : 'Add BluRay',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),

              if (_isEditMode && _isDeleted) ...[
                const SizedBox(width: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textError.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Deleted',
                    style: TextStyle(
                      color: AppColors.textError,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ---------------------------------------------------------------------
        // DELETE / RESTORE
        // ---------------------------------------------------------------------
        if (_isEditMode) ...[
          SizedBox(
            height: 42,
            child: Material(
              color: _isDeleted
                  ? AppColors.backgroundSecondary
                  : AppColors.textError,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: (_isSaving || _isDeleting)
                    ? null
                    : (_isDeleted ? _restoreBluRay : _deleteBluRay),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isDeleting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _isDeleted
                                    ? AppColors.textPrimary
                                    : Colors.white,
                              ),
                            )
                          : Icon(
                              _isDeleted ? Icons.restore : Icons.delete_outline,
                              color: _isDeleted
                                  ? AppColors.textPrimary
                                  : Colors.white,
                              size: 21,
                            ),

                      const SizedBox(width: 9),

                      Text(
                        _isDeleting
                            ? (_isDeleted ? 'Restoring...' : 'Deleting...')
                            : (_isDeleted ? 'Restore BluRay' : 'Delete BluRay'),
                        style: TextStyle(
                          color: _isDeleted
                              ? AppColors.textPrimary
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),
        ],

        // ---------------------------------------------------------------------
        // SAVE
        // ---------------------------------------------------------------------
        SizedBox(
          height: 42,
          child: Material(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: (_isSaving || _isDeleting) ? null : _saveBluRay,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isSaving)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      )
                    else
                      Icon(
                        _isEditMode ? Icons.save_outlined : Icons.add,
                        color: AppColors.textPrimary,
                        size: 21,
                      ),

                    const SizedBox(width: 10),

                    Text(
                      _isSaving
                          ? 'Saving...'
                          : _isEditMode
                          ? 'Save Changes'
                          : 'Add BluRay',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGE
  // ---------------------------------------------------------------------------

  Widget _buildImageSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BluRayPosterPreview(imageUrl: _imageController.text),

        const SizedBox(width: 10),

        Expanded(
          child: _buildTextField(
            controller: _imageController,
            onChanged: (_) {
              setState(() {});
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Image URL is required.';
              }

              return null;
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DESCRIPTION
  // ---------------------------------------------------------------------------

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      minLines: 5,
      maxLines: 8,
      textAlignVertical: TextAlignVertical.top,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      cursorColor: AppColors.textPrimary,
      decoration: _inputDecoration(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Description is required.';
        }

        return null;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // METADATA
  // ---------------------------------------------------------------------------

  Widget _buildWideMetadata() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Video Format'),

              const SizedBox(height: 6),

              _buildFormatPicker(
                selectedFormat: _selectedVideoFormat,
                hintText: 'Select video format...',
                onTap: _showVideoFormatSelector,
              ),

              const SizedBox(height: 12),

              _buildLabel('Audio Format'),

              const SizedBox(height: 6),

              _buildFormatPicker(
                selectedFormat: _selectedAudioFormat,
                hintText: 'Select audio format...',
                onTap: _showAudioFormatSelector,
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Release Date'),

              const SizedBox(height: 6),

              _buildDateButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Video Format'),

        const SizedBox(height: 6),

        _buildFormatPicker(
          selectedFormat: _selectedVideoFormat,
          hintText: 'Select video format...',
          onTap: _showVideoFormatSelector,
        ),

        const SizedBox(height: 12),

        _buildLabel('Audio Format'),

        const SizedBox(height: 6),

        _buildFormatPicker(
          selectedFormat: _selectedAudioFormat,
          hintText: 'Select audio format...',
          onTap: _showAudioFormatSelector,
        ),

        const SizedBox(height: 12),

        _buildLabel('Release Date'),

        const SizedBox(height: 6),

        _buildDateButton(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FORMAT PICKER
  // ---------------------------------------------------------------------------

  Widget _buildFormatPicker({
    required BaseClassME? selectedFormat,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: (_isSaving || _isDeleting) ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedFormat?.name ?? hintText,
                style: TextStyle(
                  color: selectedFormat == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INVENTORY
  // ---------------------------------------------------------------------------

  Widget _buildWideInventory() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Disc Count'),

              const SizedBox(height: 6),

              _buildIntegerField(
                controller: _discCountController,
                fieldName: 'Disc Count',
                allowZero: false,
              ),

              const SizedBox(height: 12),

              _buildLabel('Runtime (minutes)'),

              const SizedBox(height: 6),

              _buildIntegerField(
                controller: _runtimeController,
                fieldName: 'Runtime',
                allowZero: false,
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('In Stock'),

              const SizedBox(height: 6),

              _buildIntegerField(
                controller: _inStockController,
                fieldName: 'In Stock',
                allowZero: true,
              ),

              const SizedBox(height: 12),

              _buildLabel('Price'),

              const SizedBox(height: 6),

              _buildPriceField(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowInventory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Disc Count'),

        const SizedBox(height: 6),

        _buildIntegerField(
          controller: _discCountController,
          fieldName: 'Disc Count',
          allowZero: false,
        ),

        const SizedBox(height: 12),

        _buildLabel('Runtime (minutes)'),

        const SizedBox(height: 6),

        _buildIntegerField(
          controller: _runtimeController,
          fieldName: 'Runtime',
          allowZero: false,
        ),

        const SizedBox(height: 12),

        _buildLabel('In Stock'),

        const SizedBox(height: 6),

        _buildIntegerField(
          controller: _inStockController,
          fieldName: 'In Stock',
          allowZero: true,
        ),

        const SizedBox(height: 12),

        _buildLabel('Price'),

        const SizedBox(height: 6),

        _buildPriceField(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DATE
  // ---------------------------------------------------------------------------

  Widget _buildDateButton() {
    return InkWell(
      onTap: (_isSaving || _isDeleting) ? null : _selectReleaseDate,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 17,
              color: AppColors.textPrimary,
            ),

            const SizedBox(width: 8),

            Text(
              _releaseDate == null ? 'Select date' : _formatDate(_releaseDate!),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  // ---------------------------------------------------------------------------
  // SHARED INPUTS
  // ---------------------------------------------------------------------------

  Widget _buildIntegerField({
    required TextEditingController controller,
    required String fieldName,
    required bool allowZero,
  }) {
    return _buildTextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
      validator: (value) {
        return _requiredIntegerValidator(
          value,
          fieldName: fieldName,
          allowZero: allowZero,
        );
      },
    );
  }

  Widget _buildPriceField() {
    return _buildTextField(
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _priceValidator,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      cursorColor: AppColors.textPrimary,
      decoration: _inputDecoration(),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.backgroundTertiary,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.textSecondary),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.textError),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.textError),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),

      hintStyle: const TextStyle(color: AppColors.textSecondary),
    );
  }
}

// =============================================================================
// FORMAT SELECTION DIALOG
// =============================================================================

class _FormatSelectionDialog extends StatefulWidget {
  const _FormatSelectionDialog({
    required this.title,
    required this.formats,
    required this.selectedFormatId,
  });

  final String title;
  final List<BaseClassME> formats;
  final int? selectedFormatId;

  @override
  State<_FormatSelectionDialog> createState() => _FormatSelectionDialogState();
}

class _FormatSelectionDialogState extends State<_FormatSelectionDialog> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredFormats = widget.formats.where((format) {
      if (_searchText.trim().isEmpty) {
        return true;
      }

      return format.name.toLowerCase().contains(
        _searchText.trim().toLowerCase(),
      );
    }).toList();

    return AlertDialog(
      backgroundColor: AppColors.backgroundPrimary,

      title: Text(
        widget.title,
        style: const TextStyle(color: AppColors.textPrimary),
      ),

      content: SizedBox(
        width: 450,
        height: 500,
        child: Column(
          children: [
            TextField(
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              cursorColor: AppColors.textPrimary,
              decoration: InputDecoration(
                hintText: 'Search formats...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.backgroundTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),

            const SizedBox(height: 12),

            Expanded(
              child: filteredFormats.isEmpty
                  ? const Center(
                      child: Text(
                        'No formats found.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredFormats.length,
                      itemBuilder: (context, index) {
                        final format = filteredFormats[index];

                        final selected = format.id == widget.selectedFormatId;

                        return RadioListTile<int>(
                          value: format.id,
                          groupValue: widget.selectedFormatId,
                          title: Text(
                            format.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          activeColor: AppColors.textPrimary,
                          selected: selected,
                          onChanged: (_) {
                            Navigator.of(context).pop(format);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// =============================================================================
// POSTER PREVIEW
// =============================================================================

class _BluRayPosterPreview extends StatelessWidget {
  const _BluRayPosterPreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 145,
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.trim().isEmpty
          ? const Center(
              child: Icon(
                Icons.movie_outlined,
                size: 36,
                color: AppColors.textSecondary,
              ),
            )
          : Image.network(
              imageUrl.trim(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 36,
                    color: AppColors.textSecondary,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
    );
  }
}

// =============================================================================
// LABEL
// =============================================================================

Widget _buildLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
  );
}
