class Machine {
  final String id;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  Machine({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Machine copyWith({
    String? id,
    String? name,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
