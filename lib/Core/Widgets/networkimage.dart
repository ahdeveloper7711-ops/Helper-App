import 'package:flutter/material.dart';

/// Reusable image widget: loading spinner + tap-to-retry on failure.
/// Flaky network (jaisa is app ke test mein dekha gaya) mein image
/// hamesha ke liye fail nahi rehti — user tap karke dobara try kar sakta hai.
class NetworkImageRetry extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final Widget Function(BuildContext context)? placeholderIconBuilder;

  const NetworkImageRetry({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholderIconBuilder,
  });

  @override
  State<NetworkImageRetry> createState() => _NetworkImageRetryState();
}

class _NetworkImageRetryState extends State<NetworkImageRetry> {
  int _retryToken = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Image.network(
      widget.url,
      key: ValueKey('${widget.url}_$_retryToken'),
      fit: widget.fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.primaryColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return GestureDetector(
          onTap: () => setState(() => _retryToken++),
          child: Container(
            alignment: Alignment.center,
            color: theme.primaryColor.withOpacity(0.08),
            child: widget.placeholderIconBuilder?.call(context) ??
                Icon(Icons.refresh_rounded, color: theme.primaryColor.withOpacity(0.7)),
          ),
        );
      },
    );
  }
}