import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/notification_model.dart';

class NotificationDrawer extends StatefulWidget {
  final VoidCallback? onClose;
  final double initialHeight;

  const NotificationDrawer({
    Key? key,
    this.onClose,
    this.initialHeight = 0.6, // 60% de la hauteur de l'écran
  }) : super(key: key);

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer>
    with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  
  // Variables pour le geste flexible
  double _currentHeight = 0.6;
  double _minHeight = 0.3; // 30% minimum
  double _maxHeight = 0.9; // 90% maximum
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.initialHeight;
    _setupAnimations();
    _loadNotifications();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _notificationService.getAllNotifications();
      _isLoading = false;
    });
  }

  void _markAsRead(NotificationModel notification) {
    _notificationService.markAsRead(notification.id);
    _loadNotifications();
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
    _loadNotifications();
  }

  void _closeDrawer() {
    _animationController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final delta = details.delta.dy / screenHeight;
    
    setState(() {
      _currentHeight = (_currentHeight - delta).clamp(_minHeight, _maxHeight);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;
    
    final velocity = details.velocity.pixelsPerSecond.dy;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Si la vélocité est forte vers le bas, fermer le drawer
    if (velocity > 500) {
      _closeDrawer();
      return;
    }
    
    // Si la vélocité est forte vers le haut, maximiser
    if (velocity < -500) {
      setState(() {
        _currentHeight = _maxHeight;
      });
      return;
    }
    
    // Sinon, ajuster selon la position actuelle
    if (_currentHeight < (_minHeight + _maxHeight) / 2) {
      _closeDrawer();
    } else if (_currentHeight < (_minHeight + _maxHeight) * 0.7) {
      setState(() {
        _currentHeight = _minHeight;
      });
    } else {
      setState(() {
        _currentHeight = _maxHeight;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: _closeDrawer,
      child: Container(
        // Flou de fond pour un look futuriste
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35)),
        child: GestureDetector(
          onTap: () {}, // Empêche la fermeture quand on tape sur le drawer
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Container(
                    height: screenHeight * _currentHeight,
                    decoration: BoxDecoration(
                      // Carte translucide avec blur léger
                      color: colorScheme.surface.withOpacity(0.95),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle bar avec indicateur de position
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _isDragging 
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(height: 8),
                              // Indicateurs de position
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildPositionIndicator(_minHeight, 'Min'),
                                  SizedBox(width: 20),
                                  _buildPositionIndicator(0.6, 'Mid'),
                                  SizedBox(width: 20),
                                  _buildPositionIndicator(_maxHeight, 'Max'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      
                        // Header
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_notifications.isNotEmpty)
                                    TextButton(
                                      onPressed: _markAllAsRead,
                                      child: Text(
                                        'Tout marquer comme lu',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    onPressed: _closeDrawer,
                                    icon: Icon(
                                      Icons.close,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Content
                        Expanded(
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: colorScheme.primary,
                                  ),
                                )
                              : _notifications.isEmpty
                                  ? _buildEmptyState(colorScheme)
                                  : _buildNotificationsList(colorScheme),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionIndicator(double height, String label) {
    final isActive = (_currentHeight - height).abs() < 0.05;
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentHeight = height;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive 
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive 
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.5),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 24),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vous serez notifié des nouvelles actualités\net informations importantes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(ColorScheme colorScheme) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        // Swipe pour supprimer
        return Dismissible(
          key: ValueKey(notification.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            _notificationService.removeNotification(notification.id);
            _loadNotifications();
          },
          background: Container(
            margin: EdgeInsets.only(bottom: 12),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: _buildNotificationCard(notification, colorScheme),
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, ColorScheme colorScheme) {
    return AnimatedContainer(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? colorScheme.surfaceVariant.withOpacity(0.3)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead 
              ? colorScheme.outline.withOpacity(0.2)
              : colorScheme.primary.withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _markAsRead(notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône de type
                AnimatedContainer(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: _getTypeColor(notification.type),
                    size: 20,
                  ),
                  duration: Duration(milliseconds: 250),
                ),
                SizedBox(width: 12),
                
                // Contenu
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
                                fontSize: 16,
                                fontWeight: notification.isRead 
                                    ? FontWeight.w500 
                                    : FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        notification.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Image (si disponible)
                if (notification.imageUrl != null) ...[
                  SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      notification.imageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'news':
        return Colors.blue;
      case 'promotion':
        return Colors.orange;
      case 'event':
        return Colors.green;
      case 'update':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'news':
        return Icons.newspaper_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'event':
        return Icons.event_outlined;
      case 'update':
        return Icons.system_update_outlined;
      default:
        return Icons.info_outlined;
    }
  }
}