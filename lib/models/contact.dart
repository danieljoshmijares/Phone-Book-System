class Contact {
  String name;
  String number;
  String tel;
  String address;

  Contact({
    required this.name,
    required this.number,
    required this.tel,
    required this.address,
  });

  // Convert Contact to JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'tel': tel,
      'address': address,
    };
  }

  // Create Contact from JSON (Map)
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      tel: json['tel'] ?? '',
      address: json['address'] ?? '',
    );
  }
}