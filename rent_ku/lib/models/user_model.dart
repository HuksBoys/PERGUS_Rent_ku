class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? profilePhoto;
  final String? profilePhotoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePhoto,
    this.profilePhotoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user',
      profilePhoto: json['profile_photo'],
      profilePhotoUrl: json['profile_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_photo': profilePhoto,
    };
  }
}
