import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';
import '../../requests_and_models/entity_r&m/user_favorites/userfavorites_models.dart';
import '../../requests_and_models/helper_r&m/paged_result/paged_result.dart';

// =============================================================================
// PROFILE FAVORITES WIDGET
// =============================================================================

class ProfileFavoritesWidget extends StatelessWidget {
  const ProfileFavoritesWidget({super.key, required this.favorites});

  final PagedResult<UserFavoritesMU>? favorites;

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // LOADING
    // -------------------------------------------------------------------------

    if (favorites == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // EMPTY
    // -------------------------------------------------------------------------

    if (favorites!.resultList.isEmpty) {
      return _buildEmptyState();
    }

    // -------------------------------------------------------------------------
    // FAVORITES
    // -------------------------------------------------------------------------

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favorites!.resultList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        final favorite = favorites!.resultList[index];

        return _buildMovieCard(favorite);
      },
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
          // ---------------------------------------------------------------------
          // MOVIE IMAGE
          // ---------------------------------------------------------------------
          Expanded(child: _buildMovieImage(movie.image)),

          // ---------------------------------------------------------------------
          // MOVIE INFORMATION
          // ---------------------------------------------------------------------
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
    final hasImage = imageUrl.trim().isNotEmpty;

    if (!hasImage) {
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
}
