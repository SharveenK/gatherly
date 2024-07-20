import 'package:json_annotation/json_annotation.dart';
part 'stall_details.g.dart';

@JsonSerializable(explicitToJson: true)
class StallDetails {
  StallDetails(
      {this.description,
      this.mediaUrls,
      this.startDate,
      this.endDate,
      this.title});

  factory StallDetails.fromJson(Map<String, Object?> json) =>
      _$StallDetailsFromJson(json);

  String? title;
  String? description;
  String? startDate;
  String? endDate;
  List<String>? mediaUrls;

  Map<String, Object?> toJson() => _$StallDetailsToJson(this);
}
