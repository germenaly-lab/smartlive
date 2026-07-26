class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final bool isLoggedIn;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.isLoggedIn = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    bool? isLoggedIn,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  factory UserModel.guest() {
    return UserModel(
      id: '',
      name: 'Guest User',
      email: '',
      photoUrl: '',
      isLoggedIn: false,
    );
  }
}
