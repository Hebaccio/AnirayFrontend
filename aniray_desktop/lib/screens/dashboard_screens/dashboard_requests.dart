import 'dart:async';

import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:aniray_desktop/models/request/request_models.dart';
import 'package:aniray_desktop/providers/api_result.dart';
import 'package:aniray_desktop/providers/entity_providers/request_provider.dart';
import 'package:aniray_desktop/requests/paged_result.dart';
import 'package:aniray_desktop/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardRequestsScreen extends StatefulWidget {
  const DashboardRequestsScreen({
    super.key,
    required this.title,
    this.onRequestSelected,
  });

  final String title;

  final void Function(int requestId)? onRequestSelected;

  @override
  State<DashboardRequestsScreen> createState() =>
      _DashboardRequestsScreenState();
}

class _DashboardRequestsScreenState extends State<DashboardRequestsScreen> {
  // ---------------------------------------------------------------------------
  // CONSTANTS
  // ---------------------------------------------------------------------------

  static const int _pageSize = 30;

  // ---------------------------------------------------------------------------
  // PROVIDERS / CONTROLLERS
  // ---------------------------------------------------------------------------

  final RequestProvider _requestProvider = RequestProvider();

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  // ---------------------------------------------------------------------------
  // FILTER STATE
  // ---------------------------------------------------------------------------

  DateTime? _dateTimeGTE;
  DateTime? _dateTimeLTE;

  String? _userFullNameFTS;
  String? _userMailFTS;

  RequestSortField? _orderBy;
  SortType? _sortType;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  List<RequestME> _requests = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _page = 0;
  int _totalRequests = 0;

  // ---------------------------------------------------------------------------
  // PAGINATION
  // ---------------------------------------------------------------------------

  int get _totalPages {
    if (_totalRequests == 0) {
      return 1;
    }

    return (_totalRequests / _pageSize).ceil();
  }

  bool get _canGoPrevious => _page > 0;

  bool get _canGoNext => _page < _totalPages - 1;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _loadRequests();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------

  Future<void> _loadRequests() async {
    _setLoading();

    final String searchText = _searchController.text.trim();

    final search = RequestSOE(
      page: _page,
      pageSize: _pageSize,

      // -----------------------------------------------------------------------
      // SEARCH BAR
      // -----------------------------------------------------------------------
      titleFTS: searchText.isEmpty ? null : searchText,

      // -----------------------------------------------------------------------
      // FILTERS
      // -----------------------------------------------------------------------
      dateTimeGTE: _dateTimeGTE,
      dateTimeLTE: _dateTimeLTE,

      userFullNameFTS: _userFullNameFTS,
      userMailFTS: _userMailFTS,

      // -----------------------------------------------------------------------
      // SORTING
      // -----------------------------------------------------------------------
      orderBy: _orderBy,
      sortType: _sortType,
    );

    final ApiResult<PagedResult<RequestME>> result = await _requestProvider
        .getPagedEntityForEmployees(search);

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      setState(() {
        _requests = result.data!.resultList;
        _totalRequests = result.data!.count;
        _isLoading = false;
      });
    } else {
      setState(() {
        _requests = [];
        _totalRequests = 0;
        _isLoading = false;
        _errorMessage = result.message ?? 'Failed to load requests.';
      });
    }
  }

  void _setLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _page = 0;
    });

    await _loadRequests();
  }

  // ---------------------------------------------------------------------------
  // FILTER
  // ---------------------------------------------------------------------------

  Future<void> _onFilterPressed() async {
    final RequestFilterResult? result = await showDialog<RequestFilterResult>(
      context: context,
      builder: (context) {
        return RequestFilterDialog(
          dateTimeGTE: _dateTimeGTE,
          dateTimeLTE: _dateTimeLTE,
          userFullNameFTS: _userFullNameFTS,
          userMailFTS: _userMailFTS,
          orderBy: _orderBy,
          sortType: _sortType,
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _dateTimeGTE = result.dateTimeGTE;
      _dateTimeLTE = result.dateTimeLTE;

      _userFullNameFTS = result.userFullNameFTS;
      _userMailFTS = result.userMailFTS;

      _orderBy = result.orderBy;
      _sortType = result.sortType;

      // Any filter change returns to page 0.
      _page = 0;
    });

    await _loadRequests();
  }

  // ---------------------------------------------------------------------------
  // PAGINATION ACTIONS
  // ---------------------------------------------------------------------------

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages || page == _page) {
      return;
    }

    setState(() {
      _page = page;
    });

    _loadRequests();
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

            const SizedBox(height: 30),

            Expanded(child: _buildContent()),

            if (_shouldShowPagination()) ...[
              const SizedBox(height: 15),
              _buildPagination(),
            ],
          ],
        ),
      ),
    );
  }

  bool _shouldShowPagination() {
    return !_isLoading && _errorMessage == null && _requests.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------------------------

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 35, 60, 5),
      child: _buildSearchAndFilter(),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 608, minWidth: 300),
          child: _buildSearchField(),
        ),

        const SizedBox(width: 22),

        _buildFilterButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search requests by title',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textPrimary,
                size: 28,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterButton() {
    return _buildIconButton(
      icon: Icons.tune,
      size: 42,
      iconSize: 25,
      onPressed: _onFilterPressed,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required double size,
    required double iconSize,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Icon(icon, color: AppColors.textPrimary, size: iconSize),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_requests.isEmpty) {
      return _buildEmptyState();
    }

    return _buildRequestGrid();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.textPrimary),
    );
  }

  // ---------------------------------------------------------------------------
  // REQUEST GRID
  // ---------------------------------------------------------------------------

  Widget _buildRequestGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(37, 0, 37, 30),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 430,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.4,
      ),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(_requests[index]);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // REQUEST CARD
  // ---------------------------------------------------------------------------

  Widget _buildRequestCard(RequestME request) {
    final bool isUnreplied = !request.readByStaff;

    return Material(
      color: const Color(0xFF405F8D),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          widget.onRequestSelected?.call(request.id);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 11),

                  _buildRequestInfoRow(
                    icon: Icons.person_outline,
                    text: request.userFullName,
                  ),

                  const SizedBox(height: 8),

                  _buildRequestInfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: _formatDateTime(request.dateTime),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: Text(
                      request.text,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isUnreplied)
              Positioned(
                top: -12,
                right: 17,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.reply_outlined, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Unreplied',
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
        ),
      ),
    );
  }

  Widget _buildRequestInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE3E8F0), size: 19),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PAGINATION
  // ---------------------------------------------------------------------------

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
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

          _buildPageIndicator(),

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
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Text(
      'Page ${_page + 1} of $_totalPages',
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: enabled
            ? AppColors.backgroundSecondary
            : AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onPressed : null,
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR / EMPTY STATES
  // ---------------------------------------------------------------------------

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.textError, size: 50),

          const SizedBox(height: 14),

          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton(onPressed: _loadRequests, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.textSecondary, size: 60),

          SizedBox(height: 16),

          Text(
            'No requests found',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  String _formatDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$month/$day/${dateTime.year} $hour:$minute';
  }
}

// =============================================================================
// REQUEST FILTER RESULT
// =============================================================================

class RequestFilterResult {
  final DateTime? dateTimeGTE;
  final DateTime? dateTimeLTE;

  final String? userFullNameFTS;
  final String? userMailFTS;

  final RequestSortField? orderBy;
  final SortType? sortType;

  const RequestFilterResult({
    this.dateTimeGTE,
    this.dateTimeLTE,
    this.userFullNameFTS,
    this.userMailFTS,
    this.orderBy,
    this.sortType,
  });
}

// =============================================================================
// REQUEST FILTER DIALOG
// =============================================================================

class RequestFilterDialog extends StatefulWidget {
  const RequestFilterDialog({
    super.key,
    this.dateTimeGTE,
    this.dateTimeLTE,
    this.userFullNameFTS,
    this.userMailFTS,
    this.orderBy,
    this.sortType,
  });

  final DateTime? dateTimeGTE;
  final DateTime? dateTimeLTE;

  final String? userFullNameFTS;
  final String? userMailFTS;

  final RequestSortField? orderBy;
  final SortType? sortType;

  @override
  State<RequestFilterDialog> createState() => _RequestFilterDialogState();
}

class _RequestFilterDialogState extends State<RequestFilterDialog> {
  // ---------------------------------------------------------------------------
  // CONTROLLERS
  // ---------------------------------------------------------------------------

  late final TextEditingController _userFullNameController;
  late final TextEditingController _userMailController;

  // ---------------------------------------------------------------------------
  // FILTER STATE
  // ---------------------------------------------------------------------------

  DateTime? _dateTimeGTE;
  DateTime? _dateTimeLTE;

  RequestSortField? _orderBy;
  SortType? _sortType;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _userFullNameController = TextEditingController(
      text: widget.userFullNameFTS ?? '',
    );

    _userMailController = TextEditingController(text: widget.userMailFTS ?? '');

    _dateTimeGTE = widget.dateTimeGTE;
    _dateTimeLTE = widget.dateTimeLTE;

    _orderBy = widget.orderBy;
    _sortType = widget.sortType;
  }

  @override
  void dispose() {
    _userFullNameController.dispose();
    _userMailController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),

              const SizedBox(height: 25),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------------------------------------------------
                      // USER NAME
                      // ---------------------------------------------------------
                      _buildTextField(
                        controller: _userFullNameController,
                        label: 'User',
                        hint: 'Search by user name',
                      ),

                      const SizedBox(height: 18),

                      // ---------------------------------------------------------
                      // USER EMAIL
                      // ---------------------------------------------------------
                      _buildTextField(
                        controller: _userMailController,
                        label: 'Email',
                        hint: 'Search by user email',
                      ),

                      const SizedBox(height: 24),

                      // ---------------------------------------------------------
                      // DATE RANGE
                      // ---------------------------------------------------------
                      _buildSectionTitle('Request Date'),

                      const SizedBox(height: 10),

                      _buildDateRange(),

                      const SizedBox(height: 24),

                      // ---------------------------------------------------------
                      // SORTING
                      // ---------------------------------------------------------
                      _buildSectionTitle('Sorting'),

                      const SizedBox(height: 10),

                      _buildSorting(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.tune, color: AppColors.textPrimary, size: 24),

        const SizedBox(width: 12),

        const Expanded(
          child: Text(
            'Filter Requests',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TEXT FIELD
  // ---------------------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.backgroundTertiary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DATE RANGE
  // ---------------------------------------------------------------------------

  Widget _buildDateRange() {
    return Row(
      children: [
        Expanded(
          child: _buildDateButton(
            label: _dateTimeGTE == null ? 'From' : _formatDate(_dateTimeGTE!),
            onPressed: () => _selectDate(isStart: true),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildDateButton(
            label: _dateTimeLTE == null ? 'To' : _formatDate(_dateTimeLTE!),
            onPressed: () => _selectDate(isStart: false),
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: Material(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 18,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final DateTime initialDate =
        (isStart ? _dateTimeGTE : _dateTimeLTE) ?? DateTime.now();

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.backgroundTertiary,
              surface: AppColors.backgroundSecondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      if (isStart) {
        _dateTimeGTE = selected;
      } else {
        _dateTimeLTE = selected;
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  // ---------------------------------------------------------------------------
  // SORTING
  // ---------------------------------------------------------------------------

  Widget _buildSorting() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<RequestSortField?>(
            value: _orderBy,
            dropdownColor: AppColors.backgroundTertiary,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.backgroundTertiary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            hint: const Text(
              'Sort by',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            items: RequestSortField.values.map((field) {
              return DropdownMenuItem<RequestSortField?>(
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
        ),

        const SizedBox(width: 12),

        Expanded(
          child: DropdownButtonFormField<SortType?>(
            value: _sortType,
            dropdownColor: AppColors.backgroundTertiary,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.backgroundTertiary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            hint: const Text(
              'Direction',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            items: SortType.values.map((type) {
              return DropdownMenuItem<SortType?>(
                value: type,
                child: Text(_sortTypeLabel(type)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _sortType = value;
              });
            },
          ),
        ),
      ],
    );
  }

  String _sortFieldLabel(RequestSortField field) {
    switch (field) {
      case RequestSortField.dateTime:
        return 'Date';
    }
  }

  String _sortTypeLabel(SortType type) {
    switch (type) {
      case SortType.ascending:
        return 'Ascending';

      case SortType.descending:
        return 'Descending';
    }
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearFilters,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.backgroundTertiary),
            ),
            child: const Text('Clear'),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Apply'),
          ),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _dateTimeGTE = null;
      _dateTimeLTE = null;

      _userFullNameController.clear();
      _userMailController.clear();

      _orderBy = null;
      _sortType = null;
    });
  }

  void _applyFilters() {
    Navigator.of(context).pop(
      RequestFilterResult(
        dateTimeGTE: _dateTimeGTE,
        dateTimeLTE: _dateTimeLTE,

        userFullNameFTS: _userFullNameController.text.trim().isEmpty
            ? null
            : _userFullNameController.text.trim(),

        userMailFTS: _userMailController.text.trim().isEmpty
            ? null
            : _userMailController.text.trim(),

        orderBy: _orderBy,
        sortType: _sortType,
      ),
    );
  }
}
