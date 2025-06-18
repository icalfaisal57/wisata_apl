class TouristPlace {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int cityId;
  bool isFavorite; // Untuk menyimpan status favorit

  TouristPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cityId,
    this.isFavorite = false,
  });

  factory TouristPlace.fromMap(Map<String, dynamic> map) {
    return TouristPlace(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['image_url'],
      cityId: map['city_id'],
      isFavorite:
          map['is_favorite'] == 1, // SQLite menyimpan boolean sebagai 0/1
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'city_id': cityId,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }
}
