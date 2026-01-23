import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/request_model.dart';
import '../../../providers/active_request_provider.dart';
import '../../../providers/open_requests_provider.dart';
import '../../../utils/http_colors.dart';

class RequestTabsWidget extends ConsumerWidget {
  const RequestTabsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openRequestsAsync = ref.watch(openRequestsProvider);
    final activeRequest = ref.watch(activeRequestProvider);

    return openRequestsAsync.when(
      data: (openRequests) {
        if (openRequests.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: openRequests.length,
            itemBuilder: (context, index) {
              final request = openRequests[index];
              final isActive = activeRequest?.id == request.id;

              return _buildTab(context, ref, request, isActive);
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 40), // Placeholder while loading
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildTab(
      BuildContext context, WidgetRef ref, RequestModel request, bool isActive) {
    return InkWell(
      onTap: () {
        ref.read(openRequestsProvider.notifier).setActive(request);
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2D2D2D) : Colors.transparent,
          border: Border(
            right: const BorderSide(color: Colors.white10),
            top: isActive 
                ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2) 
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Text(
              request.method,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: HttpColors.getMethodColor(request.method),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                request.name.isNotEmpty ? request.name : 'Untitled',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isActive ? Colors.white : Colors.white54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref.read(openRequestsProvider.notifier).closeRequest(request);
              },
              hoverColor: Colors.white10,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close, size: 14, color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
