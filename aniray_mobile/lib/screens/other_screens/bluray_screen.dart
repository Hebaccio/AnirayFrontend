import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/bluray_provider.dart';
import '../../requests_and_models/entity_r&m/bluray/bluray_models.dart';

class BluRayScreen extends StatefulWidget {
  const BluRayScreen({
    super.key,
    required this.title,
    required this.blurayId,
    required this.onBack,
  });

  final String title;
  final int blurayId;
  final VoidCallback onBack;

  @override
  State<BluRayScreen> createState() => _BluRayScreenState();
}

class _BluRayScreenState extends State<BluRayScreen> {
  // ---------------------------------------------------------------------------
  // PROVIDER
  // ---------------------------------------------------------------------------

  final BluRayProvider _bluRayProvider = BluRayProvider();

  // ---------------------------------------------------------------------------
  // BLU-RAY
  // ---------------------------------------------------------------------------

  BluRayMU? _bluRay;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  bool _isLoading = true;
  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _loadBluRay();
  }

  // ---------------------------------------------------------------------------
  // LOAD BLU-RAY
  // ---------------------------------------------------------------------------

  Future<void> _loadBluRay() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _bluRayProvider.entityGetByIdForUsers(
        widget.blurayId,
      );

      if (!mounted) {
        return;
      }

      if (result.statusCode != null &&
          result.statusCode! >= 200 &&
          result.statusCode! < 300 &&
          result.data != null) {
        setState(() {
          _bluRay = result.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _bluRay = null;
          _errorMessage =
              result.message ?? "Failed to load Blu-ray information.";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _bluRay = null;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
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
          // -------------------------------------------------------------------
          // BACK BUTTON
          // -------------------------------------------------------------------
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),

          const SizedBox(width: 4),

          // -------------------------------------------------------------------
          // BACK TEXT
          // -------------------------------------------------------------------
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

    if (_errorMessage != null || _bluRay == null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadBluRay,
      color: AppColors.backgroundTertiary,
      backgroundColor: AppColors.backgroundSecondary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBluRayHeader(),

            const SizedBox(height: 24),

            _buildDescription(),

            const SizedBox(height: 28),

            _buildTechnicalInformation(),

            const SizedBox(height: 28),

            _buildPriceSection(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BLU-RAY HEADER
  // ---------------------------------------------------------------------------

  Widget _buildBluRayHeader() {
    final bluRay = _bluRay!;

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
                bluRay.image,
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
        // BLU-RAY INFORMATION
        // ---------------------------------------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bluRay.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
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
    final bluRay = _bluRay!;

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

        Text(
          bluRay.description.trim().isEmpty
              ? "No description available."
              : bluRay.description,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TECHNICAL INFORMATION
  // ---------------------------------------------------------------------------

  Widget _buildTechnicalInformation() {
    final bluRay = _bluRay!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Blu-ray Information",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _buildTechnicalRow(
                icon: Icons.calendar_today_outlined,
                label: "Release Date",
                value: _formatDate(bluRay.releaseDate),
              ),

              _buildDivider(),

              _buildTechnicalRow(
                icon: Icons.high_quality_outlined,
                label: "Video Format",
                value: bluRay.videoFormat.name,
              ),

              _buildDivider(),

              _buildTechnicalRow(
                icon: Icons.audiotrack_outlined,
                label: "Audio Format",
                value: bluRay.audioFormat.name,
              ),

              _buildDivider(),

              _buildTechnicalRow(
                icon: Icons.album_outlined,
                label: "Disc Count",
                value: bluRay.discCount.toString(),
              ),

              _buildDivider(),

              _buildTechnicalRow(
                icon: Icons.timer_outlined,
                label: "Runtime",
                value: "${bluRay.runtime} minutes",
              ),

              _buildDivider(),

              _buildTechnicalRow(
                icon: Icons.subtitles_outlined,
                label: "Subtitle Language",
                value: bluRay.subtitleLanguage,
              ),

              _buildDivider(),

              _buildTechnicalRow(
                icon: bluRay.inStock > 0
                    ? Icons.inventory_2_outlined
                    : Icons.remove_shopping_cart_outlined,
                label: "Availability",
                value: bluRay.inStock > 0
                    ? "${bluRay.inStock} in stock"
                    : "Out of stock",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TECHNICAL ROW
  // ---------------------------------------------------------------------------

  Widget _buildTechnicalRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 19),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DIVIDER
  // ---------------------------------------------------------------------------

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: AppColors.backgroundTertiary.withOpacity(0.5),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRICE
  // ---------------------------------------------------------------------------

  Widget _buildPriceSection() {
    final bluRay = _bluRay!;

    final bool isOutOfStock = bluRay.inStock <= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // -------------------------------------------------------------------
          // PRICE
          // -------------------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Price",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${bluRay.price.toStringAsFixed(2)} KM",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // STOCK STATUS
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isOutOfStock
                  ? AppColors.backgroundTertiary.withOpacity(0.4)
                  : AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOutOfStock
                      ? Icons.remove_shopping_cart_outlined
                      : Icons.shopping_bag_outlined,
                  color: isOutOfStock
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  size: 17,
                ),

                const SizedBox(width: 7),

                Text(
                  isOutOfStock ? "Out of stock" : "Available",
                  style: TextStyle(
                    color: isOutOfStock
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
              "Unable to load Blu-ray",
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
              onPressed: _loadBluRay,
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
  // IMAGE PLACEHOLDER
  // ---------------------------------------------------------------------------

  Widget _buildImagePlaceholder({required double iconSize}) {
    return Container(
      color: AppColors.backgroundTertiary,
      child: Center(
        child: Icon(
          Icons.album_outlined,
          color: AppColors.textSecondary,
          size: iconSize,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGE LOADING
  // ---------------------------------------------------------------------------

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
