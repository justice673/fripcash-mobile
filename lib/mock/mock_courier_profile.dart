enum CourierDocumentStatus { approved, pending, rejected }

enum CourierDocumentType {
  nationalId,
  driversLicense,
  vehicleRegistration,
  insurance,
  profilePhoto,
}

class CourierDocument {
  const CourierDocument({
    required this.type,
    required this.status,
    required this.submittedAtLabel,
  });

  final CourierDocumentType type;
  final CourierDocumentStatus status;
  final String submittedAtLabel;
}

class CourierProfileDetails {
  const CourierProfileDetails({
    required this.courierId,
    required this.vehicleType,
    required this.plateNumber,
    required this.memberSinceLabel,
    required this.documents,
    this.isVerified = true,
  });

  final String courierId;
  final String vehicleType;
  final String plateNumber;
  final String memberSinceLabel;
  final List<CourierDocument> documents;
  final bool isVerified;
}

CourierProfileDetails courierProfileFor(String courierId) {
  return CourierProfileDetails(
    courierId: courierId,
    vehicleType: 'Motorcycle',
    plateNumber: 'GN-4821-KA',
    memberSinceLabel: 'March 2025',
    isVerified: true,
    documents: const [
      CourierDocument(
        type: CourierDocumentType.profilePhoto,
        status: CourierDocumentStatus.approved,
        submittedAtLabel: '12 Feb 2025',
      ),
      CourierDocument(
        type: CourierDocumentType.nationalId,
        status: CourierDocumentStatus.approved,
        submittedAtLabel: '12 Feb 2025',
      ),
      CourierDocument(
        type: CourierDocumentType.driversLicense,
        status: CourierDocumentStatus.approved,
        submittedAtLabel: '12 Feb 2025',
      ),
      CourierDocument(
        type: CourierDocumentType.vehicleRegistration,
        status: CourierDocumentStatus.pending,
        submittedAtLabel: '3 Jul 2026',
      ),
      CourierDocument(
        type: CourierDocumentType.insurance,
        status: CourierDocumentStatus.pending,
        submittedAtLabel: '3 Jul 2026',
      ),
    ],
  );
}
