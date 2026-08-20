import 'package:aniray_desktop/models/basic_entities/basic_entities.dart';
import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:aniray_desktop/providers/entity_providers/genre_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/movie_provider.dart';
import 'package:aniray_desktop/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MovieEditScreen extends StatefulWidget {
  const MovieEditScreen({super.key, this.movieId, this.onBack});

  /// null = Add Movie
  /// non-null = Edit Movie
  final int? movieId;

  final VoidCallback? onBack;

  @override
  State<MovieEditScreen> createState() => _MovieEditScreenState();
}

class _MovieEditScreenState extends State<MovieEditScreen> {
  final MovieProvider _movieProvider = MovieProvider();
  final GenreProvider _genreProvider = GenreProvider();

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _imageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _studioController = TextEditingController();
  final _directorController = TextEditingController();

  DateTime? _releaseDate;

  List<BaseClassMU> _genres = [];
  final Set<int> _selectedGenreIds = {};

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isDeleted = false;

  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // LOCAL MOVIE STATE
  // ---------------------------------------------------------------------------

  late bool _isEditMode;
  int? _currentMovieId;

  @override
  void initState() {
    super.initState();

    // If movieId was supplied, we are editing an existing movie.
    // If it wasn't supplied, we are adding a new movie.
    _isEditMode = widget.movieId != null;
    _currentMovieId = widget.movieId;

    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    _studioController.dispose();
    _directorController.dispose();

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
      final genresResult = await _loadGenres();

      if (genresResult == null) {
        return;
      }

      if (_isEditMode) {
        await _loadMovie();
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
        _errorMessage = 'An unexpected error occurred while loading the data.';
      });
    }
  }

  Future<bool?> _loadGenres() async {
    final result = await _genreProvider.getPagedEntityForUsers(
      const BaseClassSOU(page: 0, pageSize: 100),
    );

    if (!mounted) return false;

    if (result.data != null) {
      setState(() {
        _genres = result.data!.resultList;
      });

      return true;
    }

    setState(() {
      _isLoading = false;
      _errorMessage = result.message ?? 'Unable to load movie genres.';
    });

    return null;
  }

  Future<void> _loadMovie() async {
    final movieId = _currentMovieId;

    if (movieId == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      return;
    }

    final result = await _movieProvider.entityGetByIdForEmployees(movieId);

    if (!mounted) return;

    if (result.data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message ?? 'Unable to load the movie.';
      });

      return;
    }

    final movie = result.data!;

    _titleController.text = movie.title;
    _imageController.text = movie.image;
    _descriptionController.text = movie.description;
    _studioController.text = movie.studio;
    _directorController.text = movie.director ?? '';
    _releaseDate = movie.releaseDate;
    _isDeleted = movie.isDeleted;

    _selectedGenreIds.clear();

    for (final movieGenre in movie.movieGenres) {
      _selectedGenreIds.add(movieGenre.genre.id);
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ---------------------------------------------------------------------------
  // SAVE
  // ---------------------------------------------------------------------------

  Future<void> _saveMovie() async {
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

    setState(() {
      _isSaving = true;
    });

    try {
      final genreIds = _selectedGenreIds.toList();

      if (_isEditMode) {
        await _updateMovie(genreIds);
      } else {
        await _insertMovie(genreIds);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showError('An unexpected error occurred while saving the movie.');
    }
  }

  // ---------------------------------------------------------------------------
  // INSERT
  // ---------------------------------------------------------------------------

  Future<void> _insertMovie(List<int> genreIds) async {
    final request = MovieIRE(
      image: _imageController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      releaseDate: _releaseDate!,
      studio: _studioController.text.trim(),
      director: _nullableText(_directorController.text),
      genreIds: genreIds,
    );

    final result = await _movieProvider.insertEntityForEmployees(request);

    if (!mounted) return;

    if (result.data != null) {
      final createdMovie = result.data!;

      setState(() {
        _isSaving = false;

        // IMPORTANT:
        // The movie now exists in the database.
        // Turn this Add Movie screen into an Edit Movie screen.
        _isEditMode = true;
        _currentMovieId = createdMovie.id;

        _isDeleted = false;
      });

      _showSuccess('Movie added successfully.');

      return;
    }

    setState(() {
      _isSaving = false;
    });

    _showError(result.message ?? 'Unable to add the movie.');
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------

  Future<void> _updateMovie(List<int> genreIds) async {
    final movieId = _currentMovieId;

    if (movieId == null) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }

      _showError('Movie ID is missing.');
      return;
    }

    final request = MovieURE(
      image: _nullableText(_imageController.text),
      title: _nullableText(_titleController.text),
      description: _nullableText(_descriptionController.text),
      releaseDate: _releaseDate,
      studio: _nullableText(_studioController.text),
      director: _nullableText(_directorController.text),
      genreIds: genreIds,
      isDeleted: _isDeleted,
    );

    final result = await _movieProvider.updateEntityForEmployees(
      movieId,
      request,
    );

    if (!mounted) return;

    if (result.data != null) {
      setState(() {
        _isSaving = false;
      });

      _showSuccess('Movie updated successfully.');

      return;
    }

    setState(() {
      _isSaving = false;
    });

    _showError(result.message ?? 'Unable to update the movie.');
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  Future<void> _deleteMovie() async {
    final movieId = _currentMovieId;

    if (movieId == null || _isDeleting || _isSaving) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundPrimary,
          title: const Text(
            'Delete Movie',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to delete this movie?',
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
      final result = await _movieProvider.softDelete(movieId);

      if (!mounted) return;

      if (result.statusCode == 200) {
        setState(() {
          _isDeleting = false;
          _isDeleted = true;
        });

        _showSuccess('Movie deleted successfully.');

        return;
      }

      setState(() {
        _isDeleting = false;
      });

      _showError(result.message ?? 'Unable to delete the movie.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showError('An unexpected error occurred while deleting the movie.');
    }
  }

  // ---------------------------------------------------------------------------
  // RESTORE
  // ---------------------------------------------------------------------------

  Future<void> _restoreMovie() async {
    final movieId = _currentMovieId;

    if (movieId == null || _isDeleting || _isSaving) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final request = MovieURE(isDeleted: false);

      final result = await _movieProvider.updateEntityForEmployees(
        movieId,
        request,
      );

      if (!mounted) return;

      if (result.data != null) {
        setState(() {
          _isDeleting = false;
          _isDeleted = false;
        });

        _showSuccess('Movie restored successfully.');

        return;
      }

      setState(() {
        _isDeleting = false;
      });

      _showError(result.message ?? 'Unable to restore the movie.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showError('An unexpected error occurred while restoring the movie.');
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
  // GENRES
  // ---------------------------------------------------------------------------

  void _showGenreSelector() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return _GenreSelectionDialog(
          genres: _genres,
          selectedGenreIds: _selectedGenreIds,
          onChanged: (genreId, selected) {
            setState(() {
              if (selected) {
                _selectedGenreIds.add(genreId);
              } else {
                _selectedGenreIds.remove(genreId);
              }
            });
          },
        );
      },
    );
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

                    _buildLabel('Image'),
                    const SizedBox(height: 6),

                    _buildImageSection(),

                    const SizedBox(height: 12),

                    _buildLabel('Synopsis'),
                    const SizedBox(height: 6),

                    _buildDescriptionField(),

                    const SizedBox(height: 12),

                    if (isWide)
                      _buildWideMetadata()
                    else
                      _buildNarrowMetadata(),

                    const SizedBox(height: 12),

                    _buildGenres(),

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
                _isEditMode ? 'Edit Movie' : 'Add Movie',
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
                    : (_isDeleted ? _restoreMovie : _deleteMovie),
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
                            : (_isDeleted ? 'Restore Movie' : 'Delete Movie'),
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
        // SAVE / ADD
        // ---------------------------------------------------------------------
        SizedBox(
          height: 42,
          child: Material(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: (_isSaving || _isDeleting) ? null : _saveMovie,
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
                          : 'Add Movie',
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
        _MoviePosterPreview(imageUrl: _imageController.text),

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
              _buildLabel('Studio'),
              const SizedBox(height: 6),

              _buildTextField(
                controller: _studioController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Studio is required.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              _buildLabel('Director'),
              const SizedBox(height: 6),

              _buildTextField(controller: _directorController),
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
        _buildLabel('Studio'),
        const SizedBox(height: 6),

        _buildTextField(
          controller: _studioController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Studio is required.';
            }

            return null;
          },
        ),

        const SizedBox(height: 12),

        _buildLabel('Director'),
        const SizedBox(height: 6),

        _buildTextField(controller: _directorController),

        const SizedBox(height: 12),

        _buildLabel('Release Date'),
        const SizedBox(height: 6),

        _buildDateButton(),
      ],
    );
  }

  Widget _buildDateButton() {
    return InkWell(
      onTap: (_isSaving || _isDeleting) ? null : _selectReleaseDate,
      borderRadius: BorderRadius.circular(6),
      child: Container(
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
  // GENRES
  // ---------------------------------------------------------------------------

  Widget _buildGenres() {
    final selectedGenres = _genres
        .where((genre) => _selectedGenreIds.contains(genre.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Genres'),
        const SizedBox(height: 6),

        InkWell(
          onTap: (_isSaving || _isDeleting) ? null : _showGenreSelector,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: selectedGenres.isEmpty
                      ? const Text(
                          'Select genres...',
                          style: TextStyle(color: AppColors.textSecondary),
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: selectedGenres.map((genre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                genre.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
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
        ),

        const SizedBox(height: 6),

        Text(
          '${_selectedGenreIds.length} '
          'genre${_selectedGenreIds.length == 1 ? '' : 's'} selected',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SHARED INPUTS
  // ---------------------------------------------------------------------------

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

  Widget _buildTextField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
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
// GENRE SELECTION DIALOG
// =============================================================================

class _GenreSelectionDialog extends StatefulWidget {
  const _GenreSelectionDialog({
    required this.genres,
    required this.selectedGenreIds,
    required this.onChanged,
  });

  final List<BaseClassMU> genres;
  final Set<int> selectedGenreIds;
  final void Function(int genreId, bool selected) onChanged;

  @override
  State<_GenreSelectionDialog> createState() => _GenreSelectionDialogState();
}

class _GenreSelectionDialogState extends State<_GenreSelectionDialog> {
  late final Set<int> _selectedIds;

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _selectedIds = Set<int>.from(widget.selectedGenreIds);
  }

  @override
  Widget build(BuildContext context) {
    final filteredGenres = widget.genres.where((genre) {
      if (_searchText.trim().isEmpty) {
        return true;
      }

      return genre.name.toLowerCase().contains(
        _searchText.trim().toLowerCase(),
      );
    }).toList();

    return AlertDialog(
      backgroundColor: AppColors.backgroundPrimary,
      title: const Text(
        'Select Genres',
        style: TextStyle(color: AppColors.textPrimary),
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
                hintText: 'Search genres...',
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
              child: filteredGenres.isEmpty
                  ? const Center(
                      child: Text(
                        'No genres found.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredGenres.length,
                      itemBuilder: (context, index) {
                        final genre = filteredGenres[index];

                        final selected = _selectedIds.contains(genre.id);

                        return CheckboxListTile(
                          value: selected,
                          title: Text(
                            genre.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          activeColor: AppColors.backgroundTertiary,
                          checkColor: AppColors.textPrimary,
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              if (value) {
                                _selectedIds.add(genre.id);
                              } else {
                                _selectedIds.remove(genre.id);
                              }
                            });
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

        ElevatedButton(
          onPressed: () {
            for (final genre in widget.genres) {
              final selected = _selectedIds.contains(genre.id);

              widget.onChanged(genre.id, selected);
            }

            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

// =============================================================================
// POSTER PREVIEW
// =============================================================================

class _MoviePosterPreview extends StatelessWidget {
  const _MoviePosterPreview({required this.imageUrl});

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
