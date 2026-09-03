import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/user_favorites.dart';
import '../../requests_and_models/auth_r&m/auth_result.dart';
import '../../requests_and_models/entity_r&m/user_favorites/userfavorites_models.dart';
import '../../requests_and_models/helper_r&m/api_result_helpers/api_result.dart';
import '../../requests_and_models/helper_r&m/paged_result/paged_result.dart';

// =============================================================================
// PROFILE FAVORITES WIDGET
// =============================================================================

class ProfileFavoritesWidget extends StatefulWidget {
  const ProfileFavoritesWidget({super.key});

  @override
  State<ProfileFavoritesWidget> createState() => ProfileFavoritesWidgetState();
}

// =============================================================================
// PROFILE FAVORITES WIDGET STATE
// =============================================================================

class ProfileFavoritesWidgetState extends State<ProfileFavoritesWidget> {
  // ---------------------------------------------------------------------------
  // PROVIDER
  // ---------------------------------------------------------------------------

  final UserFavoriteProvider _userFavoriteProvider = UserFavoriteProvider();

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------

  PagedResult<UserFavoritesMU>? _favorites;

  int _currentPage = 0;

  static const int _pageSize = 20;

  // ---------------------------------------------------------------------------
  // LOADING / ERROR
  // ---------------------------------------------------------------------------

  bool _isLoading = true;
  bool _isLoadingMore = false;

  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // INIT STATE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _loadFavorites();
  }

  // ---------------------------------------------------------------------------
  // REFRESH
  // ---------------------------------------------------------------------------

  Future<void> refresh() async {
    await _loadFavorites();
  }

  // ---------------------------------------------------------------------------
  // HAS MORE
  // ---------------------------------------------------------------------------

  bool get hasMore {
    if (_favorites == null) {
      return false;
    }

    return _favorites!.resultList.length < _favorites!.count;
  }

  // ---------------------------------------------------------------------------
  // LOAD FAVORITES
  // ---------------------------------------------------------------------------

  Future<void> _loadFavorites() async {
    final token = AuthResult.accessToken;

    if (token == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to identify the current user.';
      });

      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 0;
      });
    }

    try {
      final ApiResult<PagedResult<UserFavoritesMU>> result =
          await _userFavoriteProvider.getPagedEntityForUsers(
            const UserFavoritesSOU(page: 0, pageSize: _pageSize),
          );

      if (!mounted) {
        return;
      }

      if (result.data != null) {
        setState(() {
          _favorites = result.data;
          _currentPage = 0;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.message ?? 'Failed to load your favorites.';
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load your favorites.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD MORE FAVORITES
  // ---------------------------------------------------------------------------

  Future<void> loadMore() async {
    if (_favorites == null) {
      return;
    }

    if (_isLoadingMore) {
      return;
    }

    if (!hasMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    final int nextPage = _currentPage + 1;

    try {
      final ApiResult<PagedResult<UserFavoritesMU>> result =
          await _userFavoriteProvider.getPagedEntityForUsers(
            UserFavoritesSOU(page: nextPage, pageSize: _pageSize),
          );

      if (!mounted) {
        return;
      }

      if (result.data != null) {
        setState(() {
          _favorites = PagedResult<UserFavoritesMU>(
            count: result.data!.count,
            resultList: [..._favorites!.resultList, ...result.data!.resultList],
          );

          _currentPage = nextPage;
        });
      }
    } catch (e) {
      // Keep the already-loaded favorites if loading
      // another page fails.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_favorites == null || _favorites!.resultList.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _favorites!.resultList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (context, index) {
            final favorite = _favorites!.resultList[index];

            return _buildMovieCard(favorite);
          },
        ),

        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MOVIE CARD
  // ---------------------------------------------------------------------------

  Widget _buildMovieCard(UserFavoritesMU favorite) {
    final movie = favorite.movie;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildMovieImage(movie.image)),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${movie.releaseDate.year}',
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOVIE IMAGE
  // ---------------------------------------------------------------------------

  Widget _buildMovieImage(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return _buildImagePlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGE PLACEHOLDER
  // ---------------------------------------------------------------------------

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.backgroundTertiary,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: 42,
          color: AppColors.textPrimary.withOpacity(0.5),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.favorite_border,
            size: 52,
            color: AppColors.textPrimary.withOpacity(0.4),
          ),

          const SizedBox(height: 16),

          const Text(
            'No Favorites Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Movies you add to your favorites will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR STATE
  // ---------------------------------------------------------------------------

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.textPrimary.withOpacity(0.4),
          ),

          const SizedBox(height: 14),

          const Text(
            'Unable to load favorites',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            _errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.6),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: _loadFavorites,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.backgroundTertiary,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
