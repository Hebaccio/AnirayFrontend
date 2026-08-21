import 'dart:async';

import 'package:aniray_desktop/models/basic_entities/basic_entities.dart';
import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:aniray_desktop/models/order/order_models.dart';
import 'package:aniray_desktop/providers/api_result.dart';
import 'package:aniray_desktop/providers/entity_providers/order_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/order_status_provider.dart';
import 'package:aniray_desktop/requests/paged_result.dart';
import 'package:flutter/material.dart';

class DashboardOrdersScreen extends StatefulWidget {
  const DashboardOrdersScreen({
    super.key,
    required this.title,
    this.onOrderSelected,
  });

  final String title;

  final void Function(int orderId)? onOrderSelected;

  @override
  State<DashboardOrdersScreen> createState() => _DashboardOrdersScreenState();
}

class _DashboardOrdersScreenState extends State<DashboardOrdersScreen> {
  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  static const int _pageSize = 25;

  // ===========================================================================
  // PROVIDERS
  // ===========================================================================

  final OrderProvider _orderProvider = OrderProvider();

  final OrderStatusProvider _orderStatusProvider = OrderStatusProvider();

  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  // ===========================================================================
  // ORDERS STATE
  // ===========================================================================

  List<OrderME> _orders = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _page = 0;
  int _totalOrders = 0;

  // ===========================================================================
  // ORDER STATUS STATE
  // ===========================================================================

  List<BaseClass> _orderStatuses = [];

  bool _isLoadingOrderStatuses = false;

  String? _orderStatusError;

  // ===========================================================================
  // FILTER STATE
  // ===========================================================================

  String? _userNameFTS;
  String? _userMailFTS;
  String? _userCountryFTS;
  String? _userCityFTS;
  String? _userZIPFTS;

  DateTime? _dateTimeGTE;
  DateTime? _dateTimeLTE;

  double? _fullPriceGTE;
  double? _fullPriceLTE;

  int? _orderStatusId;

  OrderSortField? _orderBy;
  SortType? _sortType;

  // ===========================================================================
  // PAGINATION
  // ===========================================================================

  int get _totalPages {
    if (_totalOrders == 0) {
      return 1;
    }

    return (_totalOrders / _pageSize).ceil();
  }

  bool get _canGoPrevious => _page > 0;

  bool get _canGoNext => _page < _totalPages - 1;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _loadOrderStatuses();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // LOAD ORDER STATUSES
  // ===========================================================================

  Future<void> _loadOrderStatuses() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingOrderStatuses = true;
      _orderStatusError = null;
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
        _isLoadingOrderStatuses = false;
        _orderStatusError = null;
      });
    } else {
      setState(() {
        _orderStatuses = [];
        _isLoadingOrderStatuses = false;
        _orderStatusError = result.message ?? 'Failed to load order statuses.';
      });
    }
  }

  // ===========================================================================
  // LOAD ORDERS
  // ===========================================================================

  Future<void> _loadOrders() async {
    _setLoading();

    final String searchText = _searchController.text.trim();

    final OrderSOE search = OrderSOE(
      page: _page,
      pageSize: _pageSize,

      // -----------------------------------------------------------------------
      // Search
      // -----------------------------------------------------------------------
      userNameFTS: searchText.isEmpty ? null : searchText,

      // -----------------------------------------------------------------------
      // Text filters
      // -----------------------------------------------------------------------
      userMailFTS: _userMailFTS,
      userCountryFTS: _userCountryFTS,
      userCityFTS: _userCityFTS,
      userZIPFTS: _userZIPFTS,

      // -----------------------------------------------------------------------
      // Date
      // -----------------------------------------------------------------------
      dateTimeGTE: _dateTimeGTE,
      dateTimeLTE: _dateTimeLTE,

      // -----------------------------------------------------------------------
      // Price
      // -----------------------------------------------------------------------
      fullPriceGTE: _fullPriceGTE,
      fullPriceLTE: _fullPriceLTE,

      // -----------------------------------------------------------------------
      // Status
      // -----------------------------------------------------------------------
      orderStatusId: _orderStatusId,

      // -----------------------------------------------------------------------
      // Sorting
      // -----------------------------------------------------------------------
      orderBy: _orderBy,
      sortType: _sortType,
    );

    final ApiResult<PagedResult<OrderME>> result = await _orderProvider
        .getPagedEntityForEmployees(search);

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      final List<OrderME> loadedOrders = result.data!.resultList;

      setState(() {
        _orders = loadedOrders;
        _totalOrders = result.data!.count;

        _isLoading = false;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _orders = [];
        _totalOrders = 0;

        _isLoading = false;
        _errorMessage = result.message ?? 'Failed to load orders.';
      });
    }
  }

  void _setLoading() {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), _performSearch);
  }

  Future<void> _performSearch() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _page = 0;
    });

    await _loadOrders();
  }

  // ===========================================================================
  // FILTER
  // ===========================================================================

  Future<void> _onFilterPressed() async {
    final OrderFilterResult? result = await showDialog<OrderFilterResult>(
      context: context,
      builder: (context) {
        return OrderFilterDialog(
          userNameFTS: _userNameFTS,
          userMailFTS: _userMailFTS,
          userCountryFTS: _userCountryFTS,
          userCityFTS: _userCityFTS,
          userZIPFTS: _userZIPFTS,

          dateTimeGTE: _dateTimeGTE,
          dateTimeLTE: _dateTimeLTE,

          fullPriceGTE: _fullPriceGTE,
          fullPriceLTE: _fullPriceLTE,

          orderStatusId: _orderStatusId,

          orderBy: _orderBy,
          sortType: _sortType,

          orderStatuses: _orderStatuses,

          isLoadingOrderStatuses: _isLoadingOrderStatuses,
          orderStatusError: _orderStatusError,
          onRetryOrderStatuses: _loadOrderStatuses,
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _userNameFTS = result.userNameFTS;
      _userMailFTS = result.userMailFTS;
      _userCountryFTS = result.userCountryFTS;
      _userCityFTS = result.userCityFTS;
      _userZIPFTS = result.userZIPFTS;

      _dateTimeGTE = result.dateTimeGTE;
      _dateTimeLTE = result.dateTimeLTE;

      _fullPriceGTE = result.fullPriceGTE;
      _fullPriceLTE = result.fullPriceLTE;

      _orderStatusId = result.orderStatusId;

      _orderBy = result.orderBy;
      _sortType = result.sortType;

      _page = 0;
    });

    await _loadOrders();
  }

  // ===========================================================================
  // PAGINATION
  // ===========================================================================

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages || page == _page) {
      return;
    }

    setState(() {
      _page = page;
    });

    _loadOrders();
  }

  void _goToFirstPage() {
    _goToPage(0);
  }

  void _goToPreviousPage() {
    _goToPage(_page - 1);
  }

  void _goToNextPage() {
    _goToPage(_page + 1);
  }

  void _goToLastPage() {
    _goToPage(_totalPages - 1);
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF08111F),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),

            const SizedBox(height: 18),

            Expanded(child: _buildContent()),

            if (_shouldShowPagination()) ...[
              const SizedBox(height: 10),
              _buildPagination(),
              const SizedBox(height: 18),
            ],
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
      padding: const EdgeInsets.only(top: 35, left: 48, right: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540, minWidth: 350),
            child: _buildSearchField(),
          ),

          const SizedBox(width: 14),

          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF253853),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Filter by User Name',
              hintStyle: const TextStyle(
                color: Color(0xFF9DA6B5),
                fontSize: 15,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFFE0E4EA),
                size: 26,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFFB9C0CA),
                        size: 21,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterButton() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: const Color(0xFF253853),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _onFilterPressed,
          child: const Icon(Icons.tune, color: Color(0xFFE0E4EA), size: 25),
        ),
      ),
    );
  }

  // ===========================================================================
  // CONTENT
  // ===========================================================================

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_orders.isEmpty) {
      return _buildEmptyState();
    }

    return _buildOrderTable();
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  // ===========================================================================
  // ORDER TABLE
  // ===========================================================================

  Widget _buildOrderTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          _buildTableHeader(),

          const SizedBox(height: 8),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
              physics: const BouncingScrollPhysics(),
              itemCount: _orders.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 17);
              },
              itemBuilder: (context, index) {
                return _buildOrderRow(_orders[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TABLE HEADER
  // ===========================================================================

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildHeaderText('Order')),

          Expanded(flex: 4, child: _buildHeaderText('Customer')),

          Expanded(flex: 3, child: _buildHeaderText('Date')),

          Expanded(flex: 2, child: _buildHeaderText('Price')),

          Expanded(flex: 3, child: _buildHeaderText('Status')),

          Expanded(flex: 3, child: _buildHeaderText('Activity')),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFFF0F1F4),
        fontSize: 25,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // ===========================================================================
  // ORDER ROW
  // ===========================================================================

  Widget _buildOrderRow(OrderME order) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF253853),
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 5,
            spreadRadius: 4,
            offset: Offset(7, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildTableCell(
              icon: Icons.receipt_long_outlined,
              text: '#${order.id}',
            ),
          ),

          _buildDivider(),

          Expanded(
            flex: 4,
            child: _buildTableCell(
              icon: Icons.person_outline,
              text: order.userName,
            ),
          ),

          _buildDivider(),

          Expanded(
            flex: 3,
            child: _buildTableCell(
              icon: Icons.calendar_today_outlined,
              text: _formatDate(order.dateTime),
            ),
          ),

          _buildDivider(),

          Expanded(
            flex: 2,
            child: _buildTableCell(
              icon: Icons.payments_outlined,
              text: order.fullPrice.toStringAsFixed(2),
            ),
          ),

          _buildDivider(),

          Expanded(flex: 3, child: _buildStatusCell(order)),

          _buildDivider(),

          Expanded(flex: 3, child: _buildActivityCell(order)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 3,
      height: double.infinity,
      color: const Color(0xFF17263A),
    );
  }

  // ===========================================================================
  // TABLE CELL
  // ===========================================================================

  Widget _buildTableCell({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE0E4EA), size: 19),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STATUS
  // ===========================================================================

  Widget _buildStatusCell(OrderME order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFE0E4EA), size: 19),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              order.orderStatus.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACTIVITY
  // ===========================================================================

  Widget _buildActivityCell(OrderME order) {
    return Center(
      child: SizedBox(
        height: 30,
        child: ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF08111F),
            foregroundColor: const Color(0xFFE5E7EB),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('View Order', style: TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  // ===========================================================================
  // ORDER DETAILS
  // ===========================================================================

  Future<void> _updateOrderStatus(int orderId, int statusId) async {
    final ApiResult<OrderME> result = await _orderProvider
        .updateEntityForEmployees(orderId, OrderURE(orderStatusId: statusId));

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      Navigator.of(context).pop();

      await _loadOrders();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Failed to update order status.'),
        ),
      );
    }
  }

  // ===========================================================================
  // PAGINATION
  // ===========================================================================

  bool _shouldShowPagination() {
    return !_isLoading && _errorMessage == null && _orders.isNotEmpty;
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageButton(
          icon: Icons.first_page,
          enabled: _canGoPrevious,
          onPressed: _goToFirstPage,
        ),

        const SizedBox(width: 6),

        _buildPageButton(
          icon: Icons.chevron_left,
          enabled: _canGoPrevious,
          onPressed: _goToPreviousPage,
        ),

        const SizedBox(width: 16),

        Text(
          'Page ${_page + 1} of $_totalPages',
          style: const TextStyle(color: Color(0xFF9DA6B5), fontSize: 13),
        ),

        const SizedBox(width: 16),

        _buildPageButton(
          icon: Icons.chevron_right,
          enabled: _canGoNext,
          onPressed: _goToNextPage,
        ),

        const SizedBox(width: 6),

        _buildPageButton(
          icon: Icons.last_page,
          enabled: _canGoNext,
          onPressed: _goToLastPage,
        ),
      ],
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Material(
        color: enabled ? const Color(0xFF253853) : const Color(0xFF08111F),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: enabled ? onPressed : null,
          child: Icon(
            icon,
            size: 21,
            color: enabled ? const Color(0xFFE0E4EA) : const Color(0xFF4C5665),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 48),

          const SizedBox(height: 14),

          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9DA6B5), fontSize: 14),
          ),

          const SizedBox(height: 18),

          ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY
  // ===========================================================================

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, color: Color(0xFF7E8795), size: 55),

          SizedBox(height: 15),

          Text(
            'No orders found',
            style: TextStyle(color: Color(0xFF9DA6B5), fontSize: 17),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DATE FORMAT
  // ===========================================================================

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }
}

// =============================================================================
// ORDER FILTER RESULT
// =============================================================================

class OrderFilterResult {
  final String? userNameFTS;
  final String? userMailFTS;
  final String? userCountryFTS;
  final String? userCityFTS;
  final String? userZIPFTS;

  final DateTime? dateTimeGTE;
  final DateTime? dateTimeLTE;

  final double? fullPriceGTE;
  final double? fullPriceLTE;

  final int? orderStatusId;

  final OrderSortField? orderBy;
  final SortType? sortType;

  const OrderFilterResult({
    this.userNameFTS,
    this.userMailFTS,
    this.userCountryFTS,
    this.userCityFTS,
    this.userZIPFTS,
    this.dateTimeGTE,
    this.dateTimeLTE,
    this.fullPriceGTE,
    this.fullPriceLTE,
    this.orderStatusId,
    this.orderBy,
    this.sortType,
  });
}

// =============================================================================
// ORDER FILTER DIALOG
// =============================================================================

class OrderFilterDialog extends StatefulWidget {
  const OrderFilterDialog({
    super.key,
    this.userNameFTS,
    this.userMailFTS,
    this.userCountryFTS,
    this.userCityFTS,
    this.userZIPFTS,
    this.dateTimeGTE,
    this.dateTimeLTE,
    this.fullPriceGTE,
    this.fullPriceLTE,
    this.orderStatusId,
    this.orderBy,
    this.sortType,
    required this.orderStatuses,
    required this.isLoadingOrderStatuses,
    required this.orderStatusError,
    required this.onRetryOrderStatuses,
  });

  final String? userNameFTS;
  final String? userMailFTS;
  final String? userCountryFTS;
  final String? userCityFTS;
  final String? userZIPFTS;

  final DateTime? dateTimeGTE;
  final DateTime? dateTimeLTE;

  final double? fullPriceGTE;
  final double? fullPriceLTE;

  final int? orderStatusId;

  final OrderSortField? orderBy;
  final SortType? sortType;

  final List<BaseClass> orderStatuses;

  final bool isLoadingOrderStatuses;
  final String? orderStatusError;

  final Future<void> Function() onRetryOrderStatuses;

  @override
  State<OrderFilterDialog> createState() => _OrderFilterDialogState();
}

class _OrderFilterDialogState extends State<OrderFilterDialog> {
  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  late final TextEditingController _userNameController;
  late final TextEditingController _userMailController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _zipController;

  late final TextEditingController _priceFromController;
  late final TextEditingController _priceToController;

  // ===========================================================================
  // STATE
  // ===========================================================================

  DateTime? _dateTimeGTE;
  DateTime? _dateTimeLTE;

  double? _fullPriceGTE;
  double? _fullPriceLTE;

  int? _orderStatusId;

  OrderSortField? _orderBy;
  SortType? _sortType;

  bool _retryingStatuses = false;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _userNameController = TextEditingController(text: widget.userNameFTS ?? '');

    _userMailController = TextEditingController(text: widget.userMailFTS ?? '');

    _countryController = TextEditingController(
      text: widget.userCountryFTS ?? '',
    );

    _cityController = TextEditingController(text: widget.userCityFTS ?? '');

    _zipController = TextEditingController(text: widget.userZIPFTS ?? '');

    _priceFromController = TextEditingController(
      text: widget.fullPriceGTE?.toString() ?? '',
    );

    _priceToController = TextEditingController(
      text: widget.fullPriceLTE?.toString() ?? '',
    );

    _dateTimeGTE = widget.dateTimeGTE;
    _dateTimeLTE = widget.dateTimeLTE;

    _fullPriceGTE = widget.fullPriceGTE;
    _fullPriceLTE = widget.fullPriceLTE;

    _orderStatusId = widget.orderStatusId;

    _orderBy = widget.orderBy;
    _sortType = widget.sortType;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userMailController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _zipController.dispose();

    _priceFromController.dispose();
    _priceToController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // DATE PICKER
  // ===========================================================================

  Future<DateTime?> _selectDate(DateTime? initialDate) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF253853),
              surface: Color(0xFF152236),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // ===========================================================================
  // APPLY
  // ===========================================================================

  void _apply() {
    _fullPriceGTE = double.tryParse(_priceFromController.text.trim());

    _fullPriceLTE = double.tryParse(_priceToController.text.trim());

    Navigator.of(context).pop(
      OrderFilterResult(
        userNameFTS: _userNameController.text.trim().isEmpty
            ? null
            : _userNameController.text.trim(),

        userMailFTS: _userMailController.text.trim().isEmpty
            ? null
            : _userMailController.text.trim(),

        userCountryFTS: _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),

        userCityFTS: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),

        userZIPFTS: _zipController.text.trim().isEmpty
            ? null
            : _zipController.text.trim(),

        dateTimeGTE: _dateTimeGTE,
        dateTimeLTE: _dateTimeLTE,

        fullPriceGTE: _fullPriceGTE,
        fullPriceLTE: _fullPriceLTE,

        orderStatusId: _orderStatusId,

        orderBy: _orderBy,
        sortType: _sortType,
      ),
    );
  }

  // ===========================================================================
  // CLEAR
  // ===========================================================================

  void _clear() {
    _userNameController.clear();
    _userMailController.clear();
    _countryController.clear();
    _cityController.clear();
    _zipController.clear();

    _priceFromController.clear();
    _priceToController.clear();

    setState(() {
      _dateTimeGTE = null;
      _dateTimeLTE = null;

      _fullPriceGTE = null;
      _fullPriceLTE = null;

      _orderStatusId = null;

      _orderBy = null;
      _sortType = null;
    });
  }

  // ===========================================================================
  // RETRY STATUS LOAD
  // ===========================================================================

  Future<void> _retryOrderStatuses() async {
    if (_retryingStatuses) {
      return;
    }

    setState(() {
      _retryingStatuses = true;
    });

    await widget.onRetryOrderStatuses();

    if (!mounted) {
      return;
    }

    setState(() {
      _retryingStatuses = false;
    });
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF152236),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 750),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),

              const SizedBox(height: 25),

              // =================================================================
              // CUSTOMER INFORMATION
              // =================================================================
              _buildTextField(
                controller: _userNameController,
                label: 'User Name',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _userMailController,
                label: 'User Email',
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _countryController,
                label: 'Country',
                icon: Icons.public,
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city_outlined,
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _zipController,
                label: 'ZIP',
                icon: Icons.markunread_mailbox_outlined,
              ),

              const SizedBox(height: 22),

              _buildSectionTitle('Filters'),

              const SizedBox(height: 12),

              // =================================================================
              // ORDER STATUS
              // =================================================================
              _buildStatusDropdown(),

              const SizedBox(height: 22),

              // =================================================================
              // ORDER DATE
              // =================================================================
              _buildSectionTitle('Order Date'),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildDateButton(
                      label: 'From',
                      value: _dateTimeGTE,
                      onPressed: () async {
                        final DateTime? date = await _selectDate(_dateTimeGTE);

                        if (date != null) {
                          setState(() {
                            _dateTimeGTE = date;
                          });
                        }
                      },
                      onClear: () {
                        setState(() {
                          _dateTimeGTE = null;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _buildDateButton(
                      label: 'To',
                      value: _dateTimeLTE,
                      onPressed: () async {
                        final DateTime? date = await _selectDate(_dateTimeLTE);

                        if (date != null) {
                          setState(() {
                            _dateTimeLTE = date;
                          });
                        }
                      },
                      onClear: () {
                        setState(() {
                          _dateTimeLTE = null;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =================================================================
              // PRICE
              // =================================================================
              _buildSectionTitle('Price'),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceFromController,
                      label: 'From',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _buildTextField(
                      controller: _priceToController,
                      label: 'To',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =================================================================
              // SORTING
              // =================================================================
              _buildSectionTitle('Sorting'),

              const SizedBox(height: 12),

              DropdownButtonFormField<OrderSortField>(
                initialValue: _orderBy,
                dropdownColor: const Color(0xFF253853),
                decoration: _inputDecoration('Order By', Icons.sort),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: OrderSortField.values.map((field) {
                  return DropdownMenuItem<OrderSortField>(
                    value: field,
                    child: Text(_sortFieldLabel(field)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _orderBy = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<SortType>(
                initialValue: _sortType,
                dropdownColor: const Color(0xFF253853),
                decoration: _inputDecoration('Sort Type', Icons.swap_vert),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: SortType.values.map((sortType) {
                  return DropdownMenuItem<SortType>(
                    value: sortType,
                    child: Text(_sortTypeLabel(sortType)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sortType = value;
                  });
                },
              ),

              const SizedBox(height: 28),

              // =================================================================
              // BUTTONS
              // =================================================================
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE0E4EA),
                        side: const BorderSide(color: Color(0xFF52627A)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // STATUS DROPDOWN
  // ===========================================================================

  Widget _buildStatusDropdown() {
    if (widget.isLoadingOrderStatuses) {
      return InputDecorator(
        decoration: _inputDecoration('Order Status', Icons.info_outline),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFE0E4EA),
              ),
            ),

            SizedBox(width: 12),

            Text(
              'Loading statuses...',
              style: TextStyle(color: Color(0xFF9DA6B5), fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (widget.orderStatusError != null && widget.orderStatuses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFF253853),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFB9C0CA), size: 20),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                widget.orderStatusError!,
                style: const TextStyle(color: Color(0xFF9DA6B5), fontSize: 13),
              ),
            ),

            const SizedBox(width: 8),

            TextButton(
              onPressed: _retryingStatuses ? null : _retryOrderStatuses,
              child: _retryingStatuses
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final bool valueExists =
        _orderStatusId == null ||
        widget.orderStatuses.any((status) => status.id == _orderStatusId);

    return DropdownButtonFormField<int>(
      initialValue: valueExists ? _orderStatusId : null,
      dropdownColor: const Color(0xFF253853),
      decoration: _inputDecoration('Order Status', Icons.info_outline),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      hint: const Text(
        'All',
        style: TextStyle(color: Color(0xFF9DA6B5), fontSize: 14),
      ),
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('All')),

        ...widget.orderStatuses.map((status) {
          return DropdownMenuItem<int>(
            value: status.id,
            child: Text(status.name, overflow: TextOverflow.ellipsis),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _orderStatusId = value;
        });
      },
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.tune, color: Colors.white, size: 23),

        const SizedBox(width: 10),

        const Expanded(
          child: Text(
            'Filter Orders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close, color: Color(0xFF9DA6B5)),
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _buildSectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE0E4EA),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF9DA6B5)),
      prefixIcon: Icon(icon, color: const Color(0xFFB9C0CA), size: 20),
      filled: true,
      fillColor: const Color(0xFF253853),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFF52627A)),
      ),
    );
  }

  // ===========================================================================
  // DATE BUTTON
  // ===========================================================================

  Widget _buildDateButton({
    required String label,
    required DateTime? value,
    required VoidCallback onPressed,
    required VoidCallback onClear,
  }) {
    final String text = value == null
        ? label
        : '${value.year.toString().padLeft(4, '0')}-'
              '${value.month.toString().padLeft(2, '0')}-'
              '${value.day.toString().padLeft(2, '0')}';

    return SizedBox(
      height: 50,
      child: Material(
        color: const Color(0xFF253853),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFFB9C0CA),
                  size: 19,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value == null
                          ? const Color(0xFF9DA6B5)
                          : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),

                if (value != null)
                  IconButton(
                    onPressed: onClear,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF9DA6B5),
                      size: 17,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // LABELS
  // ===========================================================================

  String _sortFieldLabel(OrderSortField field) {
    switch (field) {
      case OrderSortField.dateTime:
        return 'Date';

      case OrderSortField.fullPrice:
        return 'Full Price';
    }
  }

  String _sortTypeLabel(SortType sortType) {
    switch (sortType) {
      case SortType.ascending:
        return 'Ascending';

      case SortType.descending:
        return 'Descending';
    }
  }
}

// =============================================================================
// ORDER DETAILS DIALOG
// =============================================================================

class OrderDetailsDialog extends StatefulWidget {
  const OrderDetailsDialog({
    super.key,
    required this.order,
    required this.orderStatuses,
    required this.onStatusUpdated,
  });

  final OrderME order;

  final List<BaseClass> orderStatuses;

  final Future<void> Function(int statusId) onStatusUpdated;

  @override
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  late int _selectedStatusId;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _selectedStatusId = widget.order.orderStatus.id;
  }

  // ===========================================================================
  // SAVE
  // ===========================================================================

  Future<void> _save() async {
    if (_selectedStatusId == widget.order.orderStatus.id) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onStatusUpdated(_selectedStatusId);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF152236),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750, maxHeight: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 25),

              _buildCustomerSection(),

              const SizedBox(height: 22),

              _buildShippingSection(),

              const SizedBox(height: 22),

              _buildOrderItems(),

              const SizedBox(height: 22),

              _buildStatusSection(),

              const SizedBox(height: 28),

              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 24),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            'Order #${widget.order.id}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        IconButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          icon: const Icon(Icons.close, color: Color(0xFF9DA6B5)),
        ),
      ],
    );
  }

  // ===========================================================================
  // CUSTOMER
  // ===========================================================================

  Widget _buildCustomerSection() {
    return _buildSection(
      title: 'Customer',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildInfoRow('Name', widget.order.userName, Icons.person_outline),

          _buildInfoRow('Email', widget.order.userMail, Icons.email_outlined),

          _buildInfoRow('Phone', widget.order.userPhone, Icons.phone_outlined),
        ],
      ),
    );
  }

  // ===========================================================================
  // SHIPPING
  // ===========================================================================

  Widget _buildShippingSection() {
    return _buildSection(
      title: 'Delivery Information',
      icon: Icons.local_shipping_outlined,
      child: Column(
        children: [
          _buildInfoRow('Country', widget.order.userCountry, Icons.public),

          _buildInfoRow(
            'City',
            widget.order.userCity,
            Icons.location_city_outlined,
          ),

          _buildInfoRow(
            'ZIP',
            widget.order.userZIP,
            Icons.markunread_mailbox_outlined,
          ),

          _buildInfoRow(
            'Address',
            widget.order.userAdress,
            Icons.home_outlined,
          ),

          _buildInfoRow('Notes', widget.order.userNotes, Icons.notes_outlined),
        ],
      ),
    );
  }

  // ===========================================================================
  // ITEMS
  // ===========================================================================

  Widget _buildOrderItems() {
    return _buildSection(
      title: 'Order Items',
      icon: Icons.inventory_2_outlined,
      child: widget.order.bluRay.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No Blu-ray items in this order.',
                style: TextStyle(color: Color(0xFF9DA6B5), fontSize: 14),
              ),
            )
          : Column(
              children: widget.order.bluRay.map((item) {
                return _buildBluRayItem(item);
              }).toList(),
            ),
    );
  }

  Widget _buildBluRayItem(OrderBluRayME item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF253853),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              item.bluRay.image,
              width: 55,
              height: 75,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 55,
                  height: 75,
                  color: const Color(0xFF17263A),
                  child: const Icon(
                    Icons.movie_outlined,
                    color: Color(0xFF7E8795),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.bluRay.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Quantity: ${item.amount}',
                  style: const TextStyle(
                    color: Color(0xFFB9C0CA),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Price: ${item.bluRay.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFB9C0CA),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STATUS
  // ===========================================================================

  Widget _buildStatusSection() {
    final bool valueExists = widget.orderStatuses.any(
      (status) => status.id == _selectedStatusId,
    );

    return _buildSection(
      title: 'Order Status',
      icon: Icons.info_outline,
      child: DropdownButtonFormField<int>(
        initialValue: valueExists ? _selectedStatusId : null,
        dropdownColor: const Color(0xFF253853),
        decoration: _inputDecoration('Status', Icons.info_outline),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        items: widget.orderStatuses.map((status) {
          return DropdownMenuItem<int>(
            value: status.id,
            child: Text(status.name),
          );
        }).toList(),
        onChanged: _isSaving
            ? null
            : (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedStatusId = value;
                });
              },
      ),
    );
  }

  // ===========================================================================
  // BUTTONS
  // ===========================================================================

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE0E4EA),
              side: const BorderSide(color: Color(0xFF52627A)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancel'),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save'),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION
  // ===========================================================================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF253853),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE0E4EA), size: 20),

              const SizedBox(width: 9),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }

  // ===========================================================================
  // INFO ROW
  // ===========================================================================

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFB9C0CA), size: 18),

          const SizedBox(width: 10),

          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF9DA6B5), fontSize: 13),
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
  // INPUT DECORATION
  // ===========================================================================

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF9DA6B5)),
      prefixIcon: Icon(icon, color: const Color(0xFFB9C0CA), size: 20),
      filled: true,
      fillColor: const Color(0xFF253853),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFF52627A)),
      ),
    );
  }
}
