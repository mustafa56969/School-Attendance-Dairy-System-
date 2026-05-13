import 'package:flutter/material.dart';
import '../theme/playful_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final double size;

  const LoadingWidget({super.key, this.message = 'Loading...', this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Beautiful custom loading animation
          SizedBox(
            width: size,
            height: size,
            child: CustomLoadingIndicator(
              color: PlayfulTheme.primaryTeal,
              size: size,
            ),
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: PlayfulTheme.textMain,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CustomLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const CustomLoadingIndicator({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing circle
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2 * (1 - _controller.value)),
                shape: BoxShape.circle,
              ),
            ),
            // Inner rotating circles
            Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: Stack(
                children: [
                  for (int i = 0; i < 8; i++)
                    Transform.rotate(
                      angle: i * 3.14159 / 4,
                      child: Transform.translate(
                        offset: Offset(0, -widget.size * 0.3),
                        child: Container(
                          width: widget.size * 0.15,
                          height: widget.size * 0.15,
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(
                              1.0 - (i / 8) * _controller.value,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Center circle
            Container(
              width: widget.size * 0.4,
              height: widget.size * 0.4,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: PlayfulTheme.textMain,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: PlayfulTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;

  const EmptyStateWidget({
    super.key,
    this.title = 'No Data',
    this.message = 'There is no data to display',
    this.icon = Icons.info_outline,
    this.iconColor = PlayfulTheme.primaryTeal,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: PlayfulTheme.textMain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: PlayfulTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
