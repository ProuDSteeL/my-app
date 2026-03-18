import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: NavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: [
          NavigationDestination(
            icon: PhosphorIcon(
              PhosphorIconsThin.house,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            selectedIcon: PhosphorIcon(
              PhosphorIconsFill.house,
              color: theme.colorScheme.primary,
            ),
            label: 'Главная',
            tooltip: 'Главная',
          ),
          NavigationDestination(
            icon: PhosphorIcon(
              PhosphorIconsThin.magnifyingGlass,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            selectedIcon: PhosphorIcon(
              PhosphorIconsFill.magnifyingGlass,
              color: theme.colorScheme.primary,
            ),
            label: 'Поиск',
            tooltip: 'Поиск',
          ),
          NavigationDestination(
            icon: PhosphorIcon(
              PhosphorIconsThin.bookmarkSimple,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            selectedIcon: PhosphorIcon(
              PhosphorIconsFill.bookmarkSimple,
              color: theme.colorScheme.primary,
            ),
            label: 'Полки',
            tooltip: 'Полки',
          ),
          NavigationDestination(
            icon: PhosphorIcon(
              PhosphorIconsThin.downloadSimple,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            selectedIcon: PhosphorIcon(
              PhosphorIconsFill.downloadSimple,
              color: theme.colorScheme.primary,
            ),
            label: 'Загрузки',
            tooltip: 'Загрузки',
          ),
          NavigationDestination(
            icon: PhosphorIcon(
              PhosphorIconsThin.userCircle,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            selectedIcon: PhosphorIcon(
              PhosphorIconsFill.userCircle,
              color: theme.colorScheme.primary,
            ),
            label: 'Профиль',
            tooltip: 'Профиль',
          ),
        ],
      ),
    );
  }
}
