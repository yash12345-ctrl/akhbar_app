import 'package:http/http.dart' as http;
import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/models/category_model.dart';

Future<List<Category>> fetchCategories({ int page = 1}) async {
  final response = await http.get(
    Uri.parse("${AppConstants.apiCategoryUrl}?page=$page"),
    headers: {"accept": "applicatino/json"},
  );

  if (response.statusCode != 200) {
    // @TODO Extract server error message and use this as exception message
    throw Exception("Failed to load Categories");
  }

  return categoriesFromJson(response.body);
}