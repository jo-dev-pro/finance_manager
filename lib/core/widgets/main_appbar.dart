import 'package:flutter/material.dart';
import '../utils/responsive_extension.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    super.key,
    required this.titleText,
    this.actions,
    this.showBackButton,
    this.onBackPressed,
    this.bottom,
    this.elevation = 0,
    this.scrolledUnderElevation = 0,
  });

  final String titleText;
  final List<Widget>? actions;
  final bool? showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final double elevation;
  final double scrolledUnderElevation;

  @override
  Widget build(BuildContext context) {
    final bool canPop = showBackButton ?? Navigator.canPop(context);

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      title: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.desktopWidthSize),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                if (canPop) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    titleText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}