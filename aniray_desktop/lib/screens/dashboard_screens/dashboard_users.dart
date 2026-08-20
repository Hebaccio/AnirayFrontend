import 'dart:async';

import 'package:aniray_desktop/models/basic_entities/basic_entities.dart';
import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:aniray_desktop/models/user/user_models.dart';
import 'package:aniray_desktop/providers/api_result.dart';
import 'package:aniray_desktop/providers/entity_providers/gender_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/user_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/user_role_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/user_status_provider.dart';
import 'package:aniray_desktop/requests/auth_requests/auth_result.dart';
import 'package:aniray_desktop/requests/paged_result.dart';
import 'package:flutter/material.dart';

class DashboardUsersScreen extends StatefulWidget {
  const DashboardUsersScreen({
    super.key,
    required this.title,
    this.onUserSelected,
  });

  final String title;
  final void Function(int userId)? onUserSelected;

  @override
  State<DashboardUsersScreen> createState() => _DashboardUsersScreenState();
}

class _DashboardUsersScreenState extends State<DashboardUsersScreen> {
  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  static const int _pageSize = 25;

  // ===========================================================================
  // PROVIDERS
  // ===========================================================================

  final UserProvider _userProvider = UserProvider();

  final GenderProvider _genderProvider = GenderProvider();

  final UserRoleProvider _userRoleProvider = UserRoleProvider();

  final UserStatusProvider _userStatusProvider = UserStatusProvider();

  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  // ===========================================================================
  // USERS STATE
  // ===========================================================================

  List<UserME> _users = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _page = 0;
  int _totalUsers = 0;

  // ===========================================================================
  // FILTER ENTITY STATE
  // ===========================================================================

  List<BaseClassME> _genders = [];
  List<BaseClassME> _userRoles = [];
  List<BaseClassME> _userStatuses = [];

  bool _isLoadingFilters = true;

  // ===========================================================================
  // FILTER STATE
  // ===========================================================================

  String? _usernameFTS;
  String? _emailFTS;

  DateTime? _birthdayGTE;
  DateTime? _birthdayLTE;

  DateTime? _createdAtGTE;
  DateTime? _createdAtLTE;

  int? _userRoleId;
  int? _userStatusId;
  int? _genderId;

  UserSortField? _orderBy;
  SortType? _sortType;

  // ===========================================================================
  // ROLE ACCESS
  // ===========================================================================

  /// Only Boss users are allowed to see/use the User Role filter.
  bool get _isBoss => AuthResult.isBoss;

  // ===========================================================================
  // PAGINATION
  // ===========================================================================

  int get _totalPages {
    if (_totalUsers == 0) {
      return 1;
    }

    return (_totalUsers / _pageSize).ceil();
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

    _initialize();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  Future<void> _initialize() async {
    await Future.wait([_loadFilterEntities(), _loadUsers()]);
  }

  // ===========================================================================
  // LOAD FILTER ENTITIES
  // ===========================================================================

  Future<void> _loadFilterEntities() async {
    if (mounted) {
      setState(() {
        _isLoadingFilters = true;
      });
    }

    try {
      final List<Future<List<BaseClassME>>> requests = [
        _loadGenders(),
        _loadUserStatuses(),
      ];

      // Only fetch User Roles if the current user is a Boss.
      if (_isBoss) {
        requests.add(_loadUserRoles());
      }

      final results = await Future.wait(requests);

      if (!mounted) {
        return;
      }

      if (_isBoss) {
        setState(() {
          _genders = results[0];
          _userStatuses = results[1];
          _userRoles = results[2];

          _isLoadingFilters = false;
        });
      } else {
        setState(() {
          _genders = results[0];
          _userStatuses = results[1];
          _userRoles = [];

          _isLoadingFilters = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingFilters = false;
      });
    }
  }

  Future<List<BaseClassME>> _loadGenders() async {
    final ApiResult<PagedResult<BaseClassME>> result = await _genderProvider
        .getPagedEntityForEmployees(const BaseClassSOE(page: 0, pageSize: 100));

    if (result.data == null) {
      return [];
    }

    return result.data!.resultList;
  }

  Future<List<BaseClassME>> _loadUserRoles() async {
    final ApiResult<PagedResult<BaseClassME>> result = await _userRoleProvider
        .getPagedEntityForEmployees(const BaseClassSOE(page: 0, pageSize: 100));

    if (result.data == null) {
      return [];
    }

    return result.data!.resultList;
  }

  Future<List<BaseClassME>> _loadUserStatuses() async {
    final ApiResult<PagedResult<BaseClassME>> result = await _userStatusProvider
        .getPagedEntityForEmployees(const BaseClassSOE(page: 0, pageSize: 100));

    if (result.data == null) {
      return [];
    }

    return result.data!.resultList;
  }

  // ===========================================================================
  // LOAD USERS
  // ===========================================================================

  Future<void> _loadUsers() async {
    _setLoading();

    final String searchText = _searchController.text.trim();

    final UserSOE search = UserSOE(
      page: _page,
      pageSize: _pageSize,

      // Search
      fullNameFTS: searchText.isEmpty ? null : searchText,

      // Text filters
      usernameFTS: _usernameFTS,
      emailFTS: _emailFTS,

      // Birthday filters
      birthdayGTE: _birthdayGTE,
      birthdayLTE: _birthdayLTE,

      // Created At filters
      createdAtGTE: _createdAtGTE,
      createdAtLTE: _createdAtLTE,

      // Entity filters
      userRoleId: _isBoss ? _userRoleId : null,
      userStatusId: _userStatusId,
      genderId: _genderId,

      // Sorting
      orderBy: _orderBy,
      sortType: _sortType,
    );

    final ApiResult<PagedResult<UserME>> result = await _userProvider
        .getPagedEntityForEmployees(search);

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      setState(() {
        _users = result.data!.resultList;
        _totalUsers = result.data!.count;

        _isLoading = false;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _users = [];
        _totalUsers = 0;

        _isLoading = false;
        _errorMessage = result.message ?? 'Failed to load users.';
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

    await _loadUsers();
  }

  // ===========================================================================
  // FILTER
  // ===========================================================================

  Future<void> _onFilterPressed() async {
    final UserFilterResult? result = await showDialog<UserFilterResult>(
      context: context,
      builder: (context) {
        return UserFilterDialog(
          usernameFTS: _usernameFTS,
          emailFTS: _emailFTS,

          birthdayGTE: _birthdayGTE,
          birthdayLTE: _birthdayLTE,

          createdAtGTE: _createdAtGTE,
          createdAtLTE: _createdAtLTE,

          userRoleId: _isBoss ? _userRoleId : null,
          userStatusId: _userStatusId,
          genderId: _genderId,

          orderBy: _orderBy,
          sortType: _sortType,

          genders: _genders,
          userRoles: _userRoles,
          userStatuses: _userStatuses,

          isLoadingFilters: _isLoadingFilters,

          // Tell the dialog whether it should display User Role.
          canFilterByUserRole: _isBoss,
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _usernameFTS = result.usernameFTS;
      _emailFTS = result.emailFTS;

      _birthdayGTE = result.birthdayGTE;
      _birthdayLTE = result.birthdayLTE;

      _createdAtGTE = result.createdAtGTE;
      _createdAtLTE = result.createdAtLTE;

      // User Role is only accepted for Boss users.
      _userRoleId = _isBoss ? result.userRoleId : null;

      _userStatusId = result.userStatusId;
      _genderId = result.genderId;

      _orderBy = result.orderBy;
      _sortType = result.sortType;

      _page = 0;
    });

    await _loadUsers();
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

    _loadUsers();
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
              hintText: 'Filter by Name',
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

    if (_users.isEmpty) {
      return _buildEmptyState();
    }

    return _buildUserTable();
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  // ===========================================================================
  // USER TABLE
  // ===========================================================================

  Widget _buildUserTable() {
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
              itemCount: _users.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 17);
              },
              itemBuilder: (context, index) {
                return _buildUserRow(_users[index]);
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
          Expanded(flex: 4, child: _buildHeaderText('Person')),

          Expanded(flex: 4, child: _buildHeaderText('Email')),

          Expanded(flex: 2, child: _buildHeaderText('Status')),

          Expanded(flex: 2, child: _buildHeaderText('Activity')),
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
  // USER ROW
  // ===========================================================================

  Widget _buildUserRow(UserME user) {
    final String fullName = '${user.name} ${user.lastName}'.trim();

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
            flex: 4,
            child: _buildTableCell(icon: Icons.person_outline, text: fullName),
          ),

          _buildDivider(),

          Expanded(
            flex: 4,
            child: _buildTableCell(
              icon: Icons.alternate_email,
              text: user.email,
            ),
          ),

          _buildDivider(),

          Expanded(flex: 2, child: _buildStatusCell(user)),

          _buildDivider(),

          Expanded(flex: 2, child: _buildActivityCell(user)),
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

  Widget _buildStatusCell(UserME user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.help_outline, color: Color(0xFFE0E4EA), size: 19),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              user.userStatus.name,
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

  Widget _buildActivityCell(UserME user) {
    return Center(
      child: SizedBox(
        height: 30,
        child: ElevatedButton.icon(
          onPressed: () {
            widget.onUserSelected?.call(user.id);
          },
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
          label: const Text('Edit User', style: TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  // ===========================================================================
  // PAGINATION
  // ===========================================================================

  bool _shouldShowPagination() {
    return !_isLoading && _errorMessage == null && _users.isNotEmpty;
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

          ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
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
          Icon(Icons.people_outline, color: Color(0xFF7E8795), size: 55),

          SizedBox(height: 15),

          Text(
            'No users found',
            style: TextStyle(color: Color(0xFF9DA6B5), fontSize: 17),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// USER FILTER RESULT
// =============================================================================

class UserFilterResult {
  final String? usernameFTS;
  final String? emailFTS;

  final DateTime? birthdayGTE;
  final DateTime? birthdayLTE;

  final DateTime? createdAtGTE;
  final DateTime? createdAtLTE;

  final int? userRoleId;
  final int? userStatusId;
  final int? genderId;

  final UserSortField? orderBy;
  final SortType? sortType;

  const UserFilterResult({
    this.usernameFTS,
    this.emailFTS,

    this.birthdayGTE,
    this.birthdayLTE,

    this.createdAtGTE,
    this.createdAtLTE,

    this.userRoleId,
    this.userStatusId,
    this.genderId,

    this.orderBy,
    this.sortType,
  });
}

// =============================================================================
// USER FILTER DIALOG
// =============================================================================

class UserFilterDialog extends StatefulWidget {
  const UserFilterDialog({
    super.key,
    this.usernameFTS,
    this.emailFTS,

    this.birthdayGTE,
    this.birthdayLTE,

    this.createdAtGTE,
    this.createdAtLTE,

    this.userRoleId,
    this.userStatusId,
    this.genderId,

    this.orderBy,
    this.sortType,

    required this.genders,
    required this.userRoles,
    required this.userStatuses,
    required this.isLoadingFilters,

    required this.canFilterByUserRole,
  });

  final String? usernameFTS;
  final String? emailFTS;

  final DateTime? birthdayGTE;
  final DateTime? birthdayLTE;

  final DateTime? createdAtGTE;
  final DateTime? createdAtLTE;

  final int? userRoleId;
  final int? userStatusId;
  final int? genderId;

  final UserSortField? orderBy;
  final SortType? sortType;

  final List<BaseClassME> genders;
  final List<BaseClassME> userRoles;
  final List<BaseClassME> userStatuses;

  final bool isLoadingFilters;

  /// Determines whether the User Role filter is visible.
  final bool canFilterByUserRole;

  @override
  State<UserFilterDialog> createState() => _UserFilterDialogState();
}

class _UserFilterDialogState extends State<UserFilterDialog> {
  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;

  // ===========================================================================
  // STATE
  // ===========================================================================

  DateTime? _birthdayGTE;
  DateTime? _birthdayLTE;

  DateTime? _createdAtGTE;
  DateTime? _createdAtLTE;

  int? _userRoleId;
  int? _userStatusId;
  int? _genderId;

  UserSortField? _orderBy;
  SortType? _sortType;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController(text: widget.usernameFTS ?? '');

    _emailController = TextEditingController(text: widget.emailFTS ?? '');

    _birthdayGTE = widget.birthdayGTE;
    _birthdayLTE = widget.birthdayLTE;

    _createdAtGTE = widget.createdAtGTE;
    _createdAtLTE = widget.createdAtLTE;

    _userRoleId = widget.canFilterByUserRole ? widget.userRoleId : null;

    _userStatusId = widget.userStatusId;
    _genderId = widget.genderId;

    _orderBy = widget.orderBy;
    _sortType = widget.sortType;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();

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
    Navigator.of(context).pop(
      UserFilterResult(
        usernameFTS: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),

        emailFTS: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),

        birthdayGTE: _birthdayGTE,
        birthdayLTE: _birthdayLTE,

        createdAtGTE: _createdAtGTE,
        createdAtLTE: _createdAtLTE,

        // Only Boss users can apply a User Role filter.
        userRoleId: widget.canFilterByUserRole ? _userRoleId : null,

        userStatusId: _userStatusId,
        genderId: _genderId,

        orderBy: _orderBy,
        sortType: _sortType,
      ),
    );
  }

  // ===========================================================================
  // CLEAR
  // ===========================================================================

  void _clear() {
    _usernameController.clear();
    _emailController.clear();

    setState(() {
      _birthdayGTE = null;
      _birthdayLTE = null;

      _createdAtGTE = null;
      _createdAtLTE = null;

      _userRoleId = null;
      _userStatusId = null;
      _genderId = null;

      _orderBy = null;
      _sortType = null;
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

              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 22),

              _buildSectionTitle('Filters'),

              const SizedBox(height: 12),

              // =================================================================
              // USER STATUS
              // =================================================================
              _buildEntityDropdown(
                label: 'User Status',
                icon: Icons.info_outline,
                value: _userStatusId,
                items: widget.userStatuses,
                isLoading: widget.isLoadingFilters,
                onChanged: (value) {
                  setState(() {
                    _userStatusId = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              // =================================================================
              // GENDER
              // =================================================================
              _buildEntityDropdown(
                label: 'Gender',
                icon: Icons.person_outline,
                value: _genderId,
                items: widget.genders,
                isLoading: widget.isLoadingFilters,
                onChanged: (value) {
                  setState(() {
                    _genderId = value;
                  });
                },
              ),

              // =================================================================
              // USER ROLE
              // =================================================================
              if (widget.canFilterByUserRole) ...[
                const SizedBox(height: 14),

                _buildEntityDropdown(
                  label: 'User Role',
                  icon: Icons.admin_panel_settings_outlined,
                  value: _userRoleId,
                  items: widget.userRoles,
                  isLoading: widget.isLoadingFilters,
                  onChanged: (value) {
                    setState(() {
                      _userRoleId = value;
                    });
                  },
                ),
              ],

              const SizedBox(height: 22),

              // =================================================================
              // BIRTHDAY
              // =================================================================
              _buildSectionTitle('Birthday'),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildDateButton(
                      label: 'From',
                      value: _birthdayGTE,
                      onPressed: () async {
                        final DateTime? date = await _selectDate(_birthdayGTE);

                        if (date != null) {
                          setState(() {
                            _birthdayGTE = date;
                          });
                        }
                      },
                      onClear: () {
                        setState(() {
                          _birthdayGTE = null;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _buildDateButton(
                      label: 'To',
                      value: _birthdayLTE,
                      onPressed: () async {
                        final DateTime? date = await _selectDate(_birthdayLTE);

                        if (date != null) {
                          setState(() {
                            _birthdayLTE = date;
                          });
                        }
                      },
                      onClear: () {
                        setState(() {
                          _birthdayLTE = null;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =================================================================
              // CREATED AT
              // =================================================================
              _buildSectionTitle('Created At'),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildDateButton(
                      label: 'From',
                      value: _createdAtGTE,
                      onPressed: () async {
                        final DateTime? date = await _selectDate(_createdAtGTE);

                        if (date != null) {
                          setState(() {
                            _createdAtGTE = date;
                          });
                        }
                      },
                      onClear: () {
                        setState(() {
                          _createdAtGTE = null;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _buildDateButton(
                      label: 'To',
                      value: _createdAtLTE,
                      onPressed: () async {
                        final DateTime? date = await _selectDate(_createdAtLTE);

                        if (date != null) {
                          setState(() {
                            _createdAtLTE = date;
                          });
                        }
                      },
                      onClear: () {
                        setState(() {
                          _createdAtLTE = null;
                        });
                      },
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

              DropdownButtonFormField<UserSortField>(
                initialValue: _orderBy,
                dropdownColor: const Color(0xFF253853),
                decoration: _inputDecoration('Order By', Icons.sort),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: UserSortField.values.map((field) {
                  return DropdownMenuItem<UserSortField>(
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
  // ENTITY DROPDOWN
  // ===========================================================================

  Widget _buildEntityDropdown({
    required String label,
    required IconData icon,
    required int? value,
    required List<BaseClassME> items,
    required bool isLoading,
    required ValueChanged<int?> onChanged,
  }) {
    final bool valueExists =
        value == null || items.any((item) => item.id == value);

    return DropdownButtonFormField<int>(
      initialValue: valueExists ? value : null,
      dropdownColor: const Color(0xFF253853),
      decoration: _inputDecoration(label, icon),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      hint: Text(
        isLoading ? 'Loading...' : 'All',
        style: const TextStyle(color: Color(0xFF9DA6B5), fontSize: 14),
      ),
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('All')),

        ...items.map((item) {
          return DropdownMenuItem<int>(
            value: item.id,
            child: Text(item.name, overflow: TextOverflow.ellipsis),
          );
        }),
      ],
      onChanged: isLoading ? null : onChanged,
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
            'Filter Users',
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

  String _sortFieldLabel(UserSortField field) {
    switch (field) {
      case UserSortField.username:
        return 'Username';

      case UserSortField.name:
        return 'Name';

      case UserSortField.lastName:
        return 'Last Name';

      case UserSortField.email:
        return 'Email';

      case UserSortField.birthday:
        return 'Birthday';

      case UserSortField.createdAt:
        return 'Created At';

      case UserSortField.userRoleId:
        return 'User Role';

      case UserSortField.userStatusId:
        return 'User Status';

      case UserSortField.genderId:
        return 'Gender';
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
