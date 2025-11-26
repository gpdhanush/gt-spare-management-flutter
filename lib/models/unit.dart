class Unit {
  final String id;
  final String machineId;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  Unit({
    required this.id,
    required this.machineId,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machine_id': machineId,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'] as String,
      machineId: map['machine_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Unit copyWith({
    String? id,
    String? machineId,
    String? name,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return Unit(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
