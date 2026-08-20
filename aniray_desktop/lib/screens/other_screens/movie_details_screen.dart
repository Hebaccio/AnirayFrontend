import 'package:aniray_desktop/models/bluray/bluray_models.dart';
import 'package:aniray_desktop/providers/entity_providers/bluray_provider.dart';
import 'package:aniray_desktop/screens/other_screens/bluray_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:aniray_desktop/providers/api_result.dart';
import 'package:aniray_desktop/requests/paged_result.dart';
import 'package:flutter_html/flutter_html.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({
    super.key,
    required this.movie,
    this.onBack,
    this.onEditMovie,
  });

  final MovieME movie;
  final VoidCallback? onBack;
  final VoidCallback? onEditMovie;

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final BluRayProvider _bluRayProvider = BluRayProvider();

  List<BluRayME> _offers = [];

  bool _isLoadingOffers = true;
  String? _offersError;

  static const int _page = 0;
  static const int _pageSize = 1000;

  // ---------------------------------------------------------------------------
  // BLURAY EDIT SCREEN
  // ---------------------------------------------------------------------------

  Widget? _bluRayEditPage;

  @override
  void initState() {
    super.initState();
    _loadBluRayOffers();
  }

  // ---------------------------------------------------------------------------
  // LOAD BLURAY OFFERS
  // ---------------------------------------------------------------------------

  Future<void> _loadBluRayOffers() async {
    if (!mounted) return;

    setState(() {
      _isLoadingOffers = true;
      _offersError = null;
    });

    final search = BluRaySOE(
      page: _page,
      pageSize: _pageSize,
      movieId: widget.movie.id,
    );

    final ApiResult<PagedResult<BluRayME>> result = await _bluRayProvider
        .getPagedEntityForEmployees(search);

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      setState(() {
        _offers = result.data!.resultList;
        _isLoadingOffers = false;
      });
    } else {
      setState(() {
        _offers = [];
        _isLoadingOffers = false;
        _offersError = result.message ?? 'Failed to load Blu-ray offers.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // OPEN ADD BLURAY
  // ---------------------------------------------------------------------------

  void _openAddBluRay() {
    setState(() {
      _bluRayEditPage = BluRayEditScreen(
        movieId: widget.movie.id,
        bluRayId: null,
        onBack: _closeBluRayEdit,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // OPEN EDIT BLURAY
  // ---------------------------------------------------------------------------

  void _openEditBluRay(int bluRayId) {
    setState(() {
      _bluRayEditPage = BluRayEditScreen(
        movieId: widget.movie.id,
        bluRayId: bluRayId,
        onBack: _closeBluRayEdit,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // CLOSE BLURAY EDITOR
  // ---------------------------------------------------------------------------

  Future<void> _closeBluRayEdit() async {
    if (!mounted) return;

    setState(() {
      _bluRayEditPage = null;
    });

    // Reload offers so any add/update/delete/restore is reflected.
    await _loadBluRayOffers();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_bluRayEditPage != null) {
      return _bluRayEditPage!;
    }

    final movie = widget.movie;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF08111F),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 36),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildBackButton(),

                    const SizedBox(height: 20),

                    _buildMovieHeader(movie),

                    const SizedBox(height: 42),

                    _buildBottomContent(movie),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // BACK BUTTON
  // ===========================================================================

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 38,
        child: ElevatedButton.icon(
          onPressed: widget.onBack,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF152236),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Back', style: TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  // ===========================================================================
  // MOVIE HEADER
  // ===========================================================================

  Widget _buildMovieHeader(MovieME movie) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainPoster(movie),

        const SizedBox(width: 32),

        Expanded(child: _buildMovieDescription(movie)),
      ],
    );
  }

  Widget _buildMainPoster(MovieME movie) {
    return Container(
      width: 130,
      height: 192,
      decoration: BoxDecoration(
        color: const Color(0xFF17263A),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        movie.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.movie_outlined, color: Colors.white38, size: 45),
          );
        },
      ),
    );
  }

  Widget _buildMovieDescription(MovieME movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(width: 20),

            _buildActionButton(
              label: 'Edit Movie',
              icon: Icons.edit,
              onPressed: widget.onEditMovie ?? () {},
            ),
          ],
        ),

        const SizedBox(height: 16),

        Html(
          data: movie.description,
          style: {
            'body': Style(
              color: const Color(0xFFE1E5EA),
              fontSize: FontSize(14),
              lineHeight: const LineHeight(1.8),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            'p': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // BOTTOM CONTENT
  // ===========================================================================

  Widget _buildBottomContent(MovieME movie) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 196, child: _buildMovieInformation(movie)),

        const SizedBox(width: 24),

        Expanded(child: _buildOffersSection()),
      ],
    );
  }

  // ===========================================================================
  // MOVIE INFORMATION
  // ===========================================================================

  Widget _buildMovieInformation(MovieME movie) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF152236),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem('Release Date', _formatDate(movie.releaseDate)),

          const SizedBox(height: 20),

          _buildInfoItem('Favorites', movie.favorites.toString()),

          const SizedBox(height: 20),

          _buildInfoItem('Studio', movie.studio),

          const SizedBox(height: 20),

          _buildInfoItem('Director', movie.director ?? 'Unknown'),

          const SizedBox(height: 20),

          _buildGenres(movie),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE5E7EB),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFD6DAE0),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildGenres(MovieME movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genres',
          style: TextStyle(
            color: Color(0xFFE5E7EB),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 8),

        if (movie.movieGenres.isEmpty)
          const Text(
            'No genres',
            style: TextStyle(color: Color(0xFFD6DAE0), fontSize: 12),
          )
        else
          ...movie.movieGenres.map(
            (movieGenre) => Text(
              movieGenre.genre.name,
              style: const TextStyle(
                color: Color(0xFFD6DAE0),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // BLU-RAY OFFERS
  // ===========================================================================

  Widget _buildOffersSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 12, 13, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF152236),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 4, bottom: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Blu-Ray Offers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                _buildActionButton(
                  label: 'Add Blu-Ray',
                  icon: Icons.add,
                  onPressed: _openAddBluRay,
                ),
              ],
            ),
          ),

          _buildOffersContent(),
        ],
      ),
    );
  }

  Widget _buildOffersContent() {
    if (_isLoadingOffers) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_offersError != null) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 38),

              const SizedBox(height: 10),

              Text(
                _offersError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _loadBluRayOffers,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_offers.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No Blu-ray offers available.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: [
        ..._offers.map(
          (offer) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOfferCard(offer),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BLU-RAY OFFER CARD
  // ===========================================================================

  Widget _buildOfferCard(BluRayME offer) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 168,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF08111F),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOfferPoster(offer),

              const SizedBox(width: 17),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE5E7EB),
                        fontSize: 15,
                      ),
                    ),

                    const Spacer(),

                    _buildActionButton(
                      label: 'Edit',
                      icon: Icons.edit,
                      onPressed: () {
                        _openEditBluRay(offer.id);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 15),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5, right: 5),
                  child: Text(
                    '\$${offer.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ---------------------------------------------------------------------
        // DELETED BADGE
        // ---------------------------------------------------------------------
        if (offer.isDeleted)
          Positioned(
            top: -5,
            right: 17,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, color: Colors.white, size: 14),

                  SizedBox(width: 5),

                  Text(
                    'Deleted',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // BLU-RAY POSTER
  // ===========================================================================

  Widget _buildOfferPoster(BluRayME offer) {
    return Container(
      width: 108,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF17263A),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        offer.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.album_outlined, color: Colors.white38, size: 35),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // ACTION BUTTON
  // ===========================================================================

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 29,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF20334E),
          foregroundColor: const Color(0xFFE5E7EB),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
