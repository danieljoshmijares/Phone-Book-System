class Contact {
  String? id; // Firestore document ID
  String name;
  String number;
  String tel;
  String address;
  String? imageUrl;

  // Dynamic custom fields
  Map<String, String> customFields;

  Contact({
    this.id,
    required this.name,
    required this.number,
    required this.tel,
    required this.address,
    this.imageUrl,
    Map<String, String>? customFields,
  }) : customFields = Map<String, String>.from(customFields ?? {});

  Contact copyWith({
    String? id,
    String? name,
    String? number,
    String? tel,
    String? address,
    String? imageUrl,
    Map<String, String>? customFields,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      tel: tel ?? this.tel,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,

      // IMPORTANT: deep copy the map
      customFields: customFields != null
          ? Map<String, String>.from(customFields)
          : Map<String, String>.from(this.customFields),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      number: json['number'],
      tel: json['tel'],
      address: json['address'],
      imageUrl: json['imageUrl'],

      // Already safe
      customFields: Map<String, String>.from(json['customFields'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'tel': tel,
      'address': address,
      'imageUrl': imageUrl,

      // Safe (Dart JSON encoder copies map anyway)
      'customFields': customFields,
    };
  }
}
