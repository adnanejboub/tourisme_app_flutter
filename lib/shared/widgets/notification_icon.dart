import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/notification_model.dart';

class NotificationIcon extends StatefulWidget {
  final VoidCallback? onTap;
  final double size;
  final Color? color;

  const NotificationIcon({
    Key? key,
    this.onTap,
    this.size = 24.0,
    this.color,
  }) : super(key: key);

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  void _loadUnreadCount() {
    setState(() {
      _unreadCount = _notificationService.getUnreadCount();
    });
  }

  @override
  void didUpdateWidget(NotificationIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recharger le compteur quand le widget est mis à jour
    _loadUnreadCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Écoute en temps réel
    _notificationService.unreadCountNotifier.addListener(_loadUnreadCount);
  }

  @override
  void dispose() {
    _notificationService.unreadCountNotifier.removeListener(_loadUnreadCount);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Stack(
        children: [
          Icon(
            Icons.notifications_outlined,
            size: widget.size,
            color: widget.color ?? colorScheme.onSurface.withOpacity(0.7),
          ),
          if (_unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
