// Path: lib/models/user.dart
class User {
  final int? id; // Nullable for new users before insertion
  final String username;
  final String password; // In real apps, store hashed password!

  User({this.id, required this.username, required this.password});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'password': password};
  }
}
