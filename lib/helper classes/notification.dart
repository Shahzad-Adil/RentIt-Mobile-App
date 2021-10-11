class CustomNotification {
  late int id;
  late String email;
  late String? token;

  CustomNotification({required this.id, required this.email, required this.token});

  CustomNotification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    token = json['token'];
  }

  Map<String, dynamic> convertoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['token'] = this.token;
    return data;
  }
}
