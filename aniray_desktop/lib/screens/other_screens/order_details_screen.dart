import 'package:aniray_desktop/models/basic_entities/basic_entities.dart';
import 'package:aniray_desktop/models/bluray/bluray_models.dart';
import 'package:aniray_desktop/models/order/order_models.dart';
import 'package:aniray_desktop/providers/api_result.dart';
import 'package:aniray_desktop/providers/entity_providers/order_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/order_status_provider.dart';
import 'package:aniray_desktop/requests/paged_result.dart';
import 'package:aniray_desktop/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.onBack,
  });

  final int orderId;
  final VoidCallback onBack;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // ===========================================================================
  // PROVIDERS
  // ===========================================================================

  final OrderProvider _orderProvider = OrderProvider();

  final OrderStatusProvider _orderStatusProvider = OrderStatusProvider();

  // ===========================================================================
  // ORDER STATE
  // ===========================================================================

  OrderME? _order;

  bool _isLoadingOrder = true;
  String? _orderError;

  // ===========================================================================
  // STATUS STATE
  // ===========================================================================

  List<BaseClass> _orderStatuses = [];

  bool _isLoadingStatuses = true;
  String? _statusError;

  int? _selectedStatusId;

  bool _isSavingStatus = false;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _loadOrder();
    _loadOrderStatuses();
  }

  // ===========================================================================
  // LOAD ORDER
  // ===========================================================================

  Future<void> _loadOrder() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingOrder = true;
      _orderError = null;
    });

    final ApiResult<OrderME> result = await _orderProvider
        .entityGetByIdForEmployees(widget.orderId);

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      setState(() {
        _order = result.data;
        _selectedStatusId = result.data!.orderStatus.id;

        _isLoadingOrder = false;
        _orderError = null;
      });
    } else {
      setState(() {
        _order = null;

        _isLoadingOrder = false;
        _orderError = result.message ?? 'Failed to load order.';
      });
    }
  }

  // ===========================================================================
  // LOAD ORDER STATUSES
  // ===========================================================================

  Future<void> _loadOrderStatuses() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingStatuses = true;
      _statusError = null;
    });

    final ApiResult<PagedResult<BaseClassME>> result =
        await _orderStatusProvider.getPagedEntityForEmployees(
          const BaseClassSOE(page: 0, pageSize: 100, isDeleted: false),
        );

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      final List<BaseClass> statuses = result.data!.resultList
          .map(
            (status) => BaseClass(
              id: status.id,
              name: status.name,
              isDeleted: status.isDeleted,
            ),
          )
          .toList();

      setState(() {
        _orderStatuses = statuses;
        _isLoadingStatuses = false;
        _statusError = null;
      });
    } else {
      setState(() {
        _orderStatuses = [];
        _isLoadingStatuses = false;
        _statusError = result.message ?? 'Failed to load order statuses.';
      });
    }
  }

  // ===========================================================================
  // UPDATE STATUS
  // ===========================================================================

  Future<void> _updateStatus() async {
    final OrderME? order = _order;

    if (order == null || _selectedStatusId == null) {
      return;
    }

    if (_selectedStatusId == order.orderStatus.id) {
      return;
    }

    if (_isSavingStatus) {
      return;
    }

    setState(() {
      _isSavingStatus = true;
    });

    final OrderURE request = OrderURE(orderStatusId: _selectedStatusId!);

    final ApiResult<OrderME> result = await _orderProvider
        .updateEntityForEmployees(order.id, request);

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      setState(() {
        _order = result.data;
        _selectedStatusId = result.data!.orderStatus.id;
        _isSavingStatus = false;
      });

      _showSnackBar('Order status updated successfully.', isError: false);
    } else {
      setState(() {
        _isSavingStatus = false;
      });

      _showSnackBar(
        result.message ?? 'Failed to update order status.',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // SNACKBAR
  // ===========================================================================

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? AppColors.textError
              : AppColors.backgroundTertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.backgroundPrimary,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),

            const SizedBox(height: 20),

            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP BAR
  // ===========================================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 48, right: 48),
      child: Row(
        children: [
          _buildBackButton(),

          const SizedBox(width: 18),

          Expanded(child: _buildTitle()),

          if (_order != null) _buildStatusControl(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _isSavingStatus ? null : widget.onBack,
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    if (_order == null) {
      return const Text(
        'Order Details',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 25,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order #${_order!.id}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          _formatDateTime(_order!.dateTime),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  // ===========================================================================
  // STATUS CONTROL
  // ===========================================================================

  Widget _buildStatusControl() {
    final OrderME order = _order!;

    final bool hasChanges =
        _selectedStatusId != null && _selectedStatusId != order.orderStatus.id;

    return Row(
      children: [
        SizedBox(width: 220, height: 48, child: _buildStatusDropdown()),

        const SizedBox(width: 10),

        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isSavingStatus || !hasChanges ? null : _updateStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.backgroundTertiary,
              disabledBackgroundColor: AppColors.backgroundFourth,
              foregroundColor: AppColors.textPrimary,
              disabledForegroundColor: AppColors.textSecondary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: _isSavingStatus
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(_isSavingStatus ? 'Saving...' : 'Save Status'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    if (_isLoadingStatuses) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: const Row(
          children: [
            SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(width: 10),

            Text(
              'Loading statuses...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_statusError != null && _orderStatuses.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.textSecondary,
              size: 18,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                'Status unavailable',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),

            IconButton(
              onPressed: _loadOrderStatuses,
              icon: const Icon(
                Icons.refresh,
                color: AppColors.textPrimary,
                size: 19,
              ),
            ),
          ],
        ),
      );
    }

    final bool valueExists =
        _selectedStatusId == null ||
        _orderStatuses.any((status) => status.id == _selectedStatusId);

    return DropdownButtonFormField<int>(
      initialValue: valueExists ? _selectedStatusId : null,
      dropdownColor: AppColors.backgroundSecondary,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Order Status',
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.info_outline,
          color: AppColors.textSecondary,
          size: 19,
        ),
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.backgroundTertiary),
        ),
      ),
      items: _orderStatuses.map((status) {
        return DropdownMenuItem<int>(
          value: status.id,
          child: Text(status.name, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: _isSavingStatus
          ? null
          : (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedStatusId = value;
              });
            },
    );
  }

  // ===========================================================================
  // CONTENT
  // ===========================================================================

  Widget _buildContent() {
    if (_isLoadingOrder) {
      return _buildLoadingState();
    }

    if (_orderError != null) {
      return _buildErrorState();
    }

    if (_order == null) {
      return _buildErrorState(message: 'Order could not be loaded.');
    }

    return _buildOrderContent(_order!);
  }

  // ===========================================================================
  // ORDER CONTENT
  // ===========================================================================

  Widget _buildOrderContent(OrderME order) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 48, right: 48, bottom: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              _buildSummaryCard(order),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildCustomerCard(order),

                        const SizedBox(height: 18),

                        _buildDeliveryCard(order),

                        const SizedBox(height: 18),

                        _buildNotesCard(order),
                      ],
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(flex: 7, child: _buildItemsCard(order)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ===========================================================================
  // SUMMARY
  // ===========================================================================

  Widget _buildSummaryCard(OrderME order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSummaryItem(
            icon: Icons.receipt_long_outlined,
            label: 'Order',
            value: '#${order.id}',
          ),

          _buildSummaryDivider(),

          _buildSummaryItem(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _formatDate(order.dateTime),
          ),

          _buildSummaryDivider(),

          _buildSummaryItem(
            icon: Icons.inventory_2_outlined,
            label: 'Items',
            value: '${_totalItems(order)}',
          ),

          _buildSummaryDivider(),

          _buildSummaryItem(
            icon: Icons.payments_outlined,
            label: 'Total',
            value: _formatPrice(order.fullPrice),
            emphasized: true,
          ),

          _buildSummaryDivider(),

          _buildSummaryItem(
            icon: Icons.info_outline,
            label: 'Status',
            value: order.orderStatus.name,
            emphasized: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    bool emphasized = false,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 21),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: emphasized ? 17 : 15,
                    fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: const Color(0xFF17263A),
    );
  }

  // ===========================================================================
  // CUSTOMER
  // ===========================================================================

  Widget _buildCustomerCard(OrderME order) {
    return _buildCard(
      title: 'Customer',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Name',
            value: order.userName,
            icon: Icons.person_outline,
          ),

          _buildInfoRow(
            label: 'Email',
            value: order.userMail,
            icon: Icons.email_outlined,
          ),

          _buildInfoRow(
            label: 'Phone',
            value: order.userPhone,
            icon: Icons.phone_outlined,
          ),

          _buildInfoRow(
            label: 'User ID',
            value: '#${order.userId}',
            icon: Icons.badge_outlined,
            bottomPadding: 0,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DELIVERY
  // ===========================================================================

  Widget _buildDeliveryCard(OrderME order) {
    return _buildCard(
      title: 'Delivery Information',
      icon: Icons.local_shipping_outlined,
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Country',
            value: order.userCountry,
            icon: Icons.public,
          ),

          _buildInfoRow(
            label: 'City',
            value: order.userCity,
            icon: Icons.location_city_outlined,
          ),

          _buildInfoRow(
            label: 'ZIP',
            value: order.userZIP,
            icon: Icons.markunread_mailbox_outlined,
          ),

          _buildInfoRow(
            label: 'Address',
            value: order.userAdress,
            icon: Icons.home_outlined,
            bottomPadding: 0,
          ),
        ],
      ),
    );
  }
  // ===========================================================================
  // CUSTOMER NOTES
  // ===========================================================================

  Widget _buildNotesCard(OrderME order) {
    final bool hasNotes = order.userNotes.trim().isNotEmpty;

    return _buildCard(
      title: 'Customer Notes',
      icon: Icons.notes_outlined,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundFourth,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.backgroundTertiary),
        ),
        child: Text(
          hasNotes ? order.userNotes : 'No notes provided.',
          style: TextStyle(
            color: hasNotes ? const Color(0xFFE5E7EB) : AppColors.textSecondary,
            fontSize: 13,
            height: 1.45,
            fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ORDER ITEMS
  // ===========================================================================

  Widget _buildItemsCard(OrderME order) {
    return _buildCard(
      title: 'Order Items',
      icon: Icons.inventory_2_outlined,
      child: order.bluRay.isEmpty
          ? _buildEmptyItems()
          : Column(
              children: [
                ...order.bluRay.asMap().entries.map((entry) {
                  return _buildBluRayItem(
                    entry.value,
                    isLast: entry.key == order.bluRay.length - 1,
                  );
                }),

                const SizedBox(height: 16),

                _buildOrderTotal(order),
              ],
            ),
    );
  }

  // ===========================================================================
  // BLU-RAY ITEM
  // ===========================================================================

  Widget _buildBluRayItem(OrderBluRayME item, {required bool isLast}) {
    final BluRayME bluRay = item.bluRay;

    final double itemTotal = bluRay.price * item.amount;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF17263A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // IMAGE
          // -------------------------------------------------------------------
          _buildBluRayImage(bluRay.image),

          const SizedBox(width: 15),

          // -------------------------------------------------------------------
          // NAME + QUANTITY
          // -------------------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bluRay.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.textSecondary,
                      size: 15,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      'Quantity: ${item.amount}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // -------------------------------------------------------------------
          // PRICE
          // -------------------------------------------------------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(itemTotal),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                '${_formatPrice(bluRay.price)} × ${item.amount}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BLU-RAY IMAGE
  // ===========================================================================

  Widget _buildBluRayImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Image.network(
        imageUrl,
        width: 78,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 78,
            height: 110,
            color: AppColors.backgroundFourth,
            child: const Icon(
              Icons.movie_outlined,
              color: AppColors.textSecondary,
              size: 30,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: 78,
            height: 110,
            color: AppColors.backgroundFourth,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // ORDER TOTAL
  // ===========================================================================

  Widget _buildOrderTotal(OrderME order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF17263A))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'Order Total',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),

          const SizedBox(width: 18),

          Text(
            _formatPrice(order.fullPrice),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY ITEMS
  // ===========================================================================

  Widget _buildEmptyItems() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: Color(0xFF7E8795), size: 40),

          SizedBox(height: 10),

          Text(
            'No Blu-ray items in this order.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // GENERIC CARD
  // ===========================================================================

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 21),

              const SizedBox(width: 9),

              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }

  // ===========================================================================
  // INFO ROW
  // ===========================================================================

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    double bottomPadding = 10,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),

          const SizedBox(width: 10),

          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // LOADING
  // ===========================================================================

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.textPrimary),
    );
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  Widget _buildErrorState({String? message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 50),

          const SizedBox(height: 15),

          Text(
            message ?? _orderError ?? 'Failed to load order.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: _loadOrder,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  int _totalItems(OrderME order) {
    return order.bluRay.fold(0, (total, item) => total + item.amount);
  }

  String _formatPrice(double value) {
    return '${value.toStringAsFixed(2)} KM';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
