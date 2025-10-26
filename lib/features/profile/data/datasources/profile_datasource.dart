import 'dart:io';
import 'package:dio/dio.dart';
import 'package:season_app/core/constants/api_endpoints.dart';

class ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSource(this.dio);

  Future<Response> getProfile() async {
    final response = await dio.get(
      ApiEndpoints.profile,
    );
    return response;
  }

  Future<Response> updateProfile({
    required String name,
    String? nickname,
    required String email,
    required String phone,
    String? birthDate,
    String? gender,
    int? avatarId,
    File? photoFile,
  }) async {
    // If photo file is provided, use multipart/form-data
    if (photoFile != null) {
      print('📸 Uploading photo file: ${photoFile.path}');
      
      FormData formData = FormData.fromMap({
        'name': name,
        'nickname': nickname ?? '',
        'email': email,
        'phone': phone,
        'birth_date': birthDate ?? '',
        'gender': gender ?? '',
        '_method': 'PUT',
      });

      // Add photo file with key 'photo_url'
      String fileName = photoFile.path.split('/').last;
      formData.files.add(
        MapEntry(
          'photo_url',  // API expects this key
          await MultipartFile.fromFile(
            photoFile.path,
            filename: fileName,
          ),
        ),
      );

      print('📤 Sending multipart/form-data with photo_url');

      final response = await dio.post(
        ApiEndpoints.updateProfile,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response;
    }

    // Otherwise, send regular JSON with avatar_id
    print('📝 Sending JSON without photo file');
    final data = {
      'name': name,
      'nickname': nickname ?? '',
      'email': email,
      'phone': phone,
      'birth_date': birthDate ?? '',
      'gender': gender ?? '',
      '_method': 'PUT',
    };

    // Only add avatar_id if it's provided
    if (avatarId != null) {
      data['avatar_id'] = avatarId.toString();
    }

    final response = await dio.post(
      ApiEndpoints.updateProfile,
      data: data,
    );

    return response;
  }


}

