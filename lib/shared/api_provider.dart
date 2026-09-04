// ignore_for_file: unused_local_variable, avoid_print, duplicate_ignore

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

import 'package:gwealth/models/user_profile_store.dart';
import 'package:flutter/foundation.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

const versionName = '0.0.1';
const versionNumber = 4;

/// G-Wealth API base (เครื่อง Android ใช้ IP ของ Mac ไม่ใช่ localhost)
// const server = 'http://localhost:7201/';
const server = 'http://line-ddpm.we-builds.com/g-wealth-api/';
const serverUpload = 'https://lc.we-builds.com/lc-document/upload';
const serverOTP = 'https://portal-otp.smsmkt.com/api/';

// --- Endpoints used by G-Wealth app ---
const sharedApi = '${server}configulation/shared/';
const registerApi = '${server}m/register/';
const newsApi = '${server}m/news/';
const newsReadApi = '${server}m/news/read';
const newsV2Api = '${server}m/v2/news/';
const newsGalleryApi = '${server}m/news/gallery/read';
const knowledgeApi = '${server}m/knowledge/';
const knowledgeCategoryApi = '${server}m/knowledge/category/';
const contactApi = '${server}m/contact/';
const contactCategoryApi = '${server}m/contact/category/';
const bannerApi = '${server}banner/';
const bannerReadApi = '${server}banner/read';
const mainBannerApi = bannerReadApi;
const bannerGalleryApi = '${server}banner/gallery/read';
const aboutUsApi = '${server}m/aboutus/';
const notificationApi = '${server}m/v2/notification/';
const welfareApi = '${server}m/welfare/';
const welfareCategoryApi = '${server}m/welfare/category/';
const welfareGalleryApi = '${server}m/welfare/gallery/read';
const pollApi = '${server}m/poll/';
const privilegeApi = '${server}m/privilege/';
const splashReadApi = '${server}m/splash/read';
const profileReadApi = '${server}m/v2/register/read';
const organizationImageReadApi = '${server}m/v2/organization/image/read';
const mainPopupHomeApi = '${server}m/MainPopup/';
const forceAdsApi = '${server}m/ForceAds/';

/// บนมือถือจริงใช้ localhost ผ่าน `adb reverse tcp:7201 tcp:7201`
/// (อย่าแปลงเป็น 10.0.2.2 — ค่านั้นใช้ได้เฉพาะ Android emulator)
String resolveApiUrl(String url) => url;

Map<String, String> _jsonHeaders({bool includeAuth = true}) {
  final headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  final token = UserProfileStore.instance.token.trim();
  if (includeAuth && token.isNotEmpty) {
    headers["Authorization"] = "Bearer $token";
  }

  return headers;
}

Dio _createDio({bool includeAuth = true}) {
  final dio = Dio();
  dio.options.headers.addAll(_jsonHeaders(includeAuth: includeAuth));
  return dio;
}

Future<dynamic> postCategory(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] ?? 0,
    "limit": criteria['limit'] ?? 1,
    "code": criteria['code'] ?? '',
    "reference": criteria['reference'] ?? '',
    "description": criteria['description'] ?? '',
    "category": criteria['category'] ?? '',
    "keySearch": criteria['keySearch'] ?? '',
    "username": criteria['username'] ?? '',
    "isHighlight": criteria['isHighlight'] ?? false,
    "isCategory": criteria['isCategory'] ?? false,
  });

  var response =
      await http.post(Uri.parse(url), body: body, headers: _jsonHeaders());

  var data = json.decode(response.body);

  List<dynamic> list = [
    {'code': "", 'title': 'ทั้งหมด'}
  ];
  list = [...list, ...data['objectData']];

  return Future.value(list);
}

Future<dynamic> post(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] ?? 0,
    "limit": criteria['limit'] ?? 1,
    "code": criteria['code'] ?? '',
    "reference": criteria['reference'] ?? '',
    "description": criteria['description'] ?? '',
    "category": criteria['category'] ?? '',
    "keySearch": criteria['keySearch'] ?? '',
    "username": criteria['username'] ?? '',
    "password": criteria['password'] ?? '',
    "email": criteria['email'] ?? '',
    "firstName": criteria['firstName'] ?? '',
    "lastName": criteria['lastName'] ?? '',
    "title": criteria['title'] ?? '',
    "answer": criteria['answer'] ?? '',
    "isHighlight": criteria['isHighlight'] ?? false,
    "createBy": criteria['createBy'] ?? '',
    "isPublic": criteria['isPublic'] ?? false,
    "imageList": criteria['imageList'] ?? [],
    "profileCode": criteria['profileCode'] ?? '',
    "isCategory": criteria['isCategory'] ?? false,
    "idcard": criteria['idcard'] ?? false,
  });

  var response =
      await http.post(Uri.parse(url), body: body, headers: _jsonHeaders());

  var data = json.decode(response.body);
  return Future.value(data['objectData']);
}

Future<dynamic> postAny(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] ?? 0,
    "limit": criteria['limit'] ?? 1,
    "code": criteria['code'] ?? '',
    "category": criteria['category'] ?? '',
    "username": criteria['username'] ?? '',
    "password": criteria['password'] ?? '',
    "createBy": criteria['createBy'] ?? '',
    "imageUrlCreateBy": criteria['imageUrlCreateBy'] ?? '',
    "reference": criteria['reference'] ?? '',
    "description": criteria['description'] ?? '',
  });

  var response =
      await http.post(Uri.parse(url), body: body, headers: _jsonHeaders());

  var data = json.decode(response.body);

  return Future.value(data['status']);
}

Future<dynamic> postAnyObj(String url, dynamic criteria) async {
  var body = json.encode({
    "permission": "all",
    "skip": criteria['skip'] ?? 0,
    "limit": criteria['limit'] ?? 1,
    "code": criteria['code'] ?? '',
    "createBy": criteria['createBy'] ?? '',
    "imageUrlCreateBy": criteria['imageUrlCreateBy'] ?? '',
    "reference": criteria['reference'] ?? '',
    "description": criteria['description'] ?? '',
  });

  var response =
      await http.post(Uri.parse(url), body: body, headers: _jsonHeaders());

  var data = json.decode(response.body);

  return Future.value(data);
}

Future<dynamic> postLogin(String url, dynamic criteria) async {
  var body = json.encode({
    "category": criteria['category'] ?? '',
    "password": criteria['password'] ?? '',
    "username": criteria['username'] ?? '',
    "email": criteria['email'] ?? '',
  });

  var response = await http.post(
    Uri.parse(url),
    body: body,
    headers: _jsonHeaders(includeAuth: false),
  );

  var data = json.decode(response.body);

  return Future.value(data['objectData']);
}

Future<dynamic> postObjectData(String url, dynamic criteria) async {
  var body = json.encode(criteria);

  var response = await http.post(Uri.parse(server + url),
      body: body, headers: _jsonHeaders());

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return {
      "status": data['status'],
      "message": data['message'],
      "objectData": data['objectData'],
      "totalData": data['totalData'],
    };
  } else {
    return {"status": "F"};
  }
}

Future<dynamic> postConfigShare() async {
  var body = json.encode({});

  var response = await http.post(
      Uri.parse('${server}configulation/shared/read'),
      body: body,
      headers: _jsonHeaders());

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return {
      "status": data['status'],
      "message": data['message'],
      "objectData": data['objectData']
    };
  } else {
    return {"status": "F"};
  }
}

Future<File> convertimageTofile(imgUrl) async {
  var response = await http.get(imgUrl);
  Directory documentDirectory = await getApplicationDocumentsDirectory();
  File file = File(join(documentDirectory.path, 'imagetest.png'));
  file.writeAsBytesSync(response.bodyBytes);
  return file;
}

Future<String> uploadImage(File file) async {
  Dio dio = _createDio();
  String fileName = file.path.split('/').last;
  FormData formData = FormData.fromMap({
    "ImageCaption": "flutter",
    "Image": await MultipartFile.fromFile(file.path, filename: fileName),
  });

  var response = await dio.post(serverUpload, data: formData);

  return response.data['imageUrl'];
}

Future<String> uploadImageX(XFile file) async {
  Dio dio = _createDio();
  String fileName = file.path.split('/').last;
  FormData formData = FormData.fromMap({
    "ImageCaption": "flutter",
    "Image": await MultipartFile.fromFile(file.path, filename: fileName),
  });

  var response = await dio.post(serverUpload, data: formData);

  return response.data['imageUrl'];
}

upload(File file) async {
  var uri = Uri.parse(serverUpload);
  var request = http.MultipartRequest('POST', uri)
    ..fields['ImageCaption'] = 'flutter2'
    ..files.add(await http.MultipartFile.fromPath('Image', file.path,
        contentType: MediaType('application', 'x-tar')));
  var response = await request.send();
  if (response.statusCode == 200) {
    return response;
  }
}

createStorageApp({dynamic model, String? category}) {
  const storage = FlutterSecureStorage();

  storage.write(key: 'profileCategory', value: category);

  storage.write(
    key: 'profileCode18',
    value: model['code'],
  );

  storage.write(
    key: 'profileImageUrl',
    value: model['imageUrl'],
  );

  storage.write(
    key: 'profileFirstName',
    value: model['firstName'],
  );

  storage.write(
    key: 'profileLastName',
    value: model['lastName'],
  );

  storage.write(
    key: 'dataUserLoginLC',
    value: jsonEncode(model),
  );
}

Future<dynamic> postDio(String url, dynamic criteria) async {
  const storage = FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode18');
  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }
  Dio dio = _createDio();
  dio.options.connectTimeout = const Duration(seconds: 12);
  dio.options.receiveTimeout = const Duration(seconds: 20);
  try {
    final resolved = resolveApiUrl(url);
    var response = await dio.post(resolved, data: criteria);
    return Future.value(response.data);
  } on DioException catch (e) {
    debugPrint(
        'postDio $url → ${e.type} ${e.response?.statusCode} ${e.message}');
    if (url != resolveApiUrl(url)) {
      debugPrint('postDio resolved ${resolveApiUrl(url)}');
    }
    return null;
  }
}

/// ดึง list จาก response มาตรฐานของ API (objectData / jsonData)
List<dynamic> extractObjectData(dynamic result) {
  if (result == null) return const [];
  if (result is List) return result;
  if (result is! Map) return const [];
  final map = Map<String, dynamic>.from(result);
  final od = map['objectData'] ?? map['ObjectData'];
  if (od is List) return od;
  final jd = map['jsonData'] ?? map['JsonData'];
  if (jd is String && jd.trim().isNotEmpty && jd.trim() != 'null') {
    try {
      final decoded = json.decode(jd);
      if (decoded is List) return decoded;
    } catch (_) {}
  }
  return const [];
}

Future<dynamic> postDioCategory(String url, dynamic criteria) async {
  const storage = FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode18');

  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }

  Dio dio = _createDio();
  var response = await dio.post(resolveApiUrl(url), data: criteria);

  List<dynamic> list = [
    {'code': "", 'title': 'ทั้งหมด'}
  ];
  list = [...list, ...response.data['objectData']];

  return Future.value(list);
}

Future<dynamic> postDioMessage(String url, dynamic criteria) async {
  const storage = FlutterSecureStorage();
  final profileCode = await storage.read(key: 'profileCode18');
  if (profileCode != '' && profileCode != null) {
    criteria = {'profileCode': profileCode, ...criteria};
  }
  Dio dio = _createDio();
  var response = await dio.post(resolveApiUrl(url), data: criteria);
  return Future.value(response.data['objectData']);
}

Future<dynamic> postOTPSend(String url, dynamic criteria) async {
  Dio dio = Dio();
  dio.options.contentType = Headers.formUrlEncodedContentType;
  dio.options.headers["api_key"] = "db88c29e14b65c9db353c9385f6e5f28";
  dio.options.headers["secret_key"] = "XpM2EfFk7DKcyJzt";
  var response = await dio.post(serverOTP + url, data: criteria);
  return Future.value(response.data['result']);
}

Future<void> postTrackClick(String button) async {
  const storage = FlutterSecureStorage();
  var value = await storage.read(key: 'dataUserLoginLC');
  var data = json.decode(value!);

  dynamic criteria = {
    'button': button,
    'username': data['username'] != '' ? data['username'] ?? '' : '',
    'firstname': data['firstname'] != '' ? data['firstname'] ?? '' : '',
    'lastname': data['lastname'] != '' ? data['lastname'] ?? '' : '',
    'profileCode': data['code'] != '' ? data['code'] ?? '' : '',
    'createBy': data['username'] != '' ? data['username'] ?? '' : '',
  };
  Dio dio = _createDio();
  dio.post("${server}trackClick/create", data: criteria);
}
