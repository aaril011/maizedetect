import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _predictUrl = 'https://5vrh9gtf-5000.asse.devtunnels.ms/predict';
const _requestTimeout = Duration(seconds: 30);

Future<Map<String, dynamic>> uploadImage(String imagePath) async {
  try {
    final file = File(imagePath);

    print("================================");
    print("UPLOAD IMAGE");
    print("PATH : ${file.path}");
    print("EXISTS : ${await file.exists()}");
    print("SIZE : ${await file.length()}");
    print("================================");

    if (!await file.exists()) {
      throw Exception("File gambar tidak ditemukan");
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(_predictUrl),
    );

    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      file.path,
      filename: file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'image.jpg',
    );
    request.files.add(multipartFile);

    print('[_uploadImage] request send start');
    final response = await request.send().timeout(_requestTimeout);
    print('[_uploadImage] response status: ${response.statusCode}');
    final responseBody = await response.stream.bytesToString();
    print('[_uploadImage] response body length: ${responseBody.length}');
    print('STATUS API : ${response.statusCode}');
    print('BODY API : $responseBody');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gagal upload gambar. Status: ${response.statusCode}\nBody: $responseBody',
      );
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respon bukan objek JSON');
      }
      return decoded;
    } catch (e) {
      throw Exception(
        'Respon server bukan JSON valid.\nBody: $responseBody',
      );
    }
  } on TimeoutException catch (_) {
    throw Exception(
      'Upload gambar timeout. Pastikan server berjalan dan koneksi stabil.',
    );
  } on SocketException catch (_) {
    throw Exception(
      'Tidak bisa terhubung ke server. Cek URL API dan pastikan backend berjalan.',
    );
  } catch (e) {
    print('UPLOAD ERROR:');
    print(e);

    rethrow;
  }
}
