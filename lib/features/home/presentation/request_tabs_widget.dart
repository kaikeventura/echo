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
    final colorScheme = Theme.of(context).colorScheme;

    return openRequestsAsync.when(
      data: (openRequests) {
        if (openRequests.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surface, // Cor de fundo dinâmica
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
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
      loading: () => const SizedBox(height: 40),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref, RequestModel request, Offset tapPosition) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final colorScheme = Theme.of(context).colorScheme;
    
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        tapPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: colorScheme.surface,
      items: [
        PopupMenuItem(
          value: 'close_all',
          height: 32,
          child: Text('Close All Tabs', style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
        ),
        PopupMenuItem(
          value: 'close_left',
          height: 32,
          child: Text('Close Tabs to the Left', style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
        ),
        PopupMenuItem(
          value: 'close_right',
          height: 32,
          child: Text('Close Tabs to the Right', style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
        ),
      ],
    ).then((value) {
      if (value == null) return;
      
      final notifier = ref.read(openRequestsProvider.notifier);
      switch (value) {
        case 'close_all':
          notifier.closeAll();
          break;
        case 'close_left':
          notifier.closeTabsToLeft(request);
          break;
        case 'close_right':
          notifier.closeTabsToRight(request);
          break;
      }
    });
  }

  Widget _buildTab(
      BuildContext context, WidgetRef ref, RequestModel request, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        ref.read(openRequestsProvider.notifier).setActive(request);
      },
      onSecondaryTapDown: (details) {
        _showContextMenu(context, ref, request, details.globalPosition);
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          border: Border(
            right: BorderSide(color: Theme.of(context).dividerColor),
            top: isActive 
                ? BorderSide(color: colorScheme.primary, width: 2) 
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
                  color: isActive ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.6),
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
              hoverColor: colorScheme.onSurface.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.close, size: 14, color: colorScheme.onSurface.withOpacity(0.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
