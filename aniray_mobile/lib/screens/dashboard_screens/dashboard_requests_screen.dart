import 'package:flutter/material.dart';

import '../../helpers/app_colors.dart';
import '../../providers/entity_providers/request_provider.dart';
import '../../requests_and_models/entity_r&m/request/request_models.dart';
import '../../requests_and_models/helper_r&m/api_result_helpers/api_result.dart';
import '../../requests_and_models/helper_r&m/paged_result/paged_result.dart';

class DashboardRequestsScreen extends StatefulWidget {
  const DashboardRequestsScreen({
    super.key,
    this.title,
    this.onRequestSelected,
  });

  final String? title;
  final void Function(int requestId)? onRequestSelected;

  @override
  State<DashboardRequestsScreen> createState() =>
      _DashboardRequestsScreenState();
}

class _DashboardRequestsScreenState extends State<DashboardRequestsScreen> {
  // ---------------------------------------------------------------------------
  // CONSTANTS
  // ---------------------------------------------------------------------------

  static const int _pageSize = 10;

  // ---------------------------------------------------------------------------
  // PROVIDER
  // ---------------------------------------------------------------------------

  final RequestProvider _requestProvider = RequestProvider();

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  List<RequestMU> _requests = [];

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

    _loadRequests();
  }

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------

  Future<void> _loadRequests() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // -------------------------------------------------------------------------
    // USER SEARCH OBJECT
    //
    // RequestSOU only contains:
    //
    // page
    // pageSize
    //
    // The backend determines the current user from the JWT/access token.
    // We do NOT send userId.
    // -------------------------------------------------------------------------

    final RequestSOU search = RequestSOU(page: _page, pageSize: _pageSize);

    final ApiResult<PagedResult<RequestMU>> result = await _requestProvider
        .getPagedEntityForUsers(search);

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      setState(() {
        _requests = result.data!.resultList;
        _totalRequests = result.data!.count;
        _isLoading = false;
        _errorMessage = null;
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

  // ---------------------------------------------------------------------------
  // ADD REQUEST
  // ---------------------------------------------------------------------------

  Future<void> _addRequest() async {
    final RequestAddResult? result = await showDialog<RequestAddResult>(
      context: context,
      builder: (context) {
        return const RequestAddDialog();
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final RequestIRU request = RequestIRU(
      title: result.title,
      text: result.text,
    );

    final ApiResult<RequestMU> response = await _requestProvider
        .insertEntityForUsers(request);

    if (!mounted) {
      return;
    }

    if (response.data != null) {
      setState(() {
        _page = 0;
      });

      await _loadRequests();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully.')),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response.message ?? 'Failed to submit request.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // OPEN REQUEST
  // ---------------------------------------------------------------------------

  Future<void> _openRequest(RequestMU request) async {
    final bool hasResponse =
        request.response != null && request.response!.trim().isNotEmpty;

    final bool needsToBeMarkedAsRead = hasResponse && !request.readByUser;

    // -------------------------------------------------------------------------
    // MARK RESPONSE AS READ
    //
    // The backend gets the current user from the JWT.
    //
    // Therefore:
    //
    // request.id -> identifies which request is being updated
    // RequestURU() -> contains no userId/data
    // JWT -> identifies the current user
    // -------------------------------------------------------------------------

    if (needsToBeMarkedAsRead) {
      final ApiResult<RequestMU> result = await _requestProvider
          .updateEntityForUsers(request.id, const RequestURU());

      if (!mounted) {
        return;
      }

      // -----------------------------------------------------------------------
      // If the backend update failed, do not open the request as if it was
      // successfully marked as read.
      // -----------------------------------------------------------------------

      if (result.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ?? 'Failed to mark the response as read.',
            ),
          ),
        );

        return;
      }

      // -----------------------------------------------------------------------
      // The backend successfully marked it as read.
      //
      // Update our local list immediately so the "New Response" badge
      // disappears without requiring another GET request.
      // -----------------------------------------------------------------------

      final int index = _requests.indexWhere((item) => item.id == request.id);

      if (index != -1) {
        final RequestMU updatedRequest = RequestMU(
          id: request.id,
          title: request.title,
          text: request.text,
          response: request.response,
          dateTime: request.dateTime,
          userId: request.userId,
          readByUser: true,
          userFullName: request.userFullName,
          userMail: request.userMail,
        );

        setState(() {
          _requests[index] = updatedRequest;
        });

        request = updatedRequest;
      }
    }

    if (!mounted) {
      return;
    }

    // -------------------------------------------------------------------------
    // OPEN REQUEST DETAILS
    // -------------------------------------------------------------------------

    await showDialog<void>(
      context: context,
      builder: (context) {
        return RequestDetailsDialog(request: request);
      },
    );

    // Optional callback if the parent screen still needs the request ID.
    widget.onRequestSelected?.call(request.id);
  }

  // ---------------------------------------------------------------------------
  // PAGINATION
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildContent(),

              if (_shouldShowPagination()) ...[
                const SizedBox(height: 10),
                _buildPagination(),
              ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'My Requests',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 12),

          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: _addRequest,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Add Request',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.backgroundTertiary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
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

    return _buildRequestList();
  }

  // ---------------------------------------------------------------------------
  // LOADING
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: AppColors.textPrimary),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REQUEST LIST
  // ---------------------------------------------------------------------------

  Widget _buildRequestList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: List.generate(_requests.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == _requests.length - 1 ? 0 : 14,
            ),
            child: _buildRequestCard(_requests[index]),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REQUEST CARD
  // ---------------------------------------------------------------------------

  Widget _buildRequestCard(RequestMU request) {
    final bool hasResponse =
        request.response != null && request.response!.trim().isNotEmpty;

    final bool needsAttention = hasResponse && !request.readByUser;

    return Material(
      color: const Color(0xFF405F8D),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openRequest(request),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------------------
                  // TITLE
                  // -----------------------------------------------------------
                  Text(
                    request.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // -----------------------------------------------------------
                  // DATE
                  // -----------------------------------------------------------
                  _buildRequestInfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: _formatDateTime(request.dateTime),
                  ),

                  const SizedBox(height: 12),

                  // -----------------------------------------------------------
                  // REQUEST TEXT
                  // -----------------------------------------------------------
                  Text(
                    request.text,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),

                  // -----------------------------------------------------------
                  // RESPONSE
                  // -----------------------------------------------------------
                  if (hasResponse) ...[
                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary.withValues(
                          alpha: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Response',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            request.response!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // RESPONSE BADGE
            // -----------------------------------------------------------------
            if (needsAttention)
              Positioned(
                top: -10,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mark_email_unread_outlined,
                        color: Colors.white,
                        size: 14,
                      ),

                      SizedBox(width: 5),

                      Text(
                        'New Response',
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
        Icon(icon, color: const Color(0xFFE3E8F0), size: 18),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PAGINATION
  // ---------------------------------------------------------------------------

  bool _shouldShowPagination() {
    return !_isLoading && _errorMessage == null && _requests.isNotEmpty;
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageButton(
            icon: Icons.first_page,
            enabled: _canGoPrevious,
            onPressed: _goToFirstPage,
          ),

          const SizedBox(width: 5),

          _buildPageButton(
            icon: Icons.chevron_left,
            enabled: _canGoPrevious,
            onPressed: _goToPreviousPage,
          ),

          const SizedBox(width: 14),

          _buildPageIndicator(),

          const SizedBox(width: 14),

          _buildPageButton(
            icon: Icons.chevron_right,
            enabled: _canGoNext,
            onPressed: _goToNextPage,
          ),

          const SizedBox(width: 5),

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
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
        color: enabled
            ? AppColors.backgroundSecondary
            : AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onPressed : null,
          child: Icon(
            icon,
            size: 21,
            color: enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR STATE
  // ---------------------------------------------------------------------------

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.textError,
              size: 50,
            ),

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

            ElevatedButton(
              onPressed: _loadRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              color: AppColors.textSecondary,
              size: 60,
            ),

            const SizedBox(height: 16),

            const Text(
              'You have no requests',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _addRequest,
              icon: const Icon(Icons.add),
              label: const Text('Add Request'),
            ),
          ],
        ),
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
// REQUEST ADD RESULT
// =============================================================================

class RequestAddResult {
  final String title;
  final String text;

  const RequestAddResult({required this.title, required this.text});
}

// =============================================================================
// REQUEST ADD DIALOG
// =============================================================================

class RequestAddDialog extends StatefulWidget {
  const RequestAddDialog({super.key});

  @override
  State<RequestAddDialog> createState() => _RequestAddDialogState();
}

class _RequestAddDialogState extends State<RequestAddDialog> {
  // ---------------------------------------------------------------------------
  // CONTROLLERS
  // ---------------------------------------------------------------------------

  late final TextEditingController _titleController;
  late final TextEditingController _textController;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();

    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();

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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),

              const SizedBox(height: 22),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'Enter request title',
                        maxLines: 1,
                      ),

                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: _textController,
                        label: 'Request',
                        hint: 'Describe your request',
                        maxLines: 7,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
        const Icon(
          Icons.add_comment_outlined,
          color: AppColors.textPrimary,
          size: 24,
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Text(
            'Add Request',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TEXT FIELD
  // ---------------------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: maxLines,
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
  // ACTIONS
  // ---------------------------------------------------------------------------

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.backgroundTertiary),
            ),
            child: const Text('Cancel'),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SUBMIT
  // ---------------------------------------------------------------------------

  void _submit() {
    final String title = _titleController.text.trim();

    final String text = _textController.text.trim();

    if (title.isEmpty) {
      _showValidationMessage('Please enter a title.');
      return;
    }

    if (text.isEmpty) {
      _showValidationMessage('Please enter your request.');
      return;
    }

    Navigator.of(context).pop(RequestAddResult(title: title, text: text));
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// =============================================================================
// REQUEST DETAILS DIALOG
// =============================================================================

class RequestDetailsDialog extends StatelessWidget {
  const RequestDetailsDialog({super.key, required this.request});

  final RequestMU request;

  @override
  Widget build(BuildContext context) {
    final bool hasResponse =
        request.response != null && request.response!.trim().isNotEmpty;

    return Dialog(
      backgroundColor: AppColors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),

              const SizedBox(height: 22),

              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -------------------------------------------------------
                      // TITLE
                      // -------------------------------------------------------
                      Text(
                        request.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // -------------------------------------------------------
                      // DATE
                      // -------------------------------------------------------
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: _formatDateTime(request.dateTime),
                      ),

                      const SizedBox(height: 20),

                      // -------------------------------------------------------
                      // REQUEST
                      // -------------------------------------------------------
                      const Text(
                        'Your Request',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          request.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),

                      // -------------------------------------------------------
                      // RESPONSE
                      // -------------------------------------------------------
                      if (hasResponse) ...[
                        const SizedBox(height: 20),

                        const Text(
                          'Response',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundTertiary,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            request.response!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundTertiary.withValues(
                              alpha: 0.55,
                            ),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.hourglass_empty,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),

                              SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  'No response yet.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.description_outlined,
          color: AppColors.textPrimary,
          size: 24,
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Text(
            'Request Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // INFO ROW
  // ---------------------------------------------------------------------------

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE3E8F0), size: 18),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DATE FORMAT
  // ---------------------------------------------------------------------------

  String _formatDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');

    final day = dateTime.day.toString().padLeft(2, '0');

    final hour = dateTime.hour.toString().padLeft(2, '0');

    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$month/$day/${dateTime.year} $hour:$minute';
  }
}
