import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  List<NotificationModel> _notifications = [];
  // Notifie en temps réel le nombre de non lues
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  void _refreshUnreadCount() {
    unreadCountNotifier.value = getUnreadCount();
  }

  // Générer des notifications de démonstration
  void generateDemoNotifications() {
    _notifications = [
      NotificationModel(
        id: '1',
        title: '🌟 Nouvelle attraction à Casablanca',
        message: 'Découvrez la nouvelle exposition au Musée de la Villa des Arts !',
        type: 'news',
        createdAt: DateTime.now().subtract(Duration(minutes: 30)),
        imageUrl: 'https://images.unsplash.com/photo-1539650116574-75c0c6d73c6e?w=400',
        actionUrl: '/explore',
      ),
      NotificationModel(
        id: '2',
        title: '🎉 Promotion exceptionnelle',
        message: '20% de réduction sur tous les circuits de la ville jusqu\'à dimanche !',
        type: 'promotion',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
        actionUrl: '/marketplace',
      ),
      NotificationModel(
        id: '3',
        title: '📅 Événement à venir',
        message: 'Festival des musiques du monde à Casablanca - 3 jours de concerts gratuits !',
        type: 'event',
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        actionUrl: '/explore',
      ),
      NotificationModel(
        id: '4',
        title: '🌤️ Météo parfaite',
        message: 'Ensoleillé, 26°C à Casablanca - Idéal pour une visite en extérieur !',
        type: 'news',
        createdAt: DateTime.now().subtract(Duration(hours: 6)),
        imageUrl: 'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?w=400',
      ),
      NotificationModel(
        id: '5',
        title: '💡 Recommandation personnalisée',
        message: 'Basé sur votre localisation, nous vous recommandons la visite de la Mosquée Hassan II',
        type: 'news',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        imageUrl: 'https://images.unsplash.com/photo-1551524164-6cf77b0a0a6b?w=400',
        actionUrl: '/explore',
      ),
    ];
    _refreshUnreadCount();
  }

  // Récupérer toutes les notifications
  List<NotificationModel> getAllNotifications() {
    return _notifications;
  }

  // Récupérer les notifications non lues
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Compter les notifications non lues
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  // Marquer une notification comme lue
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
    _refreshUnreadCount();
  }

  // Marquer toutes les notifications comme lues
  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _refreshUnreadCount();
  }

  // Supprimer une notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _refreshUnreadCount();
  }
}
