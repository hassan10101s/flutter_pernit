import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/failure_message_localizer.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../notifications/presentation/bloc/notification_cubit.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../domain/entities/notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationTitle),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all_rounded),
                  tooltip: l10n.notificationMarkAllRead,
                  onPressed: () =>
                      context.read<NotificationCubit>().markAllRead(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {},
        builder: (context, state) {
          return switch (state) {
            NotificationInitial() || NotificationLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            NotificationLoaded s => _buildLoaded(l10n, s),
            NotificationError s => _buildError(l10n, s),
          };
        },
      ),
    );
  }

  Widget _buildLoaded(AppLocalizations l10n, NotificationLoaded state) {
    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64.r,
              color: PernitColors.textSubtle,
            ),
            verticalSpace(16),
            Text(
              l10n.notificationEmpty,
              style: TextStyle(color: PernitColors.textMuted, fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationCubit>().refresh();
        await context.read<NotificationCubit>().stream.firstWhere(
          (s) => s is NotificationLoaded || s is NotificationError,
        );
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            _onScroll();
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.notifications.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _NotificationItem(
              notification: state.notifications[index],
              onTap: () {
                context.read<NotificationCubit>().markRead(
                  state.notifications[index].id,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, NotificationError state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64.r, color: PernitColors.danger),
          verticalSpace(16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              FailureMessageLocalizer.messageFor(
                l10n,
                state.failure.messageKey,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: PernitColors.textMuted, fontSize: 16.sp),
            ),
          ),
          verticalSpace(16),
          FilledButton.tonalIcon(
            onPressed: () => context.read<NotificationCubit>().refresh(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.notificationRetry),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Notification notification;
  final VoidCallback onTap;

  const _NotificationItem({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: notification.isRead ? null : PernitColors.borderSoft,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _typeIcon(),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              fontSize: 14.sp,
                              color: PernitColors.textStrong,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        horizontalSpace(8),
                        Text(
                          _formatTime(l10n, notification.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: PernitColors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: PernitColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeIcon() {
    final (
      Color color,
      IconData icon,
    ) = switch (notification.notificationType) {
      NotificationType.success => (
        PernitColors.success,
        Icons.check_circle_outline,
      ),
      NotificationType.warning => (
        PernitColors.warning,
        Icons.warning_amber_outlined,
      ),
      NotificationType.error => (PernitColors.danger, Icons.error_outline),
      NotificationType.info => (PernitColors.primary, Icons.info_outline),
    };
    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18.r),
    );
  }

  String _formatTime(AppLocalizations l10n, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.notificationJustNow;
    if (diff.inMinutes < 60) return l10n.notificationMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.notificationHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.notificationDaysAgo(diff.inDays);
    return '${dt.month}/${dt.day}';
  }
}

Widget verticalSpace(double height) => SizedBox(height: height.h);
Widget horizontalSpace(double width) => SizedBox(width: width.w);
