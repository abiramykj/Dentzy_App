class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String languagePreference;
  final DateTime createdAt;
  final int mythsChecked;
  final double accuracyRate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.languagePreference = 'en',
    required this.createdAt,
    this.mythsChecked = 0,
    this.accuracyRate = 0.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
      languagePreference: json['languagePreference'] ?? 'en',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      mythsChecked: json['mythsChecked'] ?? 0,
      accuracyRate: (json['accuracyRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'languagePreference': languagePreference,
      'createdAt': createdAt.toIso8601String(),
      'mythsChecked': mythsChecked,
      'accuracyRate': accuracyRate,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? languagePreference,
    DateTime? createdAt,
    int? mythsChecked,
    double? accuracyRate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      languagePreference: languagePreference ?? this.languagePreference,
      createdAt: createdAt ?? this.createdAt,
      mythsChecked: mythsChecked ?? this.mythsChecked,
      accuracyRate: accuracyRate ?? this.accuracyRate,
    );
  }
}
