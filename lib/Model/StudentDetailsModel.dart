class UserData {
  final int id;
  final String name;
  final String photo;
  final String school;
  final String classCategory;
  final int parentId;
  final String place;
  final String homeName;
  final String vehicle;

  UserData({
    required this.id,
    required this.name,
    required this.photo,
    required this.school,
    required this.classCategory,
    required this.parentId,
    required this.place,
    required this.homeName,
    required this.vehicle,
  });

  // Add a factory method to create UserData from a Map
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      school: json['school'],
      classCategory: json['class_category'],
      parentId: json['parent_id'],
      place: json['address']['place'],
      homeName: json['address']['home_name'],
      vehicle: json['vehicle'],
    );
  }
}
