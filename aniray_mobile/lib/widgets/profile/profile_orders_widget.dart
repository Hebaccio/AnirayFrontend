import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/order_provider.dart';
import '../../requests_and_models/entity_r&m/order/order_models.dart';
import '../../requests_and_models/helper_r&m/api_result_helpers/api_result.dart';
import '../../requests_and_models/helper_r&m/paged_result/paged_result.dart';

// =============================================================================
// PROFILE ORDERS WIDGET
// =============================================================================

class ProfileOrdersWidget extends StatefulWidget {
  const ProfileOrdersWidget({super.key, this.onOrdersLoaded});

  final VoidCallback? onOrdersLoaded;

  @override
  State<ProfileOrdersWidget> createState() => ProfileOrdersWidgetState();
}

// =============================================================================
// PROFILE ORDERS WIDGET STATE
// =============================================================================

class ProfileOrdersWidgetState extends State<ProfileOrdersWidget> {
  // ---------------------------------------------------------------------------
  // PROVIDER
  // ---------------------------------------------------------------------------

  final OrderProvider _orderProvider = OrderProvider();

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------

  PagedResult<OrderMU>? _orders;

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

    _loadOrders();
  }

  // ---------------------------------------------------------------------------
  // REFRESH
  // ---------------------------------------------------------------------------

  Future<void> refresh() async {
    await _loadOrders();
  }

  // ---------------------------------------------------------------------------
  // HAS MORE
  // ---------------------------------------------------------------------------

  bool get hasMore {
    if (_orders == null) {
      return false;
    }

    return _orders!.resultList.length < _orders!.count;
  }

  // ---------------------------------------------------------------------------
  // LOAD ORDERS
  // ---------------------------------------------------------------------------

  Future<void> _loadOrders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 0;
      });
    }

    try {
      final ApiResult<PagedResult<OrderMU>> result = await _orderProvider
          .getPagedEntityForUsers(const OrderSOU(page: 0, pageSize: _pageSize));

      if (!mounted) {
        return;
      }

      if (result.data != null) {
        setState(() {
          _orders = result.data;
          _currentPage = 0;
          _isLoading = false;
          _errorMessage = null;
        });

        widget.onOrdersLoaded?.call();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.message ?? 'Failed to load your orders.';
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load your orders.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD MORE ORDERS
  // ---------------------------------------------------------------------------

  Future<void> loadMore() async {
    if (_orders == null) {
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
      final ApiResult<PagedResult<OrderMU>> result = await _orderProvider
          .getPagedEntityForUsers(
            OrderSOU(page: nextPage, pageSize: _pageSize),
          );

      if (!mounted) {
        return;
      }

      if (result.data != null) {
        setState(() {
          _orders = PagedResult<OrderMU>(
            count: result.data!.count,
            resultList: [..._orders!.resultList, ...result.data!.resultList],
          );

          _currentPage = nextPage;
        });
      }
    } catch (e) {
      // Do not destroy already-loaded orders if loading another
      // page fails.
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_orders == null || _orders!.resultList.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _orders!.resultList.length,
          separatorBuilder: (context, index) {
            return const SizedBox(height: 12);
          },
          itemBuilder: (context, index) {
            return _buildOrderCard(_orders!.resultList[index]);
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
  // ORDER CARD
  // ---------------------------------------------------------------------------

  Widget _buildOrderCard(OrderMU order) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showOrderDetails(order),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _formatDateTime(order.dateTime),
                          style: TextStyle(
                            color: AppColors.textPrimary.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.orderStatus.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Divider(
                height: 1,
                color: AppColors.backgroundTertiary.withOpacity(0.35),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.movie_outlined,
                      label: 'Items',
                      value: '${order.bluRay.length}',
                    ),
                  ),

                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.attach_money,
                      label: 'Total',
                      value: '${order.fullPrice.toStringAsFixed(2)} KM',
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY ITEM
  // ---------------------------------------------------------------------------

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textPrimary.withOpacity(0.55), size: 18),

        const SizedBox(width: 7),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary.withOpacity(0.5),
                fontSize: 10,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ORDER DETAILS
  // ---------------------------------------------------------------------------

  void _showOrderDetails(OrderMU order) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.id}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          order.orderStatus.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.close,
                          color: AppColors.textPrimary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _buildDialogInfoRow(
                    Icons.calendar_today_outlined,
                    'Date',
                    _formatDateTime(order.dateTime),
                  ),

                  const SizedBox(height: 10),

                  _buildDialogInfoRow(
                    Icons.person_outline,
                    'Customer',
                    order.userName,
                  ),

                  const SizedBox(height: 10),

                  _buildDialogInfoRow(
                    Icons.email_outlined,
                    'Email',
                    order.userMail,
                  ),

                  const SizedBox(height: 10),

                  _buildDialogInfoRow(
                    Icons.phone_outlined,
                    'Phone',
                    order.userPhone,
                  ),

                  const SizedBox(height: 10),

                  _buildDialogInfoRow(
                    Icons.location_on_outlined,
                    'Address',
                    '${order.userAdress}, '
                        '${order.userZIP} '
                        '${order.userCity}, '
                        '${order.userCountry}',
                  ),

                  if (order.userNotes.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),

                    _buildDialogInfoRow(
                      Icons.notes_outlined,
                      'Notes',
                      order.userNotes,
                    ),
                  ],

                  const SizedBox(height: 18),

                  Divider(color: AppColors.backgroundTertiary.withOpacity(0.5)),

                  const SizedBox(height: 12),

                  const Text(
                    'Order Items',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Flexible(
                    child: order.bluRay.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No items in this order.',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: order.bluRay.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 8);
                            },
                            itemBuilder: (context, index) {
                              return _buildDialogBluRay(order.bluRay[index]);
                            },
                          ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Text(
                          '${order.fullPrice.toStringAsFixed(2)} KM',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // DIALOG INFO ROW
  // ---------------------------------------------------------------------------

  Widget _buildDialogInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textPrimary.withOpacity(0.65), size: 18),

        const SizedBox(width: 10),

        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DIALOG BLU-RAY
  // ---------------------------------------------------------------------------

  Widget _buildDialogBluRay(OrderBluRayMU item) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 60,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: item.bluRay.image.trim().isEmpty
                ? Icon(
                    Icons.movie_outlined,
                    color: AppColors.textPrimary.withOpacity(0.5),
                    size: 24,
                  )
                : Image.network(
                    item.bluRay.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.movie_outlined,
                        color: AppColors.textPrimary.withOpacity(0.5),
                        size: 24,
                      );
                    },
                  ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.bluRay.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Quantity: ${item.amount}',
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.bluRay.price.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                'each',
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
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
            Icons.shopping_bag_outlined,
            size: 52,
            color: AppColors.textPrimary.withOpacity(0.4),
          ),

          const SizedBox(height: 16),

          const Text(
            'No Orders Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Orders you place will appear here.',
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
            'Unable to load orders',
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
            onPressed: _loadOrders,
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

  // ---------------------------------------------------------------------------
  // FORMAT DATE
  // ---------------------------------------------------------------------------

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
