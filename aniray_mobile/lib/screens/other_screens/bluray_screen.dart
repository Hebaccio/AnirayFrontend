import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/bluray_provider.dart';
import '../../providers/entity_providers/user_cart_provider.dart';
import '../../requests_and_models/entity_r&m/bluray/bluray_models.dart';
import '../../requests_and_models/entity_r&m/user_cart/usercart_models.dart';

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
  // PROVIDERS
  // ---------------------------------------------------------------------------

  final BluRayProvider _bluRayProvider = BluRayProvider();
  final UserCartProvider _userCartProvider = UserCartProvider();

  // ---------------------------------------------------------------------------
  // BLU-RAY
  // ---------------------------------------------------------------------------

  BluRayMU? _bluRay;

  // ---------------------------------------------------------------------------
  // USER CART
  // ---------------------------------------------------------------------------

  UserCartIsBluRayInCart? _userCartItem;

  // Original amount currently saved on the server.
  int? _originalCartAmount;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  bool _isLoading = true;
  bool _isCartUpdating = false;

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
      final bluRayResult = await _bluRayProvider.entityGetByIdForUsers(
        widget.blurayId,
      );

      if (!mounted) {
        return;
      }

      if (bluRayResult.statusCode != null &&
          bluRayResult.statusCode! >= 200 &&
          bluRayResult.statusCode! < 300 &&
          bluRayResult.data != null) {
        setState(() {
          _bluRay = bluRayResult.data;
          _isLoading = false;
        });

        // Check cart separately.
        _loadCartInformation();
      } else {
        setState(() {
          _bluRay = null;
          _userCartItem = null;
          _originalCartAmount = null;
          _errorMessage =
              bluRayResult.message ?? "Failed to load Blu-ray information.";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _bluRay = null;
        _userCartItem = null;
        _originalCartAmount = null;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD CART INFORMATION
  // ---------------------------------------------------------------------------

  Future<void> _loadCartInformation() async {
    try {
      final result = await _userCartProvider.isBluRayInCartForUsers(
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
          _userCartItem = result.data;
          _originalCartAmount = result.data!.amount.toInt();
        });
      } else {
        setState(() {
          _userCartItem = null;
          _originalCartAmount = null;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _userCartItem = null;
        _originalCartAmount = null;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // ADD TO CART
  // ---------------------------------------------------------------------------

  Future<void> _addToCart() async {
    if (_isCartUpdating) {
      return;
    }

    setState(() {
      _isCartUpdating = true;
    });

    try {
      final request = UserCartIndividualURU(
        bluRay: BluRayCartUR(bluRayId: widget.blurayId, amount: 1),
      );

      final result = await _userCartProvider.updateIndividualBluRayInCart(
        request,
      );

      if (!mounted) {
        return;
      }

      if (result.data == true) {
        await _loadCartInformation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to add Blu-ray to cart.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add Blu-ray to cart.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCartUpdating = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CHANGE CART AMOUNT LOCALLY
  // ---------------------------------------------------------------------------

  void _decreaseCartAmount() {
    final currentAmount = _userCartItem?.amount.toInt() ?? 0;

    if (currentAmount <= 1) {
      return;
    }

    setState(() {
      _userCartItem = UserCartIsBluRayInCart(
        userCartId: _userCartItem!.userCartId,
        bluRayId: _userCartItem!.bluRayId,
        amount: (currentAmount - 1).toDouble(),
      );
    });
  }

  void _increaseCartAmount() {
    final currentAmount = _userCartItem?.amount.toInt() ?? 0;
    final availableAmount = _bluRay?.inStock ?? 0;

    final maximumAmount = availableAmount > 5 ? 5 : availableAmount;

    if (currentAmount >= maximumAmount) {
      return;
    }

    setState(() {
      _userCartItem = UserCartIsBluRayInCart(
        userCartId: _userCartItem!.userCartId,
        bluRayId: _userCartItem!.bluRayId,
        amount: (currentAmount + 1).toDouble(),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // SAVE CART CHANGES
  // ---------------------------------------------------------------------------

  Future<void> _saveCartChanges() async {
    if (_isCartUpdating || _userCartItem == null) {
      return;
    }

    final amount = _userCartItem!.amount.toInt();

    if (amount == _originalCartAmount) {
      return;
    }

    setState(() {
      _isCartUpdating = true;
    });

    try {
      final request = UserCartIndividualURU(
        bluRay: BluRayCartUR(bluRayId: widget.blurayId, amount: amount),
      );

      final result = await _userCartProvider.updateIndividualBluRayInCart(
        request,
      );

      if (!mounted) {
        return;
      }

      if (result.data == true) {
        setState(() {
          _originalCartAmount = amount;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cart changes saved.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to save cart changes.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save cart changes.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCartUpdating = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // REMOVE FROM CART
  // ---------------------------------------------------------------------------

  Future<void> _removeFromCart() async {
    if (_isCartUpdating) {
      return;
    }

    setState(() {
      _isCartUpdating = true;
    });

    try {
      final request = UserCartIndividualURU(
        bluRay: BluRayCartUR(bluRayId: widget.blurayId, amount: 0),
      );

      final result = await _userCartProvider.updateIndividualBluRayInCart(
        request,
      );

      if (!mounted) {
        return;
      }

      if (result.data == true) {
        setState(() {
          _userCartItem = null;
          _originalCartAmount = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blu-ray removed from cart.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ?? 'Failed to remove Blu-ray from cart.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove Blu-ray from cart.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCartUpdating = false;
        });
      }
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
    final bool isInCart = _userCartItem != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // -----------------------------------------------------------------
              // PRICE
              // -----------------------------------------------------------------
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

              // -----------------------------------------------------------------
              // STOCK STATUS
              // -----------------------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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

          const SizedBox(height: 14),

          // ---------------------------------------------------------------------
          // CART CONTROLS
          // ---------------------------------------------------------------------
          _buildCartControls(isInCart),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CART CONTROLS
  // ---------------------------------------------------------------------------

  Widget _buildCartControls(bool isInCart) {
    // -------------------------------------------------------------------------
    // NOT IN CART
    // -------------------------------------------------------------------------

    if (!isInCart) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _isCartUpdating || (_bluRay?.inStock ?? 0) <= 0
              ? null
              : _addToCart,
          icon: _isCartUpdating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                )
              : const Icon(Icons.shopping_cart_outlined, size: 19),
          label: Text(
            _isCartUpdating ? "ADDING..." : "ADD TO CART",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.backgroundTertiary,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: AppColors.backgroundTertiary.withOpacity(
              0.5,
            ),
            disabledForegroundColor: AppColors.textSecondary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // IN CART
    // -------------------------------------------------------------------------

    final int amount = _userCartItem!.amount.toInt();

    final int availableAmount = _bluRay?.inStock ?? 0;

    final int maximumAmount = availableAmount > 5 ? 5 : availableAmount;

    final bool hasUnsavedChanges = amount != _originalCartAmount;

    return Column(
      children: [
        // -----------------------------------------------------------------------
        // QUANTITY
        // -----------------------------------------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // -----------------------------------------------------------------
              // CART ICON
              // -----------------------------------------------------------------
              const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textPrimary,
                size: 20,
              ),

              const SizedBox(width: 10),

              // -----------------------------------------------------------------
              // CART TEXT
              // -----------------------------------------------------------------
              const Expanded(
                child: Text(
                  "In your cart",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // -----------------------------------------------------------------
              // DECREASE
              // -----------------------------------------------------------------
              _buildQuantityButton(
                icon: Icons.remove,
                onPressed: _isCartUpdating || amount <= 1
                    ? null
                    : _decreaseCartAmount,
              ),

              const SizedBox(width: 10),

              // -----------------------------------------------------------------
              // AMOUNT
              // -----------------------------------------------------------------
              SizedBox(
                width: 25,
                child: Center(
                  child: Text(
                    amount.toString(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // -----------------------------------------------------------------
              // INCREASE
              // -----------------------------------------------------------------
              _buildQuantityButton(
                icon: Icons.add,
                onPressed: _isCartUpdating || amount >= maximumAmount
                    ? null
                    : _increaseCartAmount,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // -----------------------------------------------------------------------
        // SAVE CHANGES
        // -----------------------------------------------------------------------
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton.icon(
            onPressed: _isCartUpdating || !hasUnsavedChanges
                ? null
                : _saveCartChanges,
            icon: _isCartUpdating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(
              _isCartUpdating ? "SAVING..." : "SAVE CHANGES",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.backgroundTertiary,
              foregroundColor: AppColors.textPrimary,
              disabledBackgroundColor: AppColors.backgroundTertiary.withOpacity(
                0.4,
              ),
              disabledForegroundColor: AppColors.textSecondary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // -----------------------------------------------------------------------
        // REMOVE FROM CART
        // -----------------------------------------------------------------------
        SizedBox(
          width: double.infinity,
          height: 45,
          child: OutlinedButton.icon(
            onPressed: _isCartUpdating ? null : _removeFromCart,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text(
              "REMOVE FROM CART",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textError,
              side: BorderSide(color: AppColors.textError.withOpacity(0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // QUANTITY BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 18,
          color: onPressed == null
              ? AppColors.textSecondary
              : AppColors.textPrimary,
        ),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.backgroundSecondary,
          disabledBackgroundColor: AppColors.backgroundSecondary.withOpacity(
            0.4,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
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
