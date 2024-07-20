import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gatherly/models/constants.dart';
import 'package:gatherly/models/model_serialize/stall_details.dart';
import 'package:gatherly/models/repo/sqflite_repositor.dart';

class UserDetailsRepository {
  final SqfliteRepositor _sqfliteRepositor = SqfliteRepositor();
  Future<void> uploadFile(
      int stallNumber,
      Function(double event) progressLevelCallBack,
      Function(String downloadUrl) onDoneCallBack,
      List<String> mediaUrls,
      bool isOffline,
      StallDetails stallDetails) async {
    // ignore: empty_catches
    try {
      List<String> allowedExtendsion = ['jpg', 'png', 'mp4'];
      await FilePicker.platform
          .pickFiles(
              type: FileType.custom,
              allowMultiple: false,
              allowedExtensions: allowedExtendsion)
          .then(
        (value) async {
          if (value != null) {
            if (isOffline) {
              await _sqfliteRepositor.updateUploadedFile(
                'stalls',
                stallDetails,
                value.files[0].path!,
              );
              progressLevelCallBack(100);
              onDoneCallBack('');
            } else {
              final ref = FirebaseStorage.instance
                  .ref()
                  .child('stall${stallNumber + 1}')
                  .child(value.files[0].name);
              final uploadTask = ref.putFile(File(value.files[0].path!));
              uploadTask.snapshotEvents.listen(
                (event) {
                  double progress =
                      (event.bytesTransferred / event.totalBytes) * 100;
                  progressLevelCallBack(progress);
                },
                onDone: () async {
                  final downloadUrl = await ref.getDownloadURL();
                  List<String> combinedUrls = mediaUrls;
                  combinedUrls.add(downloadUrl);
                  await userCollections
                      .doc('stall${stallNumber + 1}')
                      .update({'mediaUrls': combinedUrls});
                  onDoneCallBack(downloadUrl);
                },
              );
            }
          }
        },
      );
    } catch (e) {
      throw Exception();
    }
  }
}
