class Customer {
  late int  id ;
  late String name ;
  late String  userName ;
  late String  password ;
  late String   email ;
  late String  cnic ;
  late String phone ;
  late String description ;

  Customer(
      {required this.id,
        required this.name,
        required this.userName,
        required this.password,
        required this.email,
        required this.cnic,
        required this.phone,
        required this.description});


  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    userName = json['userName'];
    password = json['password'];
    email = json['email'];
    cnic = json['cnic'];
    phone = json['phone'];
    description = json['description'];
  }


  Map<String, dynamic> convertoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['userName'] = this.userName;
    data['password'] = this.password;
    data['email'] = this.email;
    data['cnic'] = this.cnic;
    data['phone'] = this.phone;
    data['description'] = this.description;
    return data;
  }


  Map<String, dynamic> convettoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id']=this.id;
    data['name'] = this.name;
    data['userName'] = this.userName;
    data['password'] = this.password;
    data['email'] = this.email;
    data['cnic'] = this.cnic;
    data['phone'] = this.phone;
    data['description'] = this.description;
    return data;
  }

}
