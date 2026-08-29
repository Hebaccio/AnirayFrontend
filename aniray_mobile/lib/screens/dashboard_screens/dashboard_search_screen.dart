import 'dart:async';

import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/genre_provider.dart';
import '../../providers/entity_providers/movie_provider.dart';
import '../../requests_and_models/entity_r&m/movie/movie_models.dart';
import '../../requests_and_models/helper_r&m/api_result_helpers/api_result.dart';
import '../../requests_and_models/helper_r&m/basic_entities/basic_entities.dart';
import '../../requests_and_models/helper_r&m/paged_result/paged_result.dart';

class DashboardSearchScreen extends StatefulWidget {
  const DashboardSearchScreen({super.key, required this.title});

  final String title;

  @override
  State<DashboardSearchScreen> createState() => _DashboardSearchScreenState();
}

class _DashboardSearchScreenState extends State<DashboardSearchScreen> {
  // ---------------------------------------------------------------------------
  // CONSTANTS
  // ---------------------------------------------------------------------------

  static const int _pageSize = 21;

  // ---------------------------------------------------------------------------
  // PROVIDERS
  // ---------------------------------------------------------------------------

  final MovieProvider _movieProvider = MovieProvider();
  final GenreProvider _genreProvider = GenreProvider();

  // ---------------------------------------------------------------------------
  // CONTROLLERS
  // ---------------------------------------------------------------------------

  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  Timer? _searchDebounce;

  // ---------------------------------------------------------------------------
  // MOVIES
  // ---------------------------------------------------------------------------

  List<MovieMU> _movies = [];

  bool _isLoading = false;
  String? _errorMessage;

  int _page = 0;
  int _totalMovies = 0;

  // ---------------------------------------------------------------------------
  // FILTERS
  // ---------------------------------------------------------------------------

  DateTime? _releaseDateGTE;
  DateTime? _releaseDateLTE;

  int? _favoritesGTE;
  int? _favoritesLTE;

  String? _studioFTS;
  String? _directorFTS;

  final Set<int> _selectedGenreIds = {};

  MovieSortField? _orderBy;
  SortType? _sortType;

  // ---------------------------------------------------------------------------
  // GENRES
  // ---------------------------------------------------------------------------

  List<BaseClassMU> _genres = [];

  bool _isLoadingGenres = false;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _loadGenres();
    _loadMovies();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SCROLL
  // ---------------------------------------------------------------------------

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _page = 0;
      });

      _scrollToTop();

      _loadMovies();
    });
  }

  // ---------------------------------------------------------------------------
  // LOAD MOVIES
  // ---------------------------------------------------------------------------

  Future<void> _loadMovies() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final search = MovieSOU(
        page: _page,
        pageSize: _pageSize,

        titleFTS: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),

        releaseDateGTE: _releaseDateGTE,
        releaseDateLTE: _releaseDateLTE,

        favoritesGTE: _favoritesGTE,
        favoritesLTE: _favoritesLTE,

        studioFTS: _studioFTS,
        directorFTS: _directorFTS,

        isGenresIncluded: true,

        genreIds: _selectedGenreIds.isEmpty ? null : _selectedGenreIds.toList(),

        orderBy: _orderBy,
        sortType: _sortType,
      );

      final ApiResult<PagedResult<MovieMU>> result = await _movieProvider
          .getPagedEntityForUsers(search);

      if (!mounted) return;

      if (result.statusCode != null &&
          result.statusCode! >= 200 &&
          result.statusCode! < 300) {
        setState(() {
          _movies = result.data!.resultList;
          _totalMovies = result.data!.count;
        });
      } else {
        setState(() {
          _movies = [];
          _totalMovies = 0;
          _errorMessage = result.message ?? "Failed to load movies.";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _movies = [];
        _totalMovies = 0;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD GENRES
  // ---------------------------------------------------------------------------

  Future<void> _loadGenres() async {
    if (!mounted) return;

    setState(() {
      _isLoadingGenres = true;
    });

    try {
      final search = BaseClassSOU(page: 0, pageSize: 100);

      final ApiResult<PagedResult<BaseClassMU>> result = await _genreProvider
          .getPagedEntityForUsers(search);

      if (!mounted) return;

      if (result.statusCode != null &&
          result.statusCode! >= 200 &&
          result.statusCode! < 300 &&
          result.data != null) {
        setState(() {
          _genres = result.data!.resultList;
        });
      }
    } catch (_) {
      // Genres are optional for displaying the movie list.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGenres = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // PAGINATION
  // ---------------------------------------------------------------------------

  int get _totalPages {
    if (_totalMovies == 0) {
      return 0;
    }

    return (_totalMovies / _pageSize).ceil();
  }

  bool get _canGoPrevious {
    return _page > 0;
  }

  bool get _canGoNext {
    return _page + 1 < _totalPages;
  }

  void _previousPage() {
    if (!_canGoPrevious || _isLoading) {
      return;
    }

    setState(() {
      _page--;
    });

    // Move the whole page back to the top.
    _scrollToTop();

    _loadMovies();
  }

  void _firstPage() {
    if (!_canGoPrevious || _isLoading) {
      return;
    }

    setState(() {
      _page = 0;
    });

    _scrollToTop();

    _loadMovies();
  }

  void _lastPage() {
    if (!_canGoNext || _isLoading) {
      return;
    }

    setState(() {
      _page = _totalPages - 1;
    });

    _scrollToTop();

    _loadMovies();
  }

  void _nextPage() {
    if (!_canGoNext || _isLoading) {
      return;
    }

    setState(() {
      _page++;
    });

    // Move the whole page back to the top.
    _scrollToTop();

    _loadMovies();
  }

  // ---------------------------------------------------------------------------
  // FILTERS
  // ---------------------------------------------------------------------------

  bool get _hasActiveFilters {
    return _releaseDateGTE != null ||
        _releaseDateLTE != null ||
        _favoritesGTE != null ||
        _favoritesLTE != null ||
        (_studioFTS != null && _studioFTS!.trim().isNotEmpty) ||
        (_directorFTS != null && _directorFTS!.trim().isNotEmpty) ||
        _selectedGenreIds.isNotEmpty ||
        _orderBy != null ||
        _sortType != null;
  }

  void _clearFilters() {
    setState(() {
      _releaseDateGTE = null;
      _releaseDateLTE = null;

      _favoritesGTE = null;
      _favoritesLTE = null;

      _studioFTS = null;
      _directorFTS = null;

      _selectedGenreIds.clear();

      _orderBy = null;
      _sortType = null;

      _page = 0;
    });

    _scrollToTop();

    _loadMovies();
  }

  // ---------------------------------------------------------------------------
  // FILTER DIALOG
  // ---------------------------------------------------------------------------

  Future<void> _openFilters() async {
    DateTime? releaseDateGTE = _releaseDateGTE;
    DateTime? releaseDateLTE = _releaseDateLTE;

    int? favoritesGTE = _favoritesGTE;
    int? favoritesLTE = _favoritesLTE;

    String studioFTS = _studioFTS ?? "";
    String directorFTS = _directorFTS ?? "";

    final Set<int> selectedGenreIds = {..._selectedGenreIds};

    MovieSortField? orderBy = _orderBy;
    SortType? sortType = _sortType;

    final studioController = TextEditingController(text: studioFTS);

    final directorController = TextEditingController(text: directorFTS);

    final favoritesFromController = TextEditingController(
      text: favoritesGTE?.toString() ?? "",
    );

    final favoritesToController = TextEditingController(
      text: favoritesLTE?.toString() ?? "",
    );

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -------------------------------------------------------
                      // HEADER
                      // -------------------------------------------------------
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Filters",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text(
                              "Close",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                releaseDateGTE = null;
                                releaseDateLTE = null;

                                favoritesGTE = null;
                                favoritesLTE = null;

                                studioController.clear();
                                directorController.clear();

                                selectedGenreIds.clear();

                                orderBy = null;
                                sortType = null;
                              });
                            },
                            child: const Text(
                              "Clear",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // -------------------------------------------------------
                      // RELEASE DATE
                      // -------------------------------------------------------
                      const Text(
                        "Release Date",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _dateFilterButton(
                              label: releaseDateGTE == null
                                  ? "From"
                                  : _formatDate(releaseDateGTE!),
                              onPressed: () async {
                                final date = await _pickDate(
                                  context,
                                  releaseDateGTE,
                                );

                                if (date != null) {
                                  setModalState(() {
                                    releaseDateGTE = date;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _dateFilterButton(
                              label: releaseDateLTE == null
                                  ? "To"
                                  : _formatDate(releaseDateLTE!),
                              onPressed: () async {
                                final date = await _pickDate(
                                  context,
                                  releaseDateLTE,
                                );

                                if (date != null) {
                                  setModalState(() {
                                    releaseDateLTE = date;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // -------------------------------------------------------
                      // FAVORITES
                      // -------------------------------------------------------
                      const Text(
                        "Favorites",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _filterTextField(
                              controller: favoritesFromController,
                              label: "Minimum",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _filterTextField(
                              controller: favoritesToController,
                              label: "Maximum",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // -------------------------------------------------------
                      // STUDIO
                      // -------------------------------------------------------
                      const Text(
                        "Studio",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _filterTextField(
                        controller: studioController,
                        label: "Studio",
                      ),

                      const SizedBox(height: 20),

                      // -------------------------------------------------------
                      // DIRECTOR
                      // -------------------------------------------------------
                      const Text(
                        "Director",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _filterTextField(
                        controller: directorController,
                        label: "Director",
                      ),

                      const SizedBox(height: 20),

                      // -------------------------------------------------------
                      // GENRES
                      // -------------------------------------------------------
                      const Text(
                        "Genres",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (_isLoadingGenres)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_genres.isEmpty)
                        const Text(
                          "No genres available.",
                          style: TextStyle(color: AppColors.textSecondary),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _genres.map((genre) {
                            final isSelected = selectedGenreIds.contains(
                              genre.id,
                            );

                            return FilterChip(
                              label: Text(genre.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    selectedGenreIds.add(genre.id);
                                  } else {
                                    selectedGenreIds.remove(genre.id);
                                  }
                                });
                              },
                              backgroundColor: AppColors.backgroundTertiary,
                              selectedColor: AppColors.backgroundPrimary,
                              labelStyle: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              checkmarkColor: AppColors.textPrimary,
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 20),

                      // -------------------------------------------------------
                      // SORT
                      // -------------------------------------------------------
                      const Text(
                        "Sort By",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<MovieSortField?>(
                        value: orderBy,
                        dropdownColor: AppColors.backgroundTertiary,
                        decoration: _filterDecoration("Sort field"),
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: const [
                          DropdownMenuItem<MovieSortField?>(
                            value: null,
                            child: Text("Default"),
                          ),
                          DropdownMenuItem(
                            value: MovieSortField.title,
                            child: Text("Title"),
                          ),
                          DropdownMenuItem(
                            value: MovieSortField.releaseDate,
                            child: Text("Release Date"),
                          ),
                          DropdownMenuItem(
                            value: MovieSortField.favorites,
                            child: Text("Favorites"),
                          ),
                          DropdownMenuItem(
                            value: MovieSortField.studio,
                            child: Text("Studio"),
                          ),
                          DropdownMenuItem(
                            value: MovieSortField.director,
                            child: Text("Director"),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            orderBy = value;

                            if (value == null) {
                              sortType = null;
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<SortType?>(
                        value: sortType,
                        dropdownColor: AppColors.backgroundTertiary,
                        decoration: _filterDecoration("Sort direction"),
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: const [
                          DropdownMenuItem<SortType?>(
                            value: null,
                            child: Text("Default"),
                          ),
                          DropdownMenuItem(
                            value: SortType.ascending,
                            child: Text("Ascending"),
                          ),
                          DropdownMenuItem(
                            value: SortType.descending,
                            child: Text("Descending"),
                          ),
                        ],
                        onChanged: orderBy == null
                            ? null
                            : (value) {
                                setModalState(() {
                                  sortType = value;
                                });
                              },
                      ),

                      const SizedBox(height: 30),

                      // -------------------------------------------------------
                      // APPLY
                      // -------------------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            favoritesGTE = int.tryParse(
                              favoritesFromController.text.trim(),
                            );

                            favoritesLTE = int.tryParse(
                              favoritesToController.text.trim(),
                            );

                            studioFTS = studioController.text.trim();

                            directorFTS = directorController.text.trim();

                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.backgroundTertiary,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "APPLY FILTERS",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    studioController.dispose();
    directorController.dispose();
    favoritesFromController.dispose();
    favoritesToController.dispose();

    if (result != true || !mounted) {
      return;
    }

    setState(() {
      _releaseDateGTE = releaseDateGTE;
      _releaseDateLTE = releaseDateLTE;

      _favoritesGTE = favoritesGTE;
      _favoritesLTE = favoritesLTE;

      _studioFTS = studioFTS.trim().isEmpty ? null : studioFTS.trim();

      _directorFTS = directorFTS.trim().isEmpty ? null : directorFTS.trim();

      _selectedGenreIds
        ..clear()
        ..addAll(selectedGenreIds);

      _orderBy = orderBy;
      _sortType = sortType;

      _page = 0;
    });

    _scrollToTop();

    _loadMovies();
  }

  // ---------------------------------------------------------------------------
  // DATE PICKER
  // ---------------------------------------------------------------------------

  Future<DateTime?> _pickDate(
    BuildContext context,
    DateTime? initialDate,
  ) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.backgroundTertiary,
              surface: AppColors.backgroundSecondary,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------

  InputDecoration _filterDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.backgroundTertiary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _filterTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _filterDecoration(label),
    );
  }

  Widget _dateFilterButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.backgroundTertiary,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");

    return "$day.$month.${date.year}";
  }

  // ---------------------------------------------------------------------------
  // MOVIE CARD
  // ---------------------------------------------------------------------------

  Widget _movieCard(MovieMU movie) {
    return GestureDetector(
      onTap: () {
        // MovieScreen will be connected here later.
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Image.network(
                movie.image,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.backgroundTertiary,
                    child: const Center(
                      child: Icon(
                        Icons.movie_outlined,
                        color: AppColors.textSecondary,
                        size: 45,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Container(
                    color: AppColors.backgroundTertiary,
                    child: const Center(
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ---------------------------------------------------------------
            // INFORMATION
            // ---------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,

      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // -----------------------------------------------------------------
              // TOP BAR
              // -----------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: "Search movies...",
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                ),
                          filled: true,
                          fillColor: AppColors.backgroundSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Stack(
                      children: [
                        IconButton(
                          onPressed: _openFilters,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.backgroundSecondary,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.tune),
                        ),

                        if (_hasActiveFilters)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // -----------------------------------------------------------------
              // ACTIVE FILTERS
              // -----------------------------------------------------------------
              if (_hasActiveFilters)
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ActionChip(
                        label: const Text("Clear filters"),
                        onPressed: _clearFilters,
                        backgroundColor: AppColors.backgroundSecondary,
                        labelStyle: const TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

              // -----------------------------------------------------------------
              // CONTENT
              // -----------------------------------------------------------------
              _buildContent(),

              // -----------------------------------------------------------------
              // PAGINATION
              // -----------------------------------------------------------------
              if (!_isLoading && _totalPages > 1) _buildPagination(),

              const SizedBox(height: 20),
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
    if (_isLoading && _movies.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
      );
    }

    if (_errorMessage != null && _movies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.textError,
              size: 50,
            ),

            const SizedBox(height: 16),

            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loadMovies,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundTertiary,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text("TRY AGAIN"),
            ),
          ],
        ),
      );
    }

    if (_movies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.movie_outlined,
              color: AppColors.textSecondary,
              size: 60,
            ),

            SizedBox(height: 16),

            Text(
              "No movies found",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Try changing your search or filters.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),

          // The outer SingleChildScrollView handles scrolling.
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.55,
          ),

          itemCount: _movies.length,

          itemBuilder: (context, index) {
            return _movieCard(_movies[index]);
          },
        ),

        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.textPrimary),
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PAGINATION UI
  // ---------------------------------------------------------------------------

  Widget _buildPagination() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(color: AppColors.backgroundPrimary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // FIRST PAGE
          IconButton(
            onPressed: _canGoPrevious ? _firstPage : null,
            icon: const Icon(Icons.first_page),
            color: AppColors.textPrimary,
            disabledColor: AppColors.textSecondary,
            tooltip: "First page",
          ),

          // PREVIOUS PAGE
          IconButton(
            onPressed: _canGoPrevious ? _previousPage : null,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textPrimary,
            disabledColor: AppColors.textSecondary,
            tooltip: "Previous page",
          ),

          // PAGE NUMBER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "${_page + 1} / $_totalPages",
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // NEXT PAGE
          IconButton(
            onPressed: _canGoNext ? _nextPage : null,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textPrimary,
            disabledColor: AppColors.textSecondary,
            tooltip: "Next page",
          ),

          // LAST PAGE
          IconButton(
            onPressed: _canGoNext ? _lastPage : null,
            icon: const Icon(Icons.last_page),
            color: AppColors.textPrimary,
            disabledColor: AppColors.textSecondary,
            tooltip: "Last page",
          ),
        ],
      ),
    );
  }
}
