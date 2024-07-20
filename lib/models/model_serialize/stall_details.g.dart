// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stall_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StallDetails _$StallDetailsFromJson(Map<String, dynamic> json) => StallDetails(
      description: json['description'] as String?,
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$StallDetailsToJson(StallDetails instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'mediaUrls': instance.mediaUrls,
    };
