class Process {
  final int? id;
  final String? name;
  final String? nameMal;
  final String? description;
  final String? descriptionMal;

  Process({
    this.id,
    this.name,
    this.nameMal,
    this.description,
    this.descriptionMal,
  });

  factory Process.fromJson(Map<String, dynamic> json) {
    return Process(
      id: json['id'] as int?,
      name: json['name'] as String?,
      nameMal: json['name_mal'] as String?,
      description: json['description'] as String?,
      descriptionMal: json['description_mal'] as String?,
    );
  }
}
