import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum WorkerRole { technician, engineer, supervisor, helper }

extension WorkerRoleExt on WorkerRole {
  String get label {
    switch (this) {
      case WorkerRole.technician:
        return 'تکنسین';
      case WorkerRole.engineer:
        return 'مهندس';
      case WorkerRole.supervisor:
        return 'سرپرست';
      case WorkerRole.helper:
        return 'کمک';
    }
  }
}

class Worker extends Equatable {
  final int? id;
  final String name;
  final String nationalCode;
  final String phone;
  final WorkerRole role;
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  final DateTime createdAt;
  final bool isActive;

  const Worker({
    this.id,
    required this.name,
    required this.nationalCode,
    required this.phone,
    required this.role,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    required this.createdAt,
    this.isActive = true,
  });

  Worker copyWith({
    int? id,
    String? name,
    String? nationalCode,
    String? phone,
    WorkerRole? role,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      nationalCode: nationalCode ?? this.nationalCode,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'national_code': nationalCode,
      'phone': phone,
      'role': role.index,
      'address': address,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'],
      name: map['name'],
      nationalCode: map['national_code'],
      phone: map['phone'],
      role: WorkerRole.values[map['role']],
      address: map['address'],
      emergencyContact: map['emergency_contact'],
      emergencyPhone: map['emergency_phone'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isActive: map['is_active'] == 1,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nationalCode,
        phone,
        role,
        address,
        emergencyContact,
        emergencyPhone,
        createdAt,
        isActive,
      ];
}

enum AttendanceStatus { present, absent, late, leave, mission }

extension AttendanceStatusExt on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'حاضر';
      case AttendanceStatus.absent:
        return 'غایب';
      case AttendanceStatus.late:
        return 'دیر آمدن';
      case AttendanceStatus.leave:
        return 'مرخصی';
      case AttendanceStatus.mission:
        return 'ماموریت';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return const Color(0xFF2E7D32);
      case AttendanceStatus.absent:
        return const Color(0xFFC62828);
      case AttendanceStatus.late:
        return const Color(0xFFEF6C00);
      case AttendanceStatus.leave:
        return const Color(0xFF1565C0);
      case AttendanceStatus.mission:
        return const Color(0xFF6A1B9A);
    }
  }

  IconData get icon {
    switch (this) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.leave:
        return Icons.beach_access;
      case AttendanceStatus.mission:
        return Icons.directions_car;
    }
  }
}

class AttendanceRecord extends Equatable {
  final int? id;
  final int workerId;
  final DateTime date;
  final AttendanceStatus status;
  final String? note;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? location;
  final DateTime createdAt;

  const AttendanceRecord({
    this.id,
    required this.workerId,
    required this.date,
    required this.status,
    this.note,
    this.checkInTime,
    this.checkOutTime,
    this.location,
    required this.createdAt,
  });

  AttendanceRecord copyWith({
    int? id,
    int? workerId,
    DateTime? date,
    AttendanceStatus? status,
    String? note,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? location,
    DateTime? createdAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worker_id': workerId,
      'date': date.millisecondsSinceEpoch,
      'status': status.index,
      'note': note,
      'check_in_time': checkInTime?.millisecondsSinceEpoch,
      'check_out_time': checkOutTime?.millisecondsSinceEpoch,
      'location': location,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      workerId: map['worker_id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      status: AttendanceStatus.values[map['status']],
      note: map['note'],
      checkInTime: map['check_in_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['check_in_time'])
          : null,
      checkOutTime: map['check_out_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['check_out_time'])
          : null,
      location: map['location'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        workerId,
        date,
        status,
        note,
        checkInTime,
        checkOutTime,
        location,
        createdAt,
      ];
}