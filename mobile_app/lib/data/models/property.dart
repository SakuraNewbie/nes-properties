class Property {
  final String id;
  final String title;
  final String type;
  final double price;
  final PropertyLocation location;
  final int rooms;
  final int bedrooms;
  final int bathrooms;
  final double squareFeet;
  final String description;
  final String genderRestriction;
  final List<String> amenities;
  final List<PropertyImage> images;
  final bool featured;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.location,
    required this.rooms,
    required this.bedrooms,
    required this.bathrooms,
    required this.squareFeet,
    required this.description,
    required this.genderRestriction,
    required this.amenities,
    required this.images,
    required this.featured,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get primaryImageUrl {
    final primaryImage = images.where((img) => img.isPrimary).firstOrNull;
    return primaryImage?.imagePath ?? 
           (images.isNotEmpty ? images.first.imagePath : '');
  }

  List<PropertyImage> get regularImages {
    return images.where((img) => img.imageType == 'regular').toList();
  }

  List<PropertyImage> get panoramaImages {
    return images.where((img) => img.imageType == 'panorama').toList();
  }

  List<PropertyImage> get virtualTourImages {
    return images.where((img) => img.imageType == 'virtualTour').toList();
  }

  String get formattedPrice {
    return 'RM ${price.toStringAsFixed(0)}';
  }

  String get pricePerSqFt {
    if (squareFeet > 0) {
      final pricePerSqFt = price / squareFeet;
      return 'RM ${pricePerSqFt.toStringAsFixed(2)}/sq ft';
    }
    return '';
  }

  bool get hasVirtualTour {
    return virtualTourImages.isNotEmpty || panoramaImages.isNotEmpty;
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: PropertyLocation.fromJson(json['location'] ?? {}),
      rooms: json['rooms'] ?? 0,
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      squareFeet: (json['squareFeet'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      genderRestriction: json['genderRestriction'] ?? 'none',
      amenities: List<String>.from(json['amenities'] ?? []),
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => PropertyImage.fromJson(img))
          .toList() ?? [],
      featured: json['featured'] ?? false,
      ownerId: json['owner'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'price': price,
      'location': location.toJson(),
      'rooms': rooms,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'squareFeet': squareFeet,
      'description': description,
      'genderRestriction': genderRestriction,
      'amenities': amenities,
      'images': images.map((img) => img.toJson()).toList(),
      'featured': featured,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Property copyWith({
    String? id,
    String? title,
    String? type,
    double? price,
    PropertyLocation? location,
    int? rooms,
    int? bedrooms,
    int? bathrooms,
    double? squareFeet,
    String? description,
    String? genderRestriction,
    List<String>? amenities,
    List<PropertyImage>? images,
    bool? featured,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      price: price ?? this.price,
      location: location ?? this.location,
      rooms: rooms ?? this.rooms,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      squareFeet: squareFeet ?? this.squareFeet,
      description: description ?? this.description,
      genderRestriction: genderRestriction ?? this.genderRestriction,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      featured: featured ?? this.featured,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Property && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Property(id: $id, title: $title, type: $type, price: $formattedPrice)';
  }
}

class PropertyLocation {
  final String area;
  final String fullAddress;
  final double distanceToUSAS;
  final double? latitude;
  final double? longitude;

  PropertyLocation({
    required this.area,
    required this.fullAddress,
    required this.distanceToUSAS,
    this.latitude,
    this.longitude,
  });

  String get distanceToUSASFormatted {
    return '${distanceToUSAS.toStringAsFixed(1)} km to USAS';
  }

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    return PropertyLocation(
      area: json['area'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      distanceToUSAS: (json['distanceToUSAS'] ?? 0).toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'fullAddress': fullAddress,
      'distanceToUSAS': distanceToUSAS,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  PropertyLocation copyWith({
    String? area,
    String? fullAddress,
    double? distanceToUSAS,
    double? latitude,
    double? longitude,
  }) {
    return PropertyLocation(
      area: area ?? this.area,
      fullAddress: fullAddress ?? this.fullAddress,
      distanceToUSAS: distanceToUSAS ?? this.distanceToUSAS,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'PropertyLocation(area: $area, fullAddress: $fullAddress)';
  }
}

class PropertyImage {
  final String imagePath;
  final bool isPrimary;
  final String imageType;
  final String? altText;
  final DateTime createdAt;

  PropertyImage({
    required this.imagePath,
    required this.isPrimary,
    required this.imageType,
    this.altText,
    required this.createdAt,
  });

  String get fullImageUrl {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return 'http://localhost:3001/uploads/$imagePath';
  }

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      imagePath: json['imagePath'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      imageType: json['imageType'] ?? 'regular',
      altText: json['altText'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'isPrimary': isPrimary,
      'imageType': imageType,
      'altText': altText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PropertyImage copyWith({
    String? imagePath,
    bool? isPrimary,
    String? imageType,
    String? altText,
    DateTime? createdAt,
  }) {
    return PropertyImage(
      imagePath: imagePath ?? this.imagePath,
      isPrimary: isPrimary ?? this.isPrimary,
      imageType: imageType ?? this.imageType,
      altText: altText ?? this.altText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyImage && other.imagePath == imagePath;
  }

  @override
  int get hashCode => imagePath.hashCode;

  @override
  String toString() {
    return 'PropertyImage(imagePath: $imagePath, isPrimary: $isPrimary, imageType: $imageType)';
  }
}

// Extension for list operations
extension PropertyListExtension on List<Property> {
  List<Property> get featured {
    return where((property) => property.featured).toList();
  }

  List<Property> filterByType(String type) {
    return where((property) => property.type.toLowerCase() == type.toLowerCase()).toList();
  }

  List<Property> filterByPriceRange(double minPrice, double maxPrice) {
    return where((property) => 
      property.price >= minPrice && property.price <= maxPrice
    ).toList();
  }

  List<Property> filterByAmenity(String amenity) {
    return where((property) => 
      property.amenities.any((a) => a.toLowerCase().contains(amenity.toLowerCase()))
    ).toList();
  }

  List<Property> sortByPrice({bool ascending = true}) {
    final sorted = List<Property>.from(this);
    sorted.sort((a, b) => ascending 
        ? a.price.compareTo(b.price)
        : b.price.compareTo(a.price));
    return sorted;
  }

  List<Property> sortByDistance({bool ascending = true}) {
    final sorted = List<Property>.from(this);
    sorted.sort((a, b) => ascending 
        ? a.location.distanceToUSAS.compareTo(b.location.distanceToUSAS)
        : b.location.distanceToUSAS.compareTo(a.location.distanceToUSAS));
    return sorted;
  }
}