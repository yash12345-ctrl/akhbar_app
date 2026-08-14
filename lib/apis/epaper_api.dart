import 'package:akhbar/models/epaper_edition_model.dart';
import 'package:akhbar/models/epaper_mode.dart';
import 'package:http/http.dart' as http;
import 'package:akhbar/constants/app_constants.dart';

Future<List<EPaper>> fetchEPapers({ int page = 1}) async {
  final response = await http.get(
    Uri.parse("${AppConstants.apiEPaperUrl}?page=$page"),
    headers: {"accept": "applicatino/json"},
  );

  if (response.statusCode != 200) {
    // @TODO Extract server error message and use this as exception message
    throw Exception("Failed to load articles");
  }

  return ePapersFromJson(response.body);
}

Future<EPaperEdition> fetchEPaperEditions({ int page = 1}) async {
  final response = await http.get(
    Uri.parse(AppConstants.apiEPaperEditionUrl),
    headers: {"accept": "applicatino/json"},
  );

  if (response.statusCode != 200) {
    // @TODO Extract server error message and use this as exception message
    throw Exception("Failed to load articles");
  }

  return ePaperEditionsFromJson(response.body);
}