class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromMap(Map<String, dynamic> map) {
    return City(id: map['id'], name: map['name']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
