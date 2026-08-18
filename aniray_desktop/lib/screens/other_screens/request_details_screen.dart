import 'package:aniray_desktop/providers/entity_providers/request_provider.dart';
import 'package:flutter/material.dart';
import 'package:aniray_desktop/models/request/request_models.dart';
import 'package:aniray_desktop/providers/api_result.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key, required this.requestId});

  final int requestId;

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final RequestProvider _requestProvider = RequestProvider();

  RequestME? _request;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final ApiResult<RequestME> result = await _requestProvider
        .entityGetByIdForEmployees(widget.requestId);

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      setState(() {
        _request = result.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _request = null;
        _isLoading = false;
        _errorMessage = result.message ?? 'Failed to load request.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF08111F),
      child: SafeArea(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_request == null) {
      return const Center(
        child: Text(
          'Request not found.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    return _buildRequestDetails(_request!);
  }

  Widget _buildRequestDetails(RequestME request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(45, 30, 45, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 30),

              _buildRequestCard(request),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
        ),

        const SizedBox(width: 8),

        const Text(
          'Request Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(RequestME request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 25, 28, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF152236),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 25),

          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'User',
            value: request.userFullName,
          ),

          const SizedBox(height: 15),

          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: request.userMail,
          ),

          const SizedBox(height: 15),

          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _formatDateTime(request.dateTime),
          ),

          const SizedBox(height: 28),

          const Divider(color: Colors.white12),

          const SizedBox(height: 25),

          const Text(
            'Request',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF08111F),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              request.text,
              style: const TextStyle(
                color: Color(0xFFE1E5EA),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),

          if (request.response != null &&
              request.response!.trim().isNotEmpty) ...[
            const SizedBox(height: 28),

            const Text(
              'Response',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF08111F),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                request.response!,
                style: const TextStyle(
                  color: Color(0xFFE1E5EA),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ],

          const SizedBox(height: 25),

          _buildReadStatus(request),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFE1E5EA), size: 20),

        const SizedBox(width: 12),

        Text(
          '$label:',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildReadStatus(RequestME request) {
    return Row(
      children: [
        Icon(
          request.readByStaff
              ? Icons.mark_email_read_outlined
              : Icons.mark_email_unread_outlined,
          color: request.readByStaff ? Colors.greenAccent : Colors.orangeAccent,
          size: 20,
        ),

        const SizedBox(width: 10),

        Text(
          request.readByStaff ? 'Read by staff' : 'Not read by staff',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
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

          ElevatedButton(onPressed: _loadRequest, child: const Text('Retry')),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$month/$day/${dateTime.year} $hour:$minute';
  }
}
