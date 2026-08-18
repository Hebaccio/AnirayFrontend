import 'package:aniray_desktop/providers/entity_providers/request_provider.dart';
import 'package:aniray_desktop/screens/other_screens/request_details_screen.dart';
import 'package:aniray_desktop/widgets/main_sidebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:aniray_desktop/models/request/request_models.dart';
import 'package:aniray_desktop/providers/api_result.dart';
import 'package:aniray_desktop/requests/paged_result.dart';

class DashboardRequestsScreen extends StatefulWidget {
  const DashboardRequestsScreen({super.key, required this.title});

  final String title;

  @override
  State<DashboardRequestsScreen> createState() =>
      _DashboardRequestsScreenState();
}

class _DashboardRequestsScreenState extends State<DashboardRequestsScreen> {
  final RequestProvider _requestProvider = RequestProvider();

  final TextEditingController _searchController = TextEditingController();

  List<RequestME> _requests = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _page = 0;
  static const int _pageSize = 30;

  int _totalRequests = 0;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final search = RequestSOE(page: _page, pageSize: _pageSize);

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
        _isLoading = false;
        _errorMessage = result.message ?? 'Failed to load requests.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF08111F),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),

            const SizedBox(height: 36),

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 26, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 608),
            child: _buildSearchField(),
          ),

          const SizedBox(width: 22),

          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF20334E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Color(0xFF9AA5B5), fontSize: 18),
          prefixIcon: Icon(Icons.search, color: Color(0xFFE1E5EA), size: 28),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return SizedBox(
      width: 46,
      height: 42,
      child: Material(
        color: const Color(0xFF20334E),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () {
            // Filter functionality will be added later.
          },
          child: const Icon(Icons.tune, color: Color(0xFFE1E5EA), size: 26),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_requests.isEmpty) {
      return _buildEmptyState();
    }

    return _buildRequestGrid();
  }

  // ---------------------------------------------------------------------------
  // REQUEST GRID
  // ---------------------------------------------------------------------------

  Widget _buildRequestGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;

        if (constraints.maxWidth >= 1050) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 700) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(37, 0, 37, 30),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.82,
          ),
          itemCount: _requests.length,
          itemBuilder: (context, index) {
            return _buildRequestCard(_requests[index]);
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // REQUEST CARD
  // ---------------------------------------------------------------------------

  Widget _buildRequestCard(RequestME request) {
    return Material(
      color: const Color(0xFF405F8D),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RequestDetailsScreen(requestId: request.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
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

              // User
              _buildRequestInfoRow(
                icon: Icons.person_outline,
                text: request.userFullName,
              ),

              const SizedBox(height: 8),

              // Date
              _buildRequestInfoRow(
                icon: Icons.calendar_today_outlined,
                text: _formatDateTime(request.dateTime),
              ),

              const SizedBox(height: 10),

              // Description
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
  // EMPTY / ERROR
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, color: Colors.white38, size: 60),

          SizedBox(height: 16),

          Text(
            'No requests found',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 50),

          const SizedBox(height: 14),

          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),

          const SizedBox(height: 18),

          ElevatedButton(onPressed: _loadRequests, child: const Text('Retry')),
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
