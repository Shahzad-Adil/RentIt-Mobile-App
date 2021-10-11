class Terminal {
  late int id;
  late double longitude;
  late double latitude;
  late String name;
  late String description;

  Terminal(
      {required this.id, required this.longitude, required this.latitude, required this.name, required this.description});

  Terminal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> convetoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['name'] = this.name;
    data['description'] = this.description;
    return data;
  }


  Map<String, dynamic> convettoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['name'] = this.name;
    data['description'] = this.description;
    return data;
  }
}
