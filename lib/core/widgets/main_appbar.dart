import 'package:flutter/material.dart';
import '../utils/responsive_extension.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    super.key,
    required this.titleText,
    this.actions,
    this.showBackButton, 
    this.bottom,
    this.elevation = 0,
    this.scrolledUnderElevation = 0,
  });

  final String titleText;
  final List<Widget>? actions;
  final bool? showBackButton;
  final PreferredSizeWidget? bottom;
  final double elevation;
  final double scrolledUnderElevation;

  @override
  Widget build(BuildContext context) {
    // 💡 showBackButton이 명시되지 않았다면(null), 실제로 뒤로 갈 수 있는지(canPop) 자동 판단
    final bool canPop = showBackButton ?? Navigator.canPop(context);

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      title: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.desktopWidthSize),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // 💡 뒤로 갈 수 있는 상태일 때만 화살표 아이콘 노출 (박스 라인 안쪽 정렬)
                if (canPop) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    titleText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
      actions: const [SizedBox.shrink()],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}