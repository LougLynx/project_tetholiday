/// DTO cho thông tin user từ API login.
class UserDto {
  final String id;
  final String email;
  final String? name;

  const UserDto({
    required this.id,
    required this.email,
    this.name,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };
}
