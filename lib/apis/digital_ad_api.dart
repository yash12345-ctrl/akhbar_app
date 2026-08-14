
import 'package:akhbar/exceptions/http_auth_exception.dart';
import 'package:akhbar/models/digital_ad_model.dart';
import 'package:akhbar/models/saved_auth_model.dart';
import 'package:http/http.dart' as http;
import 'package:akhbar/constants/app_constants.dart';

Future<List<DigitalAd>> fetchDigitalAds() async {
  SavedAuth? authInfo;
  try {
    authInfo = await getSavedAuthInfo();
  } catch (error) {
    // @TODO Logout and redirect to login screen
    return [];
  }

  final response = await http.get(
    Uri.parse(AppConstants.apiDigitalAdUrl),
    headers: {
      "Authorization": "Bearer ${authInfo.token.plainTextToken}",
      "content-type": "application/json",
      "accept": "application/json",
    },
  );

  if (response.statusCode == 401) {
    throw HttpAuthException("Unauthorized");
  } else if (response.statusCode != 200) {
    // Extract server error message and use this as exception message
    throw Exception("Failed to load polls");
  }

  return digitalAdsFromJson(response.body);
}