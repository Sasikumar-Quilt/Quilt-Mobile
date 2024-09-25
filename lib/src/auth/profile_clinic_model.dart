class ProfileClinicModel {
  final String id;
  final String clinicName;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool isSelected;

  ProfileClinicModel({
    required this.id,
    required this.clinicName,
    required this.createdAt,
    required this.updatedAt,
    required this.isSelected,
  });

  factory ProfileClinicModel.fromJson(Map<String, dynamic> json) {
    return ProfileClinicModel(
      id: json['id'],
      clinicName: json['clinicName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSelected: false
    );
  }
}
