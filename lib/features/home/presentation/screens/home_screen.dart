import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../features/notifications/presentation/widgets/notification_badge_widget.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/bloc/logout_cubit.dart';
import '../../../auth/presentation/bloc/logout_state.dart';
import '../../domain/entities/home_menu_section.dart';
import '../widgets/home_desktop_menu.dart';
import '../widgets/home_desktop_section_header.dart';
import '../widgets/home_mobile_menu.dart';
import '../widgets/home_section_body.dart';

class HomeScreen extends StatefulWidget {
  final AuthUser user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _selectSection(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = HomeMenuPolicy(widget.user.groups).visibleSections();
    final selectedIndex = _selectedIndex.clamp(0, sections.length - 1).toInt();
    final selectedSection = sections[selectedIndex];

    return BlocConsumer<LogoutCubit, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          context.pushNamedAndRemoveAll(Routes.login);
        }
      },
      builder: (context, state) {
        final isLoggingOut = state is LogoutSubmitting;

        return LayoutBuilder(
          builder: (context, constraints) {
            final useDesktopMenu = constraints.maxWidth >= 760;

            if (useDesktopMenu) {
              return Scaffold(
                body: SafeArea(
                  child: Row(
                    children: [
                      HomeDesktopMenu(
                        user: widget.user,
                        sections: sections,
                        selectedIndex: selectedIndex,
                        isLoggingOut: isLoggingOut,
                        labelForSection: (section) =>
                            _labelForSection(l10n, section),
                        iconForSection: _iconForSection,
                        onSelected: _selectSection,
                        onLogout: () => context.read<LogoutCubit>().logout(),
                      ),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: PernitColors.border,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            HomeDesktopSectionHeader(
                              title: _labelForSection(l10n, selectedSection),
                              icon: _iconForSection(selectedSection),
                              actions: [
                                NotificationBadgeWidget(
                                  onTap: () =>
                                      context.pushNamed(Routes.notifications),
                                ),
                              ],
                            ),
                            Expanded(
                              child: HomeSectionBody(
                                section: selectedSection,
                                user: widget.user,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text(_labelForSection(l10n, selectedSection)),
                actions: [
                  NotificationBadgeWidget(
                    onTap: () => context.pushNamed(Routes.notifications),
                  ),
                  IconButton(
                    tooltip: l10n.homeLogoutTooltip,
                    onPressed: isLoggingOut
                        ? null
                        : () => context.read<LogoutCubit>().logout(),
                    icon: isLoggingOut
                        ? SizedBox.square(
                            dimension: 18.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.logout_rounded),
                  ),
                ],
              ),
              body: HomeSectionBody(
                section: selectedSection,
                user: widget.user,
              ),
              bottomNavigationBar: HomeMobileMenu(
                sections: sections,
                selectedIndex: selectedIndex,
                labelForSection: (section) => _labelForSection(l10n, section),
                iconForSection: _iconForSection,
                onSelected: _selectSection,
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconForSection(HomeMenuSection section) {
    return switch (section) {
      HomeMenuSection.overview => Icons.dashboard_outlined,
      HomeMenuSection.inventory => Icons.inventory_2_outlined,
      HomeMenuSection.quality => Icons.verified_outlined,
      HomeMenuSection.production => Icons.factory_outlined,
      HomeMenuSection.commercial => Icons.move_to_inbox_outlined,
      HomeMenuSection.settings => Icons.settings_outlined,
    };
  }

  String _labelForSection(AppLocalizations l10n, HomeMenuSection section) {
    return switch (section) {
      HomeMenuSection.overview => l10n.menuOverview,
      HomeMenuSection.inventory => l10n.menuInventory,
      HomeMenuSection.quality => l10n.menuQuality,
      HomeMenuSection.production => l10n.menuProduction,
      HomeMenuSection.commercial => l10n.menuCommercial,
      HomeMenuSection.settings => l10n.menuSettings,
    };
  }
}
