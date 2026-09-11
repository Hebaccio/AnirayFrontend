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

  @override
  void initState() {
    super.initState();
    _loadUserCart();
  }

  // ---------------------------------------------------------------------------
  // LOAD USER CART
  // ---------------------------------------------------------------------------

  Future<void> _loadUserCart() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _userCartProvider.entityGetByIdForUsers(null);

    if (!mounted) return;

    if (result.data != null) {
      setState(() {
        _userCart = result.data;
        _isLoading = false;
      });
    } else {
      setState(() {
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
  // CART
  // ---------------------------------------------------------------------------

  Widget _buildCart() {
    final cart = _userCart!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCartHeader(cart),
        const SizedBox(height: 16),
        _buildCartNotes(cart),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: cart.bluRay.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _buildCartItem(cart.bluRay[index]);
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CART HEADER
  // ---------------------------------------------------------------------------

  Widget _buildCartHeader(UserCartMU cart) {
    final int itemCount = cart.bluRay.fold(
      0,
      (total, item) => total + item.amount,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
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
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '${cart.fullCartPrice.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CART NOTES
  // ---------------------------------------------------------------------------

  Widget _buildCartNotes(UserCartMU cart) {
    final bool hasNotes = cart.cartNotes.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              color: hasNotes ? Colors.white : Colors.white38,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cart Notes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hasNotes ? cart.cartNotes : 'No notes added.',
                    style: TextStyle(
                      color: hasNotes ? Colors.white70 : Colors.white38,
                      fontSize: 14,
                      height: 1.4,
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
  // CART ITEM
  // ---------------------------------------------------------------------------

  Widget _buildCartItem(BluRayCartMU cartItem) {
    final BluRayMU bluRay = cartItem.bluRay;

    final double itemTotal = bluRay.price * cartItem.amount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPoster(bluRay),
          const SizedBox(width: 16),
          Expanded(
            child: _buildItemDetails(bluRay, cartItem.amount, itemTotal),
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

  Widget _buildItemDetails(BluRayMU bluRay, int amount, double itemTotal) {
    return SizedBox(
      height: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------------
          // TITLE
          // ---------------------------------------------------------------
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

          // ---------------------------------------------------------------
          // STOCK
          // ---------------------------------------------------------------
          _buildStockIndicator(bluRay.inStock),

          const SizedBox(height: 6),

          // ---------------------------------------------------------------
          // PRICE
          // ---------------------------------------------------------------
          _buildCartItemInfo('Price', '${bluRay.price.toStringAsFixed(2)} KM'),
          const SizedBox(height: 5),

          // ---------------------------------------------------------------
          // FULL PRICE
          // ---------------------------------------------------------------
          _buildCartItemInfo(
            'Full price',
            '${itemTotal.toStringAsFixed(2)} KM',
          ),
          const Spacer(),

          // ---------------------------------------------------------------
          // QUANTITY
          // ---------------------------------------------------------------
          Row(children: [const Spacer(), _buildQuantityDisplay(amount)]),
        ],
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
  // INFO CHIP
  // ---------------------------------------------------------------------------

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white54),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
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
  // QUANTITY DISPLAY
  // ---------------------------------------------------------------------------

  Widget _buildQuantityDisplay(int amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '× $amount',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
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
