import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/bluray_provider.dart';
import '../../providers/entity_providers/movie_provider.dart';
import '../../providers/entity_providers/user_favorites.dart';
import '../../requests_and_models/entity_r&m/bluray/bluray_models.dart';
import '../../requests_and_models/entity_r&m/movie/movie_models.dart';
import '../../requests_and_models/entity_r&m/user_favorites/userfavorites_models.dart';
import '../../requests_and_models/helper_r&m/api_result_helpers/api_result.dart';
import '../../requests_and_models/helper_r&m/paged_result/paged_result.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({
    super.key,
    required this.title,
    required this.movieId,
    required this.onBack,
    required this.onBluRaySelected,
  });

  final String title;
  final int movieId;
  final VoidCallback onBack;
  final void Function(BluRayMU bluRay) onBluRaySelected;

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  // ---------------------------------------------------------------------------
  // PROVIDERS
  // ---------------------------------------------------------------------------

  final MovieProvider _movieProvider = MovieProvider();
  final BluRayProvider _bluRayProvider = BluRayProvider();
  final UserFavoriteProvider _userFavoriteProvider = UserFavoriteProvider();

  // ---------------------------------------------------------------------------
  // MOVIE
  // ---------------------------------------------------------------------------

  MovieMU? _movie;

  // ---------------------------------------------------------------------------
  // BLU-RAYS
  // ---------------------------------------------------------------------------

  List<BluRayMU> _bluRays = [];

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  bool _isLoading = true;
  bool _isMovieFavorite = false;
  bool _isCheckingFavorite = true;
  bool _isUpdatingFavorite = false;
  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _loadMovieData();
  }

  // ---------------------------------------------------------------------------
  // LOAD MOVIE DATA
  // ---------------------------------------------------------------------------

  Future<void> _loadMovieData() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isCheckingFavorite = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // -----------------------------------------------------------------------
      // LOAD MOVIE
      // -----------------------------------------------------------------------

      final ApiResult<MovieMU> movieResult = await _movieProvider
          .entityGetByIdForUsers(widget.movieId);

      if (!mounted) {
        return;
      }

      if (movieResult.statusCode == null ||
          movieResult.statusCode! < 200 ||
          movieResult.statusCode! >= 300 ||
          movieResult.data == null) {
        setState(() {
          _movie = null;
          _bluRays = [];
          _isMovieFavorite = false;
          _errorMessage = movieResult.message ?? "Failed to load movie.";
          _isLoading = false;
        });

        return;
      }

      final MovieMU movie = movieResult.data!;

      setState(() {
        _movie = movie;
      });

      // -----------------------------------------------------------------------
      // CHECK IF MOVIE IS IN FAVORITES
      // -----------------------------------------------------------------------

      final ApiResult<bool> favoriteResult = await _userFavoriteProvider
          .isMovieInFavorites(widget.movieId);

      if (!mounted) {
        return;
      }

      if (favoriteResult.statusCode != null &&
          favoriteResult.statusCode! >= 200 &&
          favoriteResult.statusCode! < 300 &&
          favoriteResult.data != null) {
        setState(() {
          _isMovieFavorite = favoriteResult.data!;
          _isCheckingFavorite = false;
        });
      } else {
        _isMovieFavorite = false;
        _isCheckingFavorite = false;

        setState(() {
          _isMovieFavorite = false;
        });
      }

      // -----------------------------------------------------------------------
      // LOAD BLU-RAYS
      // -----------------------------------------------------------------------

      final BluRaySOU bluRaySearch = BluRaySOU(
        page: 0,
        pageSize: 100,
        movieId: widget.movieId,
      );

      final ApiResult<PagedResult<BluRayMU>> bluRayResult =
          await _bluRayProvider.getPagedEntityForUsers(bluRaySearch);

      if (!mounted) {
        return;
      }

      if (bluRayResult.statusCode != null &&
          bluRayResult.statusCode! >= 200 &&
          bluRayResult.statusCode! < 300 &&
          bluRayResult.data != null) {
        setState(() {
          _bluRays = bluRayResult.data!.resultList;
        });
      } else {
        // The movie itself can still be displayed even if
        // the Blu-ray request fails.
        setState(() {
          _bluRays = [];
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _movie = null;
        _bluRays = [];
        _isMovieFavorite = false;
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

  Future<void> _toggleMovieFavorite() async {
    if (_isCheckingFavorite || _isUpdatingFavorite) {
      return;
    }

    setState(() {
      _isUpdatingFavorite = true;
    });

    try {
      if (_isMovieFavorite) {
        // -----------------------------------------------------------------------
        // REMOVE FROM FAVORITES
        // -----------------------------------------------------------------------

        final ApiResult<bool> result = await _userFavoriteProvider
            .removeMovieFromFavorites(widget.movieId);

        if (!mounted) {
          return;
        }

        if (result.statusCode != null &&
            result.statusCode! >= 200 &&
            result.statusCode! < 300) {
          setState(() {
            _isMovieFavorite = false;
            _isUpdatingFavorite = false;
          });
        } else {
          setState(() {
            _isUpdatingFavorite = false;
          });

          _showFavoriteError(
            result.message ?? 'Failed to remove movie from favorites.',
          );
        }
      } else {
        // -----------------------------------------------------------------------
        // ADD TO FAVORITES
        // -----------------------------------------------------------------------

        final ApiResult<UserFavoritesMU> result = await _userFavoriteProvider
            .insertEntityForUsers(UserFavoritesIRU(movieId: widget.movieId));

        if (!mounted) {
          return;
        }

        if (result.statusCode != null &&
            result.statusCode! >= 200 &&
            result.statusCode! < 300) {
          setState(() {
            _isMovieFavorite = true;
            _isUpdatingFavorite = false;
          });
        } else {
          setState(() {
            _isUpdatingFavorite = false;
          });

          _showFavoriteError(
            result.message ?? 'Failed to add movie to favorites.',
          );
        }
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUpdatingFavorite = false;
      });

      _showFavoriteError('Failed to update movie favorites.');
    }
  }

  void _showFavoriteError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
            _buildTopBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------------------------

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ---------------------------------------------------------------------
          // BACK BUTTON
          // ---------------------------------------------------------------------
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),

          const SizedBox(width: 4),

          // ---------------------------------------------------------------------
          // BACK TEXT
          // ---------------------------------------------------------------------
          const Expanded(
            child: Text(
              "Back",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ---------------------------------------------------------------------
          // FAVORITES BUTTON
          // ---------------------------------------------------------------------
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 42,
            child: ElevatedButton(
              onPressed: _isCheckingFavorite || _isUpdatingFavorite
                  ? null
                  : _toggleMovieFavorite,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCheckingFavorite || _isUpdatingFavorite
                    ? AppColors.backgroundSecondary
                    : _isMovieFavorite
                    ? Colors.red.shade700
                    : AppColors.backgroundSecondary,
                disabledBackgroundColor: AppColors.backgroundSecondary,
                foregroundColor: AppColors.textPrimary,
                disabledForegroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        _isMovieFavorite &&
                            !_isCheckingFavorite &&
                            !_isUpdatingFavorite
                        ? Colors.red.shade400
                        : AppColors.backgroundTertiary,
                    width: 1,
                  ),
                ),
                elevation:
                    _isMovieFavorite &&
                        !_isCheckingFavorite &&
                        !_isUpdatingFavorite
                    ? 3
                    : 0,
                shadowColor: Colors.red.withOpacity(0.25),
              ),
              child: _isCheckingFavorite || _isUpdatingFavorite
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isMovieFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isMovieFavorite
                              ? "Movie in Favorites"
                              : "Add Movie to Favorites",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.textPrimary),
      );
    }

    if (_errorMessage != null || _movie == null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadMovieData,
      color: AppColors.backgroundTertiary,
      backgroundColor: AppColors.backgroundSecondary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMovieHeader(),

            const SizedBox(height: 24),

            _buildDescription(),

            const SizedBox(height: 24),

            _buildGenres(),

            const SizedBox(height: 28),

            _buildBluRaySection(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOVIE HEADER
  // ---------------------------------------------------------------------------

  Widget _buildMovieHeader() {
    final movie = _movie!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------------------
        // POSTER
        // ---------------------------------------------------------------------
        SizedBox(
          width: 135,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                movie.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder(iconSize: 45);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return _buildImageLoading();
                },
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // ---------------------------------------------------------------------
        // MOVIE INFORMATION
        // ---------------------------------------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildInfoRow(
                icon: Icons.calendar_today_outlined,
                label: _formatDate(movie.releaseDate),
              ),

              const SizedBox(height: 8),

              _buildInfoRow(icon: Icons.business_outlined, label: movie.studio),

              if (movie.director != null &&
                  movie.director!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),

                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: movie.director!,
                ),
              ],

              const SizedBox(height: 8),

              _buildInfoRow(
                icon: Icons.favorite_outline,
                label: "${movie.favorites} favorites",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DESCRIPTION
  // ---------------------------------------------------------------------------

  Widget _buildDescription() {
    final movie = _movie!;

    if (movie.description.trim().isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "No description available.",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Html(
          data: movie.description,
          style: {
            'body': Style(
              color: AppColors.textSecondary,
              fontSize: FontSize(14),
              lineHeight: const LineHeight(1.5),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            'p': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            'br': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // GENRES
  // ---------------------------------------------------------------------------

  Widget _buildGenres() {
    final movie = _movie!;

    if (movie.movieGenres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Genres",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: movie.movieGenres.map((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                genre,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BLU-RAY SECTION
  // ---------------------------------------------------------------------------

  Widget _buildBluRaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Available Blu-rays",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Text(
              "${_bluRays.length}",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (_bluRays.isEmpty)
          _buildNoBluRays()
        else
          Column(children: _bluRays.map(_buildBluRayCard).toList()),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BLU-RAY CARD
  // ---------------------------------------------------------------------------

  Widget _buildBluRayCard(BluRayMU bluRay) {
    int quantity = 0;

    return StatefulBuilder(
      builder: (context, setCardState) {
        final bool isOutOfStock = bluRay.inStock <= 0;
        final bool canAddToCart = quantity > 0 && !isOutOfStock;

        return InkWell(
          onTap: () {
            widget.onBluRaySelected(bluRay);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -----------------------------------------------------------------
                // POSTER
                // -----------------------------------------------------------------
                SizedBox(
                  width: 75,
                  height: 112,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.network(
                      bluRay.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder(iconSize: 28);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return _buildImageLoading();
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // -----------------------------------------------------------------
                // INFORMATION + ACTIONS
                // -----------------------------------------------------------------
                Expanded(
                  child: SizedBox(
                    height: 112,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------------------------------------------------------
                        // TITLE
                        // ---------------------------------------------------------
                        Text(
                          bluRay.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        // ---------------------------------------------------------
                        // PRICE
                        // ---------------------------------------------------------
                        Text(
                          "${bluRay.price.toStringAsFixed(2)} KM",
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // INFO ROW
  // ---------------------------------------------------------------------------

  Widget _buildInfoRow({required IconData icon, required String label}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // NO BLU-RAYS
  // ---------------------------------------------------------------------------

  Widget _buildNoBluRays() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Icon(Icons.album_outlined, color: AppColors.textSecondary, size: 42),

          SizedBox(height: 10),

          Text(
            "No Blu-rays available",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text(
            "There are currently no Blu-ray editions available for this movie.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR STATE
  // ---------------------------------------------------------------------------

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.textError,
              size: 55,
            ),

            const SizedBox(height: 16),

            const Text(
              "Unable to load movie",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage ?? "Something went wrong.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loadMovieData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundTertiary,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "TRY AGAIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGE HELPERS
  // ---------------------------------------------------------------------------

  Widget _buildImagePlaceholder({required double iconSize}) {
    return Container(
      color: AppColors.backgroundTertiary,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          color: AppColors.textSecondary,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildImageLoading() {
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
  }

  // ---------------------------------------------------------------------------
  // DATE
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");

    return "$day.$month.${date.year}";
  }
}
