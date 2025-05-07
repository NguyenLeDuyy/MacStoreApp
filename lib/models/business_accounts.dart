// models/business_account.dart
import 'package:flutter/foundation.dart';

class BusinessAccount {
  final String id;
  final DateTime createdAt;
  final String? companyName;
  final String? companyNumber;
  final String? address;
  final String? nidOwner;
  final String? userId; // Giữ kiểu String nếu UUID từ Supabase trả về là String
  final String? profilePictureUrl;
  final String? about;
  final List<String>? categories;
  final List<String>? tags;
  final String status;
  final DateTime? requestedAt;
  final DateTime? reviewedAt;
  final String? email;
  final double? balance;

  BusinessAccount({
    required this.id,
    required this.createdAt,
    this.companyName,
    this.companyNumber,
    this.address,
    this.nidOwner,
    this.userId,
    this.profilePictureUrl,
    this.about,
    this.categories,
    this.tags,
    required this.status,
    this.requestedAt,
    this.reviewedAt,
    this.email,
    this.balance,
  });

  factory BusinessAccount.fromJson(Map<String, dynamic> json) {
    return BusinessAccount(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      companyName: json['company_name'] as String?,
      companyNumber: json['company_number'] as String?,
      address: json['address'] as String?,
      nidOwner: json['nid_owner'] as String?,
      userId: json['user_id'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      about: json['about'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      requestedAt: json['requested_at'] == null
          ? null
          : DateTime.parse(json['requested_at'] as String),
      reviewedAt: json['reviewed_at'] == null
          ? null
          : DateTime.parse(json['reviewed_at'] as String),
      email: json['email'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'company_name': companyName,
      'company_number': companyNumber,
      'address': address,
      'nid_owner': nidOwner,
      'user_id': userId,
      'profile_picture_url': profilePictureUrl,
      'about': about,
      'categories': categories,
      'tags': tags,
      'status': status,
      'requested_at': requestedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'email': email,
      'balance': balance,
    };
  }
}