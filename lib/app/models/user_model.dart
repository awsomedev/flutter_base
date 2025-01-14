class User {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final int? age;
  final bool? isAdmin;
  final double? salaryPerHr;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.isAdmin,
    this.salaryPerHr,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      age: json['age'] as int?,
      isAdmin: json['isAdmin'] as bool?,
      salaryPerHr: json['salary_per_hr'] != null
          ? (json['salary_per_hr'] as num).toDouble()
          : null,
    );
  }
}
