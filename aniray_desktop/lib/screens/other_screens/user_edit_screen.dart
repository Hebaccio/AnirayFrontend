import 'package:aniray_desktop/requests/paged_result.dart';
import 'package:flutter/material.dart';

import 'package:aniray_desktop/models/basic_entities/basic_entities.dart';
import 'package:aniray_desktop/models/order/order_models.dart';
import 'package:aniray_desktop/models/user/user_models.dart';
import 'package:aniray_desktop/providers/api_result.dart';
import 'package:aniray_desktop/providers/entity_providers/gender_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/order_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/user_provider.dart';
import 'package:aniray_desktop/providers/entity_providers/user_status_provider.dart';

class UserEditScreen extends StatefulWidget {
  const UserEditScreen({
    super.key,
    required this.userId,
    this.onBack,
    this.onSaved,
  });

  final int userId;
  final VoidCallback? onSaved;
  final VoidCallback? onBack;

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  // ===========================================================================
  // PROVIDERS
  // ===========================================================================

  final UserProvider _userProvider = UserProvider();
  final UserStatusProvider _userStatusProvider = UserStatusProvider();
  final GenderProvider _genderProvider = GenderProvider();
  final OrderProvider _orderProvider = OrderProvider();

  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // ===========================================================================
  // STATE
  // ===========================================================================

  UserME? _user;

  List<BaseClassME> _userStatuses = [];
  List<BaseClassME> _genders = [];
  List<OrderME> _orders = [];

  int? _selectedStatusId;
  int? _selectedGenderId;

  DateTime? _birthday;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _ordersLoading = true;

  String? _errorMessage;
  String? _ordersError;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // LOAD DATA
  // ===========================================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _ordersLoading = true;
        _ordersError = null;
      });
    }

    try {
      final results = await Future.wait([
        _userProvider.entityGetByIdForEmployees(widget.userId),
        _loadStatuses(),
        _loadGenders(),
        _loadOrders(),
      ]);

      final ApiResult<UserME> userResult = results[0] as ApiResult<UserME>;

      final List<BaseClassME> statuses = results[1] as List<BaseClassME>;

      final List<BaseClassME> genders = results[2] as List<BaseClassME>;

      final List<OrderME> orders = results[3] as List<OrderME>;

      if (!mounted) {
        return;
      }

      if (userResult.data == null) {
        setState(() {
          _isLoading = false;
          _ordersLoading = false;
          _errorMessage = userResult.message ?? 'Failed to load user.';
        });

        return;
      }

      final UserME user = userResult.data!;

      // -----------------------------------------------------------------------
      // Resolve status ID from the status name returned by UserME.
      // -----------------------------------------------------------------------

      final int? statusId = _findEntityIdByName(
        items: statuses,
        name: user.userStatus.name,
      );

      // -----------------------------------------------------------------------
      // Resolve gender ID from the gender name returned by UserME.
      // -----------------------------------------------------------------------

      final int? genderId = _findEntityIdByName(
        items: genders,
        name: user.gender.name,
      );

      _user = user;

      _nameController.text = user.name;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _usernameController.text = user.username;

      _birthday = user.birthday;

      _userStatuses = statuses;
      _genders = genders;

      _selectedStatusId = statusId;
      _selectedGenderId = genderId;

      setState(() {
        _isLoading = false;
        _ordersLoading = false;
        _orders = orders;
        _ordersError = null;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _ordersLoading = false;
        _errorMessage = 'Failed to load user information.';
      });
    }
  }

  // ===========================================================================
  // FIND ENTITY ID BY NAME
  // ===========================================================================

  int? _findEntityIdByName({
    required List<BaseClassME> items,
    required String name,
  }) {
    final String normalizedName = name.trim().toLowerCase();

    for (final BaseClassME item in items) {
      if (item.name.trim().toLowerCase() == normalizedName) {
        return item.id;
      }
    }

    return null;
  }

  // ===========================================================================
  // LOAD STATUSES
  // ===========================================================================

  Future<List<BaseClassME>> _loadStatuses() async {
    final ApiResult<PagedResult<BaseClassME>> result = await _userStatusProvider
        .getPagedEntityForEmployees(const BaseClassSOE(page: 0, pageSize: 100));

    if (result.data == null) {
      return [];
    }

    return result.data!.resultList;
  }

  // ===========================================================================
  // LOAD GENDERS
  // ===========================================================================

  Future<List<BaseClassME>> _loadGenders() async {
    final ApiResult<PagedResult<BaseClassME>> result = await _genderProvider
        .getPagedEntityForEmployees(const BaseClassSOE(page: 0, pageSize: 100));

    if (result.data == null) {
      return [];
    }

    return result.data!.resultList;
  }

  // ===========================================================================
  // LOAD ORDERS
  // ===========================================================================

  Future<List<OrderME>> _loadOrders() async {
    try {
      final ApiResult<PagedResult<OrderME>> result = await _orderProvider
          .getPagedEntityForEmployees(
            OrderSOE(page: 0, pageSize: 100, userId: widget.userId),
          );

      if (result.data == null) {
        _ordersError = result.message ?? 'Failed to load user orders.';
        return [];
      }

      return result.data!.resultList;
    } catch (e) {
      _ordersError = 'Failed to load user orders.';
      return [];
    }
  }

  // ===========================================================================
  // SAVE
  // ===========================================================================

  Future<void> _saveChanges() async {
    if (_isSaving) {
      return;
    }

    final String name = _nameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String email = _emailController.text.trim();
    final String username = _usernameController.text.trim();

    if (name.isEmpty) {
      _showError('Name cannot be empty.');
      return;
    }

    if (lastName.isEmpty) {
      _showError('Last name cannot be empty.');
      return;
    }

    if (email.isEmpty) {
      _showError('Email cannot be empty.');
      return;
    }

    if (username.isEmpty) {
      _showError('Username cannot be empty.');
      return;
    }

    if (_birthday == null) {
      _showError('Birthday cannot be empty.');
      return;
    }

    if (_selectedGenderId == null) {
      _showError('Gender must be selected.');
      return;
    }

    if (_selectedStatusId == null) {
      _showError('User status must be selected.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final UserURE request = UserURE(
      username: username,
      name: name,
      lastName: lastName,
      email: email,
      birthday: _birthday,
      genderId: _selectedGenderId,
      userStatusId: _selectedStatusId,
    );

    final ApiResult<UserME> result = await _userProvider
        .updateEntityForEmployees(widget.userId, request);

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      _user = result.data;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully.')),
      );

      widget.onSaved?.call();
    } else {
      setState(() {
        _isSaving = false;
      });

      _showError(result.message ?? 'Failed to update user.');
    }
  }

  // ===========================================================================
  // DATE PICKER
  // ===========================================================================

  Future<void> _selectBirthday() async {
    final DateTime initialDate = _birthday ?? DateTime(2000, 1, 1);

    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF164C82),
              surface: Color(0xFF152236),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _birthday = result;
    });
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      child: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_user == null) {
      return const Center(
        child: Text(
          'User not found.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return _buildUserInfo();
  }

  // ===========================================================================
  // USER INFO
  // ===========================================================================

  Widget _buildUserInfo() {
    final UserME user = _user!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(35, 15, 35, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: _buildSectionTitle('User Info'),
          ),

          const SizedBox(height: 16),

          _buildInfoArea(user),

          const SizedBox(height: 34),

          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: _buildSectionTitle('User Orders'),
          ),

          const SizedBox(height: 18),

          _buildOrders(),
        ],
      ),
    );
  }

  // ===========================================================================
  // TOP BAR
  // ===========================================================================

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // -----------------------------------------------------------------------
        // BACK BUTTON
        // -----------------------------------------------------------------------
        ElevatedButton.icon(
          onPressed: _isSaving ? null : widget.onBack,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Back', style: TextStyle(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF253853),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF253853),
            disabledForegroundColor: Colors.white54,
            elevation: 5,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),

        // -----------------------------------------------------------------------
        // SAVE BUTTON
        // -----------------------------------------------------------------------
        ElevatedButton(
          onPressed: _isSaving ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF253853),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF253853),
            disabledForegroundColor: Colors.white54,
            elevation: 5,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
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
              : const Text('Save Changes', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  // ===========================================================================
  // INFO AREA
  // ===========================================================================

  Widget _buildInfoArea(UserME user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileImage(user),

          const SizedBox(width: 36),

          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildFields(user),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // ===========================================================================
  // PROFILE IMAGE
  // ===========================================================================

  Widget _buildProfileImage(UserME user) {
    return Container(
      width: 235,
      height: 235,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: user.pfp.trim().isEmpty
          ? Container(
              color: const Color(0xFF253853),
              child: const Icon(Icons.person, color: Colors.white70, size: 90),
            )
          : Image.network(
              user.pfp,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF253853),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white70,
                    size: 90,
                  ),
                );
              },
            ),
    );
  }

  // ===========================================================================
  // FIELDS
  // ===========================================================================

  Widget _buildFields(UserME user) {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          icon: Icons.person_outline,
          hint: 'Name',
        ),

        const SizedBox(height: 9),

        _buildTextField(
          controller: _lastNameController,
          icon: Icons.person_outline,
          hint: 'Lastname',
        ),

        const SizedBox(height: 9),

        _buildTextField(
          controller: _emailController,
          icon: Icons.alternate_email,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 9),

        _buildStatusDropdown(),

        const SizedBox(height: 9),

        _buildDateField(),

        const SizedBox(height: 9),

        _buildGenderDropdown(),

        const SizedBox(height: 9),

        _buildCreatedAtField(user),
      ],
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 29,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white, fontSize: 15),
          prefixIcon: Icon(icon, color: const Color(0xFFE0E4EA), size: 18),
          filled: true,
          fillColor: const Color(0xFF164C82),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }

  // ===========================================================================
  // STATUS
  // ===========================================================================

  Widget _buildStatusDropdown() {
    final bool valueExists =
        _selectedStatusId == null ||
        _userStatuses.any((status) => status.id == _selectedStatusId);

    return SizedBox(
      height: 29,
      child: DropdownButtonFormField<int>(
        initialValue: valueExists ? _selectedStatusId : null,
        dropdownColor: const Color(0xFF253853),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: _fieldDecoration(icon: Icons.help_outline),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
          size: 20,
        ),
        items: _userStatuses.map((status) {
          return DropdownMenuItem<int>(
            value: status.id,
            child: Text(status.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: _isSaving
            ? null
            : (value) {
                setState(() {
                  _selectedStatusId = value;
                });
              },
      ),
    );
  }

  // ===========================================================================
  // BIRTHDAY
  // ===========================================================================

  Widget _buildDateField() {
    return SizedBox(
      height: 29,
      child: Material(
        color: const Color(0xFF164C82),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: _isSaving ? null : _selectBirthday,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Row(
              children: [
                const Icon(
                  Icons.cake_outlined,
                  color: Color(0xFFE0E4EA),
                  size: 18,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    _birthday == null ? 'Birthday' : _formatDate(_birthday!),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
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
  // GENDER
  // ===========================================================================

  Widget _buildGenderDropdown() {
    final bool valueExists =
        _selectedGenderId == null ||
        _genders.any((gender) => gender.id == _selectedGenderId);

    return SizedBox(
      height: 29,
      child: DropdownButtonFormField<int>(
        initialValue: valueExists ? _selectedGenderId : null,
        dropdownColor: const Color(0xFF253853),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: _fieldDecoration(icon: Icons.person_outline),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
          size: 20,
        ),
        items: _genders.map((gender) {
          return DropdownMenuItem<int>(
            value: gender.id,
            child: Text(gender.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: _isSaving
            ? null
            : (value) {
                setState(() {
                  _selectedGenderId = value;
                });
              },
      ),
    );
  }

  // ===========================================================================
  // CREATED AT
  // ===========================================================================

  Widget _buildCreatedAtField(UserME user) {
    return Container(
      height: 29,
      decoration: BoxDecoration(
        color: const Color(0xFF164C82),
        borderRadius: BorderRadius.circular(7),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFFE0E4EA),
            size: 18,
          ),

          const SizedBox(width: 10),

          Text(
            _formatDateTime(user.createdAt),
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FIELD DECORATION
  // ===========================================================================

  InputDecoration _fieldDecoration({required IconData icon}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFFE0E4EA), size: 18),
      filled: true,
      fillColor: const Color(0xFF164C82),
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
      contentPadding: EdgeInsets.zero,
    );
  }

  // ===========================================================================
  // ORDERS
  // ===========================================================================

  Widget _buildOrders() {
    if (_ordersLoading) {
      return Container(
        height: 100,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 34),
        decoration: BoxDecoration(
          color: const Color(0xFF253853),
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    }

    if (_ordersError != null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 34),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF253853),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 24),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                _ordersError!,
                style: const TextStyle(color: Color(0xFF9DA6B5), fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Container(
        height: 100,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 34),
        decoration: BoxDecoration(
          color: const Color(0xFF253853),
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: const Text(
          'This user has no orders.',
          style: TextStyle(color: Color(0xFF9DA6B5), fontSize: 14),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Column(children: _orders.map(_buildOrderRow).toList()),
    );
  }

  // ===========================================================================
  // ORDER ROW
  // ===========================================================================

  Widget _buildOrderRow(OrderME order) {
    return Container(
      width: double.infinity,
      height: 42,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF253853),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          // -------------------------------------------------------------------
          // ORDER NUMBER
          // -------------------------------------------------------------------
          _buildOrderCell(
            width: 180,
            icon: Icons.shopping_bag_outlined,
            child: Text(
              '#${order.id}',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),

          // -------------------------------------------------------------------
          // USER
          // -------------------------------------------------------------------
          Expanded(
            flex: 2,
            child: _buildOrderCellContent(
              icon: Icons.person_outline,
              child: Text(
                order.userName.trim().isEmpty
                    ? '${order.userName}'
                    : order.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // DATE
          // -------------------------------------------------------------------
          Expanded(
            flex: 2,
            child: _buildOrderCellContent(
              icon: Icons.calendar_today_outlined,
              child: Text(
                _formatDateTime(order.dateTime),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // STATUS
          // -------------------------------------------------------------------
          Expanded(
            flex: 1,
            child: _buildOrderCellContent(
              icon: Icons.help_outline,
              child: Text(
                order.orderStatus.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // PRICE
          // -------------------------------------------------------------------
          SizedBox(
            width: 110,
            child: _buildOrderCellContent(
              icon: Icons.attach_money,
              child: Text(
                '${order.fullPrice.toStringAsFixed(2)}\$',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // VIEW ORDER
          // -------------------------------------------------------------------
          SizedBox(
            width: 212,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: () => _showOrderDetails(order),
                  icon: const Icon(Icons.visibility_outlined, size: 17),
                  label: const Text(
                    'View Order',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08192B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ORDER CELL
  // ===========================================================================

  Widget _buildOrderCell({
    required double width,
    required IconData icon,
    required Widget child,
  }) {
    return SizedBox(
      width: width,
      child: _buildOrderCellContent(icon: icon, child: child),
    );
  }

  Widget _buildOrderCellContent({
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF08111F), width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE0E4EA), size: 18),

          const SizedBox(width: 9),

          Expanded(child: child),
        ],
      ),
    );
  }

  // ===========================================================================
  // ORDER DETAILS DIALOG
  // ===========================================================================

  void _showOrderDetails(OrderME order) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF152236),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650, maxHeight: 700),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------------------
                  // HEADER
                  // -----------------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF164C82),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.orderStatus.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // -----------------------------------------------------------
                  // ORDER INFORMATION
                  // -----------------------------------------------------------
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

                  const SizedBox(height: 20),

                  const Divider(color: Color(0xFF34455F)),

                  const SizedBox(height: 14),

                  // -----------------------------------------------------------
                  // ITEMS
                  // -----------------------------------------------------------
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                                  color: Colors.white54,
                                  fontSize: 14,
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

                  const SizedBox(height: 18),

                  // -----------------------------------------------------------
                  // TOTAL
                  // -----------------------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF253853),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        Text(
                          '${order.fullPrice.toStringAsFixed(2)} KM',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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

  // ===========================================================================
  // DIALOG INFO ROW
  // ===========================================================================

  Widget _buildDialogInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFE0E4EA), size: 18),

        const SizedBox(width: 10),

        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF9DA6B5), fontSize: 13),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // DIALOG BLURAY
  // ===========================================================================

  Widget _buildDialogBluRay(OrderBluRayME item) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF253853),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // ---------------------------------------------------------------
          // IMAGE
          // ---------------------------------------------------------------
          Container(
            width: 45,
            height: 60,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF164C82),
              borderRadius: BorderRadius.circular(4),
            ),
            child: item.bluRay.image.trim().isEmpty
                ? const Icon(
                    Icons.movie_outlined,
                    color: Colors.white54,
                    size: 24,
                  )
                : Image.network(
                    item.bluRay.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.movie_outlined,
                        color: Colors.white54,
                        size: 24,
                      );
                    },
                  ),
          ),

          const SizedBox(width: 12),

          // ---------------------------------------------------------------
          // TITLE
          // ---------------------------------------------------------------
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Quantity: ${item.amount}',
                  style: const TextStyle(
                    color: Color(0xFFB8C0CC),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          // ---------------------------------------------------------------
          // PRICE
          // ---------------------------------------------------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.bluRay.price.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                'each',
                style: const TextStyle(color: Color(0xFF9DA6B5), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ERROR STATE
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

          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // ===========================================================================
  // DATE FORMATTING
  // ===========================================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year.toString().padLeft(4, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
