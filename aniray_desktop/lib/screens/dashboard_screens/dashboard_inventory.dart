import 'dart:async';

import 'package:aniray_desktop/models/basic_entities/basic_entities.dart';
import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:aniray_desktop/providers/api_result.dart';
import 'package:aniray_desktop/providers/entity_providers/genre_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/movie_provider.dart';
import 'package:aniray_desktop/screens/other_screens/movie_details_screen.dart';
import 'package:aniray_desktop/theme/app_colors.dart';
import 'package:aniray_desktop/widgets/main_sidebar_widget.dart';
import 'package:flutter/material.dart';

class DashboardInventoryScreen extends StatefulWidget {
  const DashboardInventoryScreen({
    super.key,
    required this.title,
    this.onMovieSelected,
  });

  final String title;

  final void Function(MovieME movie)? onMovieSelected;

  @override
  State<DashboardInventoryScreen> createState() =>
      _DashboardInventoryScreenState();
}

class _DashboardInventoryScreenState extends State<DashboardInventoryScreen> {
  // ---------------------------------------------------------------------------
  // CONSTANTS
  // ---------------------------------------------------------------------------

  static const int _pageSize = 40;

  static const double _movieCardWidth = 150;
  static const double _movieCardHeight = 250;

  static const double _movieSpacing = 40;
  static const double _movieRunSpacing = 30;

  // ---------------------------------------------------------------------------
  // PROVIDERS / CONTROLLERS
  // ---------------------------------------------------------------------------

  final MovieProvider _movieProvider = MovieProvider();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  // ---------------------------------------------------------------------------
  // FILTER STATE
  // ---------------------------------------------------------------------------

  DateTime? _releaseDateGTE;
  DateTime? _releaseDateLTE;

  int? _favoritesGTE;
  int? _favoritesLTE;

  String? _studioFTS;
  String? _directorFTS;

  // Selected genre IDs.
  List<int>? _genreIds;

  MovieSortField? _orderBy;
  SortType? _sortType;

  bool? _isDeleted = false;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  List<MovieME> _movies = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _page = 0;
  int _totalMovies = 0;

  // ---------------------------------------------------------------------------
  // PAGINATION
  // ---------------------------------------------------------------------------

  int get _totalPages {
    if (_totalMovies == 0) {
      return 1;
    }

    return (_totalMovies / _pageSize).ceil();
  }

  bool get _canGoPrevious => _page > 0;

  bool get _canGoNext => _page < _totalPages - 1;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _loadMovies();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------

  Future<void> _loadMovies() async {
    _setLoading();

    final String searchText = _searchController.text.trim();

    final search = MovieSOE(
      page: _page,
      pageSize: _pageSize,

      // -----------------------------------------------------------------------
      // SEARCH BAR
      // -----------------------------------------------------------------------
      titleFTS: searchText.isEmpty ? null : searchText,

      // -----------------------------------------------------------------------
      // FILTERS
      // -----------------------------------------------------------------------
      releaseDateGTE: _releaseDateGTE,
      releaseDateLTE: _releaseDateLTE,

      favoritesGTE: _favoritesGTE,
      favoritesLTE: _favoritesLTE,

      studioFTS: _studioFTS,
      directorFTS: _directorFTS,

      // Always include genres in returned movie data.
      isGenresIncluded: true,

      // Actual genre filtering.
      //
      // null/empty -> no genre filter.
      //
      // [1] -> movie must have genre 1.
      //
      // [1, 2, 5] -> movie must have genres 1 AND 2 AND 5.
      genreIds: _genreIds,

      orderBy: _orderBy,
      sortType: _sortType,

      // -----------------------------------------------------------------------
      // EMPLOYEE-ONLY FILTER
      // -----------------------------------------------------------------------
      isDeleted: _isDeleted,
    );

    final ApiResult result = await _movieProvider.getPagedEntityForEmployees(
      search,
    );

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      _handleMoviesLoaded(result.data);
    } else {
      _handleMoviesLoadError(result.message ?? 'Failed to load movies.');
    }
  }

  void _setLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  void _handleMoviesLoaded(dynamic pagedResult) {
    setState(() {
      _movies = pagedResult.resultList;
      _totalMovies = pagedResult.count;
      _isLoading = false;
    });
  }

  void _handleMoviesLoadError(String message) {
    setState(() {
      _movies = [];
      _isLoading = false;
      _errorMessage = message;
    });
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _page = 0;
    });

    await _loadMovies();
  }

  // ---------------------------------------------------------------------------
  // PAGINATION ACTIONS
  // ---------------------------------------------------------------------------

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages || page == _page) {
      return;
    }

    setState(() {
      _page = page;
    });

    _loadMovies();
  }

  void _goToFirstPage() {
    _goToPage(0);
  }

  void _goToPreviousPage() {
    _goToPage(_page - 1);
  }

  void _goToNextPage() {
    _goToPage(_page + 1);
  }

  void _goToLastPage() {
    _goToPage(_totalPages - 1);
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundPrimary,
      child: SafeArea(
        child: Column(
          children: [
            // -------------------------------------------------------------------
            // TOP BAR
            // -------------------------------------------------------------------
            _buildTopBar(),

            const SizedBox(height: 30),

            // -------------------------------------------------------------------
            // CONTENT
            // -------------------------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 30),
                child: _buildMovieContent(),
              ),
            ),

            // -------------------------------------------------------------------
            // PAGINATION
            // -------------------------------------------------------------------
            if (_shouldShowPagination()) ...[
              const SizedBox(height: 25),
              _buildPagination(),
            ],
          ],
        ),
      ),
    );
  }

  bool _shouldShowPagination() {
    return !_isLoading && _errorMessage == null && _movies.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // MOVIE CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildMovieContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_movies.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMovieGrid();
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.textPrimary),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------------------------

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 35, 100, 5),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // -------------------------------------------------------------------
            // SEARCH + FILTER — EXACTLY CENTERED ON SCREEN
            // -------------------------------------------------------------------
            _buildSearchAndFilter(),

            // -------------------------------------------------------------------
            // ADD MOVIE — RIGHT SIDE
            // -------------------------------------------------------------------
            Align(
              alignment: Alignment.centerRight,
              child: _buildAddMovieButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, minWidth: 300),
          child: _buildSearchField(),
        ),

        const SizedBox(width: 22),

        _buildFilterButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textPrimary,
                size: 28,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterButton() {
    return _buildIconButton(
      icon: Icons.tune,
      size: 42,
      iconSize: 25,
      onPressed: _onFilterPressed,
    );
  }

  Future<void> _onFilterPressed() async {
    final MovieFilterResult? result = await showDialog<MovieFilterResult>(
      context: context,
      builder: (context) {
        return MovieFilterDialog(
          releaseDateGTE: _releaseDateGTE,
          releaseDateLTE: _releaseDateLTE,

          favoritesGTE: _favoritesGTE,
          favoritesLTE: _favoritesLTE,

          studioFTS: _studioFTS,
          directorFTS: _directorFTS,

          genreIds: _genreIds,

          orderBy: _orderBy,
          sortType: _sortType,

          isDeleted: _isDeleted,
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _releaseDateGTE = result.releaseDateGTE;
      _releaseDateLTE = result.releaseDateLTE;

      _favoritesGTE = result.favoritesGTE;
      _favoritesLTE = result.favoritesLTE;

      _studioFTS = result.studioFTS;
      _directorFTS = result.directorFTS;

      _genreIds = result.genreIds;

      _orderBy = result.orderBy;
      _sortType = result.sortType;

      _isDeleted = result.isDeleted;

      // Any filter change should return to page 0.
      _page = 0;
    });

    await _loadMovies();
  }

  Widget _buildAddMovieButton() {
    return SizedBox(
      height: 42,
      child: Material(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: _onAddMoviePressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.textPrimary, size: 22),

                SizedBox(width: 10),

                Text(
                  'Add Movie',
                  style: TextStyle(
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
    );
  }

  void _onAddMoviePressed() {
    // Add Movie functionality will be added later.
  }

  Widget _buildIconButton({
    required IconData icon,
    required double size,
    required double iconSize,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Icon(icon, color: AppColors.textPrimary, size: iconSize),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOVIE GRID
  // ---------------------------------------------------------------------------

  Widget _buildMovieGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Align(
        alignment: Alignment.topCenter,
        child: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.start,
          spacing: _movieSpacing,
          runSpacing: _movieRunSpacing,
          children: _movies.map(_buildMovieGridItem).toList(),
        ),
      ),
    );
  }

  Widget _buildMovieGridItem(MovieME movie) {
    return SizedBox(
      width: _movieCardWidth,
      height: _movieCardHeight,
      child: _buildMovieCard(movie),
    );
  }

  // ---------------------------------------------------------------------------
  // MOVIE CARD
  // ---------------------------------------------------------------------------

  Widget _buildMovieCard(MovieME movie) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openMovieDetails(movie),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildMoviePoster(movie)),

            const SizedBox(height: 8),

            _buildMovieTitle(movie),
          ],
        ),
      ),
    );
  }

  Widget _buildMoviePoster(MovieME movie) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: AppColors.backgroundSecondary,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        movie.image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: _buildMovieImageError,
        loadingBuilder: _buildMovieImageLoader,
      ),
    );
  }

  Widget _buildMovieImageError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Center(
      child: Icon(
        Icons.movie_outlined,
        color: AppColors.textSecondary,
        size: 40,
      ),
    );
  }

  Widget _buildMovieImageLoader(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) {
      return child;
    }

    return const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMovieTitle(MovieME movie) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        movie.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  void _openMovieDetails(MovieME movie) {
    widget.onMovieSelected?.call(movie);
  }

  // ---------------------------------------------------------------------------
  // PAGINATION
  // ---------------------------------------------------------------------------

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageButton(
            icon: Icons.first_page,
            enabled: _canGoPrevious,
            onPressed: _goToFirstPage,
          ),

          const SizedBox(width: 6),

          _buildPageButton(
            icon: Icons.chevron_left,
            enabled: _canGoPrevious,
            onPressed: _goToPreviousPage,
          ),

          const SizedBox(width: 16),

          _buildPageIndicator(),

          const SizedBox(width: 16),

          _buildPageButton(
            icon: Icons.chevron_right,
            enabled: _canGoNext,
            onPressed: _goToNextPage,
          ),

          const SizedBox(width: 6),

          _buildPageButton(
            icon: Icons.last_page,
            enabled: _canGoNext,
            onPressed: _goToLastPage,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Text(
      'Page ${_page + 1} of $_totalPages',
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: enabled
            ? AppColors.backgroundSecondary
            : AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onPressed : null,
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR / EMPTY STATES
  // ---------------------------------------------------------------------------

  Widget _buildErrorState() {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildErrorIcon(),

            const SizedBox(height: 14),

            _buildErrorMessage(),

            const SizedBox(height: 18),

            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return const Icon(
      Icons.error_outline,
      color: AppColors.textError,
      size: 50,
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      _errorMessage!,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton(onPressed: _loadMovies, child: const Text('Retry'));
  }

  Widget _buildEmptyState() {
    return const SizedBox(
      width: double.infinity,
      child: Center(
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
              'No movies found',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// MOVIE FILTER RESULT
// =============================================================================

class MovieFilterResult {
  final DateTime? releaseDateGTE;
  final DateTime? releaseDateLTE;

  final int? favoritesGTE;
  final int? favoritesLTE;

  final String? studioFTS;
  final String? directorFTS;

  final List<int>? genreIds;

  final MovieSortField? orderBy;
  final SortType? sortType;

  final bool? isDeleted;

  const MovieFilterResult({
    this.releaseDateGTE,
    this.releaseDateLTE,

    this.favoritesGTE,
    this.favoritesLTE,

    this.studioFTS,
    this.directorFTS,

    this.genreIds,

    this.orderBy,
    this.sortType,

    this.isDeleted,
  });
}

// =============================================================================
// MOVIE FILTER DIALOG
// =============================================================================

class MovieFilterDialog extends StatefulWidget {
  const MovieFilterDialog({
    super.key,

    this.releaseDateGTE,
    this.releaseDateLTE,

    this.favoritesGTE,
    this.favoritesLTE,

    this.studioFTS,
    this.directorFTS,

    this.genreIds,

    this.orderBy,
    this.sortType,

    this.isDeleted,
  });

  final DateTime? releaseDateGTE;
  final DateTime? releaseDateLTE;

  final int? favoritesGTE;
  final int? favoritesLTE;

  final String? studioFTS;
  final String? directorFTS;

  final List<int>? genreIds;

  final MovieSortField? orderBy;
  final SortType? sortType;

  final bool? isDeleted;

  @override
  State<MovieFilterDialog> createState() => _MovieFilterDialogState();
}

class _MovieFilterDialogState extends State<MovieFilterDialog> {
  // ---------------------------------------------------------------------------
  // PROVIDERS
  // ---------------------------------------------------------------------------

  final GenreProvider _genreProvider = GenreProvider();

  // ---------------------------------------------------------------------------
  // CONTROLLERS
  // ---------------------------------------------------------------------------

  late final TextEditingController _studioController;
  late final TextEditingController _directorController;

  late final TextEditingController _favoritesMinController;
  late final TextEditingController _favoritesMaxController;

  // ---------------------------------------------------------------------------
  // FILTER STATE
  // ---------------------------------------------------------------------------

  DateTime? _releaseDateGTE;
  DateTime? _releaseDateLTE;

  List<int>? _genreIds;

  MovieSortField? _orderBy;
  SortType? _sortType;

  bool? _isDeleted;

  // ---------------------------------------------------------------------------
  // GENRE STATE
  // ---------------------------------------------------------------------------

  List<BaseClassMU> _genres = [];

  bool _isLoadingGenres = false;

  String? _genreError;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _studioController = TextEditingController(text: widget.studioFTS ?? '');

    _directorController = TextEditingController(text: widget.directorFTS ?? '');

    _favoritesMinController = TextEditingController(
      text: widget.favoritesGTE?.toString() ?? '',
    );

    _favoritesMaxController = TextEditingController(
      text: widget.favoritesLTE?.toString() ?? '',
    );

    _releaseDateGTE = widget.releaseDateGTE;
    _releaseDateLTE = widget.releaseDateLTE;

    _genreIds = widget.genreIds == null
        ? null
        : List<int>.from(widget.genreIds!);

    _orderBy = widget.orderBy;
    _sortType = widget.sortType;

    _isDeleted = widget.isDeleted;

    _loadGenres();
  }

  @override
  void dispose() {
    _studioController.dispose();
    _directorController.dispose();

    _favoritesMinController.dispose();
    _favoritesMaxController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // GENRE DATA
  // ---------------------------------------------------------------------------

  Future<void> _loadGenres() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingGenres = true;
      _genreError = null;
    });

    try {
      final List<BaseClassMU> allGenres = [];

      int page = 0;

      // We don't know how many genres exist, so keep requesting pages
      // until the backend returns an empty page or a page smaller than
      // the requested page size.
      const int genrePageSize = 30;

      while (true) {
        final search = BaseClassSOU(page: page, pageSize: genrePageSize);

        final ApiResult result = await _genreProvider.getPagedEntityForUsers(
          search,
        );

        if (result.data == null) {
          throw Exception(result.message ?? 'Failed to load genres.');
        }

        final dynamic pagedResult = result.data;

        final List<BaseClassMU> pageGenres = List<BaseClassMU>.from(
          pagedResult.resultList,
        );

        allGenres.addAll(pageGenres);

        // Stop when this is the last page.
        if (pageGenres.isEmpty || pageGenres.length < genrePageSize) {
          break;
        }

        page++;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _genres = allGenres;
        _isLoadingGenres = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _genres = [];
        _isLoadingGenres = false;
        _genreError = e.toString();
      });
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),

              const SizedBox(height: 25),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _studioController,
                        label: 'Studio',
                        hint: 'Search by studio',
                      ),

                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _directorController,
                        label: 'Director',
                        hint: 'Search by director',
                      ),

                      const SizedBox(height: 24),

                      _buildSectionTitle('Release Date'),

                      const SizedBox(height: 10),

                      _buildDateRange(),

                      const SizedBox(height: 24),

                      _buildSectionTitle('Favorites'),

                      const SizedBox(height: 10),

                      _buildFavoritesRange(),

                      const SizedBox(height: 24),

                      _buildSectionTitle('Genres'),

                      const SizedBox(height: 10),

                      _buildGenreFilter(),

                      const SizedBox(height: 24),

                      _buildSectionTitle('Sorting'),

                      const SizedBox(height: 10),

                      _buildSorting(),

                      const SizedBox(height: 24),

                      _buildDeletedFilter(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.tune, color: AppColors.textPrimary, size: 24),

        const SizedBox(width: 12),

        const Expanded(
          child: Text(
            'Filter Movies',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TEXT FIELD
  // ---------------------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.backgroundTertiary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DATE RANGE
  // ---------------------------------------------------------------------------

  Widget _buildDateRange() {
    return Row(
      children: [
        Expanded(
          child: _buildDateButton(
            label: _releaseDateGTE == null
                ? 'From'
                : _formatDate(_releaseDateGTE!),
            onPressed: () => _selectDate(isStart: true),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildDateButton(
            label: _releaseDateLTE == null
                ? 'To'
                : _formatDate(_releaseDateLTE!),
            onPressed: () => _selectDate(isStart: false),
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: Material(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 18,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final DateTime initialDate =
        (isStart ? _releaseDateGTE : _releaseDateLTE) ?? DateTime.now();

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      if (isStart) {
        _releaseDateGTE = selected;
      } else {
        _releaseDateLTE = selected;
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  // ---------------------------------------------------------------------------
  // FAVORITES
  // ---------------------------------------------------------------------------

  Widget _buildFavoritesRange() {
    return Row(
      children: [
        Expanded(
          child: _buildNumberField(
            controller: _favoritesMinController,
            hint: 'Minimum',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildNumberField(
            controller: _favoritesMaxController,
            hint: 'Maximum',
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.backgroundTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GENRES
  // ---------------------------------------------------------------------------

  Widget _buildGenreFilter() {
    if (_isLoadingGenres) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (_genreError != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.textError,
              size: 20,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                _genreError!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),

            IconButton(
              onPressed: _loadGenres,
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            ),
          ],
        ),
      );
    }

    if (_genres.isEmpty) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No genres available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return _buildGenreMultiSelect();
  }

  Widget _buildGenreMultiSelect() {
    final List<BaseClassMU> selectedGenres = _genres
        .where((genre) => _genreIds?.contains(genre.id) ?? false)
        .toList();

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _openGenrePicker,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.category_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: selectedGenres.isEmpty
                  ? const Text(
                      'Select genres',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: selectedGenres.map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            genre.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(width: 8),

            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GENRE PICKER
  // ---------------------------------------------------------------------------

  Future<void> _openGenrePicker() async {
    final Set<int> selectedIds = {...?_genreIds};

    final Set<int>? result = await showDialog<Set<int>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                  maxHeight: 600,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ---------------------------------------------------------
                      // HEADER
                      // ---------------------------------------------------------
                      Row(
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Text(
                              'Select Genres',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ---------------------------------------------------------
                      // SELECTED COUNT
                      // ---------------------------------------------------------
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          selectedIds.isEmpty
                              ? 'No genres selected'
                              : '${selectedIds.length} genre${selectedIds.length == 1 ? '' : 's'} selected',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ---------------------------------------------------------
                      // GENRE LIST
                      // ---------------------------------------------------------
                      Expanded(
                        child: ListView.builder(
                          itemCount: _genres.length,
                          itemBuilder: (context, index) {
                            final BaseClassMU genre = _genres[index];

                            final bool isSelected = selectedIds.contains(
                              genre.id,
                            );

                            return CheckboxListTile(
                              value: isSelected,
                              title: Text(
                                genre.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              activeColor: AppColors.backgroundTertiary,
                              checkColor: AppColors.textPrimary,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    selectedIds.add(genre.id);
                                  } else {
                                    selectedIds.remove(genre.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ---------------------------------------------------------
                      // ACTIONS
                      // ---------------------------------------------------------
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setDialogState(() {
                                  selectedIds.clear();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: const BorderSide(
                                  color: AppColors.backgroundTertiary,
                                ),
                              ),
                              child: const Text('Clear'),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pop(Set<int>.from(selectedIds));
                              },
                              child: const Text('Done'),
                            ),
                          ),
                        ],
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

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _genreIds = result.isEmpty ? null : result.toList();
    });
  }

  // ---------------------------------------------------------------------------
  // SORTING
  // ---------------------------------------------------------------------------

  Widget _buildSorting() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<MovieSortField?>(
            value: _orderBy,
            dropdownColor: AppColors.backgroundTertiary,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.backgroundTertiary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            hint: const Text(
              'Sort by',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            items: MovieSortField.values.map((field) {
              return DropdownMenuItem<MovieSortField?>(
                value: field,
                child: Text(_sortFieldLabel(field)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _orderBy = value;
              });
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: DropdownButtonFormField<SortType?>(
            value: _sortType,
            dropdownColor: AppColors.backgroundTertiary,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.backgroundTertiary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            hint: const Text(
              'Direction',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            items: SortType.values.map((type) {
              return DropdownMenuItem<SortType?>(
                value: type,
                child: Text(_sortTypeLabel(type)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _sortType = value;
              });
            },
          ),
        ),
      ],
    );
  }

  String _sortFieldLabel(MovieSortField field) {
    switch (field) {
      case MovieSortField.title:
        return 'Title';

      case MovieSortField.releaseDate:
        return 'Release Date';

      case MovieSortField.favorites:
        return 'Favorites';

      case MovieSortField.studio:
        return 'Studio';

      case MovieSortField.director:
        return 'Director';
    }
  }

  String _sortTypeLabel(SortType type) {
    switch (type) {
      case SortType.ascending:
        return 'Ascending';

      case SortType.descending:
        return 'Descending';
    }
  }

  // ---------------------------------------------------------------------------
  // DELETED FILTER
  // ---------------------------------------------------------------------------

  Widget _buildDeletedFilter() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Show only deleted movies',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      value: _isDeleted ?? false,
      activeThumbColor: AppColors.backgroundTertiary,
      onChanged: (value) {
        setState(() {
          _isDeleted = value;
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearFilters,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.backgroundTertiary),
            ),
            child: const Text('Clear'),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Apply'),
          ),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _releaseDateGTE = null;
      _releaseDateLTE = null;

      _favoritesMinController.clear();
      _favoritesMaxController.clear();

      _studioController.clear();
      _directorController.clear();

      _genreIds = null;

      _orderBy = null;
      _sortType = null;

      _isDeleted = false;
    });
  }

  void _applyFilters() {
    final int? favoritesGTE = int.tryParse(_favoritesMinController.text.trim());

    final int? favoritesLTE = int.tryParse(_favoritesMaxController.text.trim());

    Navigator.of(context).pop(
      MovieFilterResult(
        releaseDateGTE: _releaseDateGTE,
        releaseDateLTE: _releaseDateLTE,

        favoritesGTE: favoritesGTE,
        favoritesLTE: favoritesLTE,

        studioFTS: _studioController.text.trim().isEmpty
            ? null
            : _studioController.text.trim(),

        directorFTS: _directorController.text.trim().isEmpty
            ? null
            : _directorController.text.trim(),

        genreIds: _genreIds,

        orderBy: _orderBy,
        sortType: _sortType,

        isDeleted: _isDeleted,
      ),
    );
  }
}
