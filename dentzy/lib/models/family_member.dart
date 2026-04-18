
class FamilyMember {
  final String id;
  final String name;
  final int age;
  final String? relation; // e.g., Father, Mother, Child, Grandparent, Sibling
  final DateTime addedDate;

  FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    this.relation,
    required this.addedDate,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'relation': relation,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  // Create from JSON
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      relation: json['relation'] as String?,
      addedDate: DateTime.parse(json['addedDate'] as String),
    );
  }

  // Create a copy with modified fields
  FamilyMember copyWith({
    String? id,
    String? name,
    int? age,
    String? relation,
    DateTime? addedDate,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      relation: relation ?? this.relation,
      addedDate: addedDate ?? this.addedDate,
    );
  }
}
