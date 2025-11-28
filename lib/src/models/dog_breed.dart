class DogBreed {
  final String id;
  final String name;
  final String temperament;
  final String lifeSpan;
  final String origin;
  final String group;
  final String imageUrl;

  DogBreed({
    required this.id,
    required this.name,
    required this.temperament,
    required this.lifeSpan,
    required this.origin,
    required this.group,
    required this.imageUrl,
  });

  factory DogBreed.fromJson(Map<String, dynamic> json) {
    return DogBreed(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? 'Desconocida',
      temperament: json['temperament'] ?? 'No especificado',
      lifeSpan: json['life_span'] ?? 'No especificado',
      origin: json['origin'] ?? 'No especificado',
      group: json['breed_group'] ?? 'No especificado',
      imageUrl: (json['image'] != null && json['image']['url'] != null)
          ? json['image']['url']
          : '',
    );
  }
}
