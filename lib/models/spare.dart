class Spare {
  final String id;
  final String subunitId;
  final String serialNo;
  final String materialCode;
  final String materialName;
  final String partNo;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  Spare({
    required this.id,
    required this.subunitId,
    required this.serialNo,
    required this.materialCode,
    required this.materialName,
    required this.partNo,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subunit_id': subunitId,
      'serial_no': serialNo,
      'material_code': materialCode,
      'material_name': materialName,
      'part_no': partNo,
      'description': description ?? '',
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Spare.fromMap(Map<String, dynamic> map) {
    return Spare(
      id: map['id'] as String,
      subunitId: map['subunit_id'] as String,
      serialNo: map['serial_no'] as String,
      materialCode: map['material_code'] as String,
      materialName: map['material_name'] as String,
      partNo: map['part_no'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Spare copyWith({
    String? id,
    String? subunitId,
    String? serialNo,
    String? materialCode,
    String? materialName,
    String? partNo,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return Spare(
      id: id ?? this.id,
      subunitId: subunitId ?? this.subunitId,
      serialNo: serialNo ?? this.serialNo,
      materialCode: materialCode ?? this.materialCode,
      materialName: materialName ?? this.materialName,
      partNo: partNo ?? this.partNo,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
