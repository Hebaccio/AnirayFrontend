import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/user_cart_provider.dart';
import '../../requests_and_models/entity_r&m/bluray/bluray_models.dart';
import '../../requests_and_models/entity_r&m/user_cart/usercart_models.dart';

class DashboardCartScreen extends StatefulWidget {
  const DashboardCartScreen({super.key, required this.title});

  final String title;

  @override
  State<DashboardCartScreen> createState() => _DashboardCartScreenState();
}

class _DashboardCartScreenState extends State<DashboardCartScreen> {
  final UserCartProvider _userCartProvider = UserCartProvider();

  bool _isLoading = true;
  UserCartMU? _userCart;

  final TextEditingController _cartNotesController = TextEditingController();

  // Original cart notes received from the backend.
  //
  // Used to determine whether the notes have unsaved changes.
  String _originalCartNotes = '';

  // ---------------------------------------------------------------------------
  // CART ITEM STATE
  // ---------------------------------------------------------------------------

  // Current locally edited amounts.
  //
  // Key   = Blu-ray ID
  // Value = currently selected amount
  final Map<int, int> _cartAmounts = {};

  // Original amounts received from the backend.
  //
  // Used to determine whether an item has unsaved changes.
  final Map<int, int> _originalCartAmounts = {};

  // Blu-ray IDs currently being updated/removed.
  final Set<int> _updatingBluRayIds = {};

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadUserCart();
  }

  @override
  void dispose() {
    _cartNotesController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOAD USER CART
  // ---------------------------------------------------------------------------

  Future<void> _loadUserCart() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await _userCartProvider.entityGetByIdForUsers(null);

    if (!mounted) return;

    if (result.data != null) {
      final cart = result.data!;

      _cartAmounts.clear();
      _originalCartAmounts.clear();

      for (final item in cart.bluRay) {
        _cartAmounts[item.bluRay.id] = item.amount;
        _originalCartAmounts[item.bluRay.id] = item.amount;
      }

      _cartNotesController.text = cart.cartNotes;
      _originalCartNotes = cart.cartNotes;

      setState(() {
        _userCart = cart;
        _isLoading = false;
      });
    } else {
      setState(() {
        _userCart = null;
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // MAXIMUM AMOUNT
  // ---------------------------------------------------------------------------

  int _maximumCartAmount(BluRayMU bluRay) {
    if (bluRay.inStock <= 0) {
      return 0;
    }

    return bluRay.inStock > 5 ? 5 : bluRay.inStock;
  }

  // ---------------------------------------------------------------------------
  // CHANGE AMOUNT LOCALLY
  // ---------------------------------------------------------------------------

  void _decreaseAmount(BluRayMU bluRay) {
    final int currentAmount = _cartAmounts[bluRay.id] ?? 0;

    if (currentAmount <= 1) {
      return;
    }

    setState(() {
      _cartAmounts[bluRay.id] = currentAmount - 1;
    });
  }

  void _increaseAmount(BluRayMU bluRay) {
    final int currentAmount = _cartAmounts[bluRay.id] ?? 0;
    final int maximumAmount = _maximumCartAmount(bluRay);

    if (currentAmount >= maximumAmount) {
      return;
    }

    setState(() {
      _cartAmounts[bluRay.id] = currentAmount + 1;
    });
  }

  // ---------------------------------------------------------------------------
  // SAVE ALL CART CHANGES
  // ---------------------------------------------------------------------------

  Future<void> _saveAllCartChanges() async {
    if (_userCart == null || _updatingBluRayIds.isNotEmpty) {
      return;
    }

    final List<BluRayCartMU> changedItems = [];

    for (final item in _userCart!.bluRay) {
      final int bluRayId = item.bluRay.id;

      final int currentAmount = _cartAmounts[bluRayId] ?? item.amount;

      final int originalAmount = _originalCartAmounts[bluRayId] ?? item.amount;

      if (currentAmount != originalAmount) {
        changedItems.add(item);
      }
    }

    final String currentNotes = _cartNotesController.text.trim();

    final bool notesChanged = currentNotes != _originalCartNotes;

    if (changedItems.isEmpty && !notesChanged) {
      return;
    }

    // -------------------------------------------------------------------------
    // VALIDATE ALL QUANTITY CHANGES BEFORE SENDING ANY REQUESTS
    // -------------------------------------------------------------------------

    for (final item in changedItems) {
      final BluRayMU bluRay = item.bluRay;
      final int amount = _cartAmounts[bluRay.id] ?? item.amount;
      final int maximumAmount = _maximumCartAmount(bluRay);

      if (amount < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quantity for "${bluRay.title}" must be at least 1.'),
          ),
        );

        return;
      }

      if (maximumAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${bluRay.title}" is currently out of stock.'),
          ),
        );

        return;
      }

      if (amount > maximumAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Only $maximumAmount '
              '${maximumAmount == 1 ? 'copy is' : 'copies are'} available '
              'for "${bluRay.title}".',
            ),
          ),
        );

        return;
      }
    }

    // -------------------------------------------------------------------------
    // MARK CHANGED BLU-RAYS AS UPDATING
    // -------------------------------------------------------------------------

    setState(() {
      for (final item in changedItems) {
        _updatingBluRayIds.add(item.bluRay.id);
      }
    });

    bool allSucceeded = true;

    try {
      // -----------------------------------------------------------------------
      // SAVE BLU-RAY QUANTITY CHANGES
      //
      // The backend currently exposes individual Blu-ray cart updates, so
      // each changed Blu-ray is sent through that endpoint.
      // -----------------------------------------------------------------------

      for (final item in changedItems) {
        final BluRayMU bluRay = item.bluRay;
        final int amount = _cartAmounts[bluRay.id] ?? item.amount;

        final request = UserCartIndividualURU(
          bluRay: BluRayCartUR(bluRayId: bluRay.id, amount: amount),
        );

        final result = await _userCartProvider.updateIndividualBluRayInCart(
          request,
        );

        if (!mounted) return;

        if (result.data == true) {
          setState(() {
            _originalCartAmounts[bluRay.id] = amount;
          });
        } else {
          allSucceeded = false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.message ?? 'Failed to update "${bluRay.title}".',
              ),
            ),
          );
        }
      }

      // -----------------------------------------------------------------------
      // SAVE CART NOTES
      // -----------------------------------------------------------------------

      if (notesChanged) {
        final request = UserCartURU(
          cartNotes: currentNotes,

          // Keep the current cart quantities.
          bluRay: _userCart!.bluRay
              .map(
                (item) => BluRayCartUR(
                  bluRayId: item.bluRay.id,
                  amount: _cartAmounts[item.bluRay.id] ?? item.amount,
                ),
              )
              .toList(),
        );

        final result = await _userCartProvider.updateEntityForUsers(
          null,
          request,
        );

        if (!mounted) return;

        if (result.data != null) {
          final updatedCart = result.data!;

          setState(() {
            _userCart = updatedCart;
            _originalCartNotes = updatedCart.cartNotes;
            _cartNotesController.text = updatedCart.cartNotes;

            _cartAmounts.clear();
            _originalCartAmounts.clear();

            for (final item in updatedCart.bluRay) {
              _cartAmounts[item.bluRay.id] = item.amount;
              _originalCartAmounts[item.bluRay.id] = item.amount;
            }
          });
        } else {
          allSucceeded = false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to save cart notes.'),
            ),
          );
        }
      }

      // -----------------------------------------------------------------------
      // SUCCESS MESSAGE
      // -----------------------------------------------------------------------

      if (!mounted) return;

      if (allSucceeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart changes saved successfully.')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save cart changes.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          for (final item in changedItems) {
            _updatingBluRayIds.remove(item.bluRay.id);
          }
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CONFIRM REMOVE
  // ---------------------------------------------------------------------------

  Future<void> _confirmRemoveCartItem(BluRayMU bluRay) async {
    final int bluRayId = bluRay.id;

    if (_updatingBluRayIds.contains(bluRayId)) {
      return;
    }

    final bool? shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundSecondary,
          title: const Text(
            'Remove from cart?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Remove "${bluRay.title}" from your cart?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'REMOVE',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      await _removeCartItem(bluRay);
    }
  }

  // ---------------------------------------------------------------------------
  // REMOVE INDIVIDUAL CART ITEM
  // ---------------------------------------------------------------------------

  Future<void> _removeCartItem(BluRayMU bluRay) async {
    final int bluRayId = bluRay.id;

    if (_updatingBluRayIds.contains(bluRayId)) {
      return;
    }

    setState(() {
      _updatingBluRayIds.add(bluRayId);
    });

    try {
      final request = UserCartIndividualURU(
        bluRay: BluRayCartUR(bluRayId: bluRayId, amount: 0),
      );

      final result = await _userCartProvider.updateIndividualBluRayInCart(
        request,
      );

      if (!mounted) return;

      if (result.data == true) {
        setState(() {
          _userCart!.bluRay.removeWhere((item) => item.bluRay.id == bluRayId);

          _cartAmounts.remove(bluRayId);
          _originalCartAmounts.remove(bluRayId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${bluRay.title}" removed from cart.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to remove cart item.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove "${bluRay.title}" from cart.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingBluRayIds.remove(bluRayId);
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
      color: const Color(0xFF08111F),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userCart == null
          ? _buildErrorState()
          : _userCart!.bluRay.isEmpty
          ? _buildEmptyCart()
          : _buildCart(),
    );
  }

  // ---------------------------------------------------------------------------
  // SAVE ALL CHANGES BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildSaveAllChangesButton() {
    final bool hasChanges = _hasUnsavedCartChanges;
    final bool isUpdating = _updatingBluRayIds.isNotEmpty;

    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: !hasChanges || isUpdating ? null : _saveAllCartChanges,
        icon: isUpdating
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined, size: 16),
        label: Text(
          isUpdating ? 'SAVING...' : 'SAVE CHANGES',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.backgroundTertiary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.backgroundPrimary,
          disabledForegroundColor: Colors.white24,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CART
  // ---------------------------------------------------------------------------

  Widget _buildCart() {
    final cart = _userCart!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCartHeader(),

          const SizedBox(height: 22),

          // -------------------------------------------------------------------
          // ORDER SUMMARY
          // -------------------------------------------------------------------
          _buildSectionTitle('ORDER SUMMARY'),

          const SizedBox(height: 10),

          _buildCartSummary(cart),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // CART NOTES
          // -------------------------------------------------------------------
          _buildCartNotes(cart),

          const SizedBox(height: 24),

          // -------------------------------------------------------------------
          // YOUR CART HEADER
          // -------------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'YOUR CART',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildSaveAllChangesButton(),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.bluRay.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _buildCartItem(cart.bluRay[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CART HEADER
  // ---------------------------------------------------------------------------

  Widget _buildCartHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 15),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.backgroundSecondary),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 12),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CART SUMMARY
  // ---------------------------------------------------------------------------

  Widget _buildCartSummary(UserCartMU cart) {
    final int itemCount = cart.bluRay.fold(
      0,
      (total, item) => total + (_cartAmounts[item.bluRay.id] ?? item.amount),
    );

    final double total = cart.bluRay.fold(0.0, (total, item) {
      final int amount = _cartAmounts[item.bluRay.id] ?? item.amount;

      return total + (item.bluRay.price * amount);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.inventory_2_outlined,
              label: 'Items',
              value: '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.payments_outlined,
              label: 'Total',
              value: '${total.toStringAsFixed(2)} KM',
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY CARD
  // ---------------------------------------------------------------------------

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
  // CART NOTES
  // ---------------------------------------------------------------------------

  Widget _buildCartNotes(UserCartMU cart) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.sticky_note_2_outlined,
                  color: Colors.white70,
                  size: 22,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cart Notes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _cartNotesController,
              onChanged: (_) {
                setState(() {});
              },
              maxLines: 4,
              minLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add notes for your cart...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                filled: true,
                fillColor: AppColors.backgroundPrimary,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CART ITEM
  // ---------------------------------------------------------------------------

  Widget _buildCartItem(BluRayCartMU cartItem) {
    final BluRayMU bluRay = cartItem.bluRay;

    final int amount = _cartAmounts[bluRay.id] ?? cartItem.amount;

    final int originalAmount =
        _originalCartAmounts[bluRay.id] ?? cartItem.amount;

    final int maximumAmount = _maximumCartAmount(bluRay);

    final bool hasUnsavedChanges = amount != originalAmount;

    final bool isUpdating = _updatingBluRayIds.contains(bluRay.id);

    final double itemTotal = bluRay.price * amount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasUnsavedChanges
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPoster(bluRay),
          const SizedBox(width: 16),
          Expanded(
            child: _buildItemDetails(
              bluRay,
              amount,
              itemTotal,
              maximumAmount,
              hasUnsavedChanges,
              isUpdating,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // POSTER
  // ---------------------------------------------------------------------------

  Widget _buildPoster(BluRayMU bluRay) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        bluRay.image,
        width: 110,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 110,
            height: 160,
            color: AppColors.textPrimary,
            child: const Icon(
              Icons.movie_outlined,
              color: Colors.white38,
              size: 42,
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ITEM DETAILS
  // ---------------------------------------------------------------------------

  Widget _buildItemDetails(
    BluRayMU bluRay,
    int amount,
    double itemTotal,
    int maximumAmount,
    bool hasUnsavedChanges,
    bool isUpdating,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------------------
        // TITLE
        // ---------------------------------------------------------------------
        Text(
          bluRay.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        // ---------------------------------------------------------------------
        // STOCK
        // ---------------------------------------------------------------------
        _buildStockIndicator(bluRay.inStock),

        const SizedBox(height: 6),

        // ---------------------------------------------------------------------
        // PRICE
        // ---------------------------------------------------------------------
        _buildCartItemInfo('Price', '${bluRay.price.toStringAsFixed(2)} KM'),

        const SizedBox(height: 5),

        // ---------------------------------------------------------------------
        // FULL PRICE
        // ---------------------------------------------------------------------
        _buildCartItemInfo('Full price', '${itemTotal.toStringAsFixed(2)} KM'),

        const SizedBox(height: 12),

        // ---------------------------------------------------------------------
        // QUANTITY + REMOVE
        // ---------------------------------------------------------------------
        Row(
          children: [
            Expanded(
              child: _buildQuantityControls(
                bluRay,
                amount,
                maximumAmount,
                isUpdating,
              ),
            ),
            const SizedBox(width: 8),
            _buildRemoveButton(bluRay, isUpdating),
          ],
        ),

        // ---------------------------------------------------------------------
        // UNSAVED INDICATOR
        // ---------------------------------------------------------------------
        if (hasUnsavedChanges) ...[
          const SizedBox(height: 7),
          const Row(
            children: [
              Icon(Icons.circle, size: 6, color: Colors.amberAccent),
              SizedBox(width: 6),
              Text(
                'Unsaved changes',
                style: TextStyle(color: Colors.amberAccent, fontSize: 11),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // QUANTITY CONTROLS
  // ---------------------------------------------------------------------------

  Widget _buildQuantityControls(
    BluRayMU bluRay,
    int amount,
    int maximumAmount,
    bool isUpdating,
  ) {
    final bool canDecrease = amount > 1 && !isUpdating;

    final bool canIncrease = amount < maximumAmount && !isUpdating;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // -------------------------------------------------------------------
          // DECREASE
          // -------------------------------------------------------------------
          _buildQuantityButton(
            icon: Icons.remove,
            enabled: canDecrease,
            onPressed: canDecrease ? () => _decreaseAmount(bluRay) : null,
          ),

          const SizedBox(width: 8),

          // -------------------------------------------------------------------
          // AMOUNT
          // -------------------------------------------------------------------
          Expanded(
            child: Center(
              child: isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      amount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 8),

          // -------------------------------------------------------------------
          // INCREASE
          // -------------------------------------------------------------------
          _buildQuantityButton(
            icon: Icons.add,
            enabled: canIncrease,
            onPressed: canIncrease ? () => _increaseAmount(bluRay) : null,
          ),

          const SizedBox(width: 8),

          // -------------------------------------------------------------------
          // MAXIMUM
          // -------------------------------------------------------------------
          Text(
            '/ $maximumAmount',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // QUANTITY BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildQuantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.white : Colors.white24,
        ),
        style: IconButton.styleFrom(
          backgroundColor: enabled
              ? AppColors.backgroundSecondary
              : AppColors.backgroundSecondary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CHECK FOR UNSAVED CHANGES
  // ---------------------------------------------------------------------------

  bool get _hasUnsavedCartChanges {
    if (_userCart == null) {
      return false;
    }

    // -------------------------------------------------------------------------
    // CHECK BLU-RAY QUANTITY CHANGES
    // -------------------------------------------------------------------------

    for (final item in _userCart!.bluRay) {
      final int bluRayId = item.bluRay.id;

      final int currentAmount = _cartAmounts[bluRayId] ?? item.amount;

      final int originalAmount = _originalCartAmounts[bluRayId] ?? item.amount;

      if (currentAmount != originalAmount) {
        return true;
      }
    }

    // -------------------------------------------------------------------------
    // CHECK CART NOTES CHANGES
    // -------------------------------------------------------------------------

    final String currentNotes = _cartNotesController.text.trim();

    if (currentNotes != _originalCartNotes) {
      return true;
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // REMOVE BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildRemoveButton(BluRayMU bluRay, bool isUpdating) {
    return SizedBox(
      height: 34,
      width: 38,
      child: OutlinedButton(
        onPressed: isUpdating ? null : () => _confirmRemoveCartItem(bluRay),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          disabledForegroundColor: Colors.redAccent.withValues(alpha: 0.25),
          padding: EdgeInsets.zero,
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: const Icon(Icons.delete_outline, size: 17),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CART ITEM INFO
  // ---------------------------------------------------------------------------

  Widget _buildCartItemInfo(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STOCK INDICATOR
  // ---------------------------------------------------------------------------

  Widget _buildStockIndicator(int stock) {
    final bool inStock = stock > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: inStock ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          inStock ? '$stock in stock' : 'Out of stock',
          style: TextStyle(
            color: inStock ? Colors.white54 : Colors.redAccent,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY CART
  // ---------------------------------------------------------------------------

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some Blu-rays to your cart to see them here.',
            style: TextStyle(color: Colors.white54, fontSize: 15),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'Unable to load cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserCart,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
