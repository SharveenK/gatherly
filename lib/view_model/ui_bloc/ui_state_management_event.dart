part of 'ui_state_management_bloc.dart';

@immutable
sealed class UiStateManagementEvent extends Equatable {}

class VideoSliderEvent extends UiStateManagementEvent {
  final double sliderValue;

  VideoSliderEvent(this.sliderValue);
  @override
  List<Object?> get props => [sliderValue];
}

class PauseAndResumeIconEvent extends UiStateManagementEvent {
  final bool isVideoPlaying;

  PauseAndResumeIconEvent(this.isVideoPlaying);
  @override
  List<Object?> get props => [isVideoPlaying];
}

class UploadFileEvent extends UiStateManagementEvent {
  final int stallNumber;
  final List<String> mediaUrls;
  final bool isOffline;
  final StallDetails stallDetails;

  UploadFileEvent(
      this.stallNumber, this.mediaUrls, this.isOffline, this.stallDetails);
  @override
  List<Object?> get props => [
        stallNumber,
        isOffline,
        mediaUrls,
        stallDetails,
      ];
}

class UploadFileProgessLevelEvent extends UiStateManagementEvent {
  final double progressLevel;

  UploadFileProgessLevelEvent(this.progressLevel);

  @override
  List<Object?> get props => [progressLevel];
}

class UploadFileConditionEvent extends UiStateManagementEvent {
  final bool isUploadedSuccessfully;

  UploadFileConditionEvent(this.isUploadedSuccessfully);

  @override
  List<Object?> get props => [
        isUploadedSuccessfully,
      ];
}
