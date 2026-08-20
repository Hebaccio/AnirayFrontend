import 'package:aniray_desktop/providers/entity_providers/request_provider.dart';
import 'package:flutter/material.dart';
import 'package:aniray_desktop/models/request/request_models.dart';
import 'package:aniray_desktop/providers/api_result.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key, required this.requestId, this.onBack});

  final int requestId;
  final VoidCallback? onBack;

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final RequestProvider _requestProvider = RequestProvider();

  final TextEditingController _responseController = TextEditingController();

  RequestME? _request;

  bool _isLoading = true;
  bool _isSendingResponse = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
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

  bool _canReply(RequestME request) {
    return request.response == null || request.response!.trim().isEmpty;
  }

  Future<void> _sendResponse() async {
    final String response = _responseController.text.trim();

    if (response.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a response.')));

      return;
    }

    setState(() {
      _isSendingResponse = true;
    });

    final ApiResult<RequestME> result = await _requestProvider
        .updateEntityForEmployees(
          widget.requestId,
          RequestURE(response: response),
        );

    if (!mounted) {
      return;
    }

    if (result.data != null) {
      setState(() {
        _request = result.data;
        _responseController.clear();
        _isSendingResponse = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response sent successfully.')),
      );
    } else {
      setState(() {
        _isSendingResponse = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Failed to send response.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFF08111F), child: _buildContent());
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
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(45, 30, 45, 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildRequestCard(request),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: widget.onBack,
            tooltip: 'Back',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
      ),
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

          if (_canReply(request)) ...[
            const SizedBox(height: 28),

            _buildResponseInput(),
          ],
        ],
      ),
    );
  }

  Widget _buildResponseInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Reply',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _responseController,
          minLines: 4,
          maxLines: 8,
          enabled: !_isSendingResponse,
          style: const TextStyle(
            color: Color(0xFFE1E5EA),
            fontSize: 15,
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: 'Write your response...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
            filled: true,
            fillColor: const Color(0xFF08111F),
            contentPadding: const EdgeInsets.all(18),
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
              borderSide: const BorderSide(color: Colors.white24),
            ),
          ),
        ),

        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: _isSendingResponse ? null : _sendResponse,
          icon: _isSendingResponse
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send_outlined),
          label: Text(_isSendingResponse ? 'Sending...' : 'Send Reply'),
        ),
      ],
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
