import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gatherly/models/model_serialize/stall_details.dart';

import 'package:gatherly/models/repo/user_details_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'ui_state_management_event.dart';
part 'ui_state_management_state.dart';

class UiStateManagementBloc
    extends Bloc<UiStateManagementEvent, UiStateManagementState> {
  UiStateManagementBloc() : super(UiStateManagementInitial()) {
    on<UiStateManagementEvent>((event, emit) {});
    on<VideoSliderEvent>(
      (event, emit) {
        emit(VideoSliderState(event.sliderValue));
      },
    );
    on<PauseAndResumeIconEvent>(
      (event, emit) {
        emit(PauseAndResumeIconState(event.isVideoPlaying));
      },
    );
    on<UploadFileEvent>(
      (event, emit) async {
        try {
          await _userDetailsRepository.uploadFile(event.stallNumber,
              (double progresslevel) {
            add(UploadFileProgessLevelEvent(progresslevel));
          }, (String downloadUrl) async {
            add(UploadFileConditionEvent(true));
          }, event.mediaUrls, event.isOffline, event.stallDetails);
        } catch (e) {
          add(UploadFileConditionEvent(false));
          return;
        }
      },
    );
    on<UploadFileProgessLevelEvent>(
      (event, emit) {
        emit(UploadingProgressLevel(event.progressLevel));
      },
    );
    on<UploadFileConditionEvent>(
      (event, emit) {
        emit(FileUploadedState(event.isUploadedSuccessfully));
      },
    );
  }
  final UserDetailsRepository _userDetailsRepository = UserDetailsRepository();
}
