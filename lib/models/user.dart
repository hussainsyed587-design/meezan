import 'dart:convert';

enum AuthType {
  email,
  google,
  apple,
  guest,
}

class User {
  final String id;
  final String email;
  final String name;
  final AuthType authType;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isFirstTime;
  final bool isEmailVerified;
  final Map<String, dynamic>? metadata;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.authType,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isFirstTime = true,
    this.isEmailVerified = false,
    this.metadata,
  });

  factory User.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      authType: AuthType.values.firstWhere(
        (e) => e.name == json['authType'],
        orElse: () => AuthType.guest,
      ),
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      isFirstTime: json['isFirstTime'] ?? true,
      isEmailVerified: json['isEmailVerified'] ?? false,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }

  String toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'email': email,
      'name': name,
      'authType': authType.name,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isFirstTime': isFirstTime,
      'isEmailVerified': isEmailVerified,
      'metadata': metadata,
    };
    return jsonEncode(json);
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    AuthType? authType,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isFirstTime,
    bool? isEmailVerified,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      authType: authType ?? this.authType,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name, authType: $authType}';
  }

  // Helper getters
  bool get isGuest => authType == AuthType.guest;
  bool get isAuthenticated => id.isNotEmpty;
  String get displayName => name.isNotEmpty ? name : email.split('@')[0];
  String get initials {
    if (name.isEmpty) return '?';
    final names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }
}