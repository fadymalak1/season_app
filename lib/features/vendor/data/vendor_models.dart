class ServiceTypeModel {
  final int id;
  final String name;
  final bool isActive;

  ServiceTypeModel({required this.id, required this.name, required this.isActive});

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) => ServiceTypeModel(
        id: json['id'] as int,
        name: json['name'] as String,
        isActive: (json['is_active'] as bool?) ?? true,
      );
}

class VendorServiceSummary {
  final int id;
  final String name;
  final String status;

  VendorServiceSummary({required this.id, required this.name, required this.status});

  factory VendorServiceSummary.fromJson(Map<String, dynamic> json) => VendorServiceSummary(
        id: json['id'] as int,
        name: json['name'] as String,
        status: json['status']?.toString() ?? '',
      );
}

class VendorServiceDetails {
  final int id;
  final String serviceType;
  final String name;
  final String description;
  final String contactNumber;
  final String address;
  final String latitude;
  final String longitude;
  final String? commercialRegisterUrl;
  final List<String> images;
  final String status;

  VendorServiceDetails({
    required this.id,
    required this.serviceType,
    required this.name,
    required this.description,
    required this.contactNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.commercialRegisterUrl,
    required this.images,
    required this.status,
  });

  factory VendorServiceDetails.fromJson(Map<String, dynamic> json) => VendorServiceDetails(
        id: json['id'] as int,
        serviceType: json['service_type']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        contactNumber: json['contact_number']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        latitude: json['latitude']?.toString() ?? '',
        longitude: json['longitude']?.toString() ?? '',
        commercialRegisterUrl: json['commercial_register']?.toString(),
        images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        status: json['status']?.toString() ?? '',
      );
}


