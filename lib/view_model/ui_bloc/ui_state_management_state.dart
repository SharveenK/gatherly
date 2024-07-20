part of 'ui_state_management_bloc.dart';

@immutable
sealed class UiStateManagementState extends Equatable {}

final class UiStateManagementInitial extends UiStateManagementState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class VideoSliderState extends UiStateManagementState {
  final double videoSlider;

  VideoSliderState(this.videoSlider);
  @override
  List<Object?> get props => [
        videoSlider,
      ];
}

class PauseAndResumeIconState extends UiStateManagementState {
  final bool isVideoPlaying;

  PauseAndResumeIconState(this.isVideoPlaying);

  @override
  List<Object?> get props => [isVideoPlaying];
}

class UploadingProgressLevel extends UiStateManagementState {
  final double uploadingPercentage;

  UploadingProgressLevel(this.uploadingPercentage);
  @override
  List<Object?> get props => [uploadingPercentage];
}

class FileUploadedState extends UiStateManagementState {
  final bool isUploaded;

  FileUploadedState(this.isUploaded);
  @override
  List<Object?> get props => [isUploaded];
}
