class TripModel {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<TripActivity> activities;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripModel({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.activities,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      destination: json['destination'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      activities: (json['activities'] as List<dynamic>?)
          ?.map((activity) => TripActivity.fromJson(activity))
          .toList() ?? [],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'destination': destination,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'activities': activities.map((activity) => activity.toMap()).toList(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TripModel copyWith({
    String? id,
    String? name,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    List<TripActivity>? activities,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      activities: activities ?? this.activities,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get duration => endDate.difference(startDate).inDays + 1;
}

class TripActivity {
  final String id;
  final String name;
  final String type; // 'attraction', 'restaurant', 'hotel', 'transport', 'custom'
  final String? description;
  final String? location;
  final DateTime? scheduledTime;
  final int? duration; // en minutes
  final String? imageUrl;
  final Map<String, dynamic>? metadata; // données supplémentaires selon le type

  TripActivity({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.location,
    this.scheduledTime,
    this.duration,
    this.imageUrl,
    this.metadata,
  });

  factory TripActivity.fromJson(Map<String, dynamic> json) {
    return TripActivity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'custom',
      description: json['description'],
      location: json['location'],
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime']) 
          : null,
      duration: json['duration'],
      imageUrl: json['imageUrl'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'location': location,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'duration': duration,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'location': location,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'duration': duration,
      'image_url': imageUrl,
      'metadata': metadata,
    };
  }

  TripActivity copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    String? location,
    DateTime? scheduledTime,
    int? duration,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return TripActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

