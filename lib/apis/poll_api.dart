import 'dart:convert';

import 'package:akhbar/exceptions/http_auth_exception.dart';
import 'package:akhbar/models/poll_model.dart';
import 'package:akhbar/models/poll_vote_model.dart';
import 'package:akhbar/models/saved_auth_model.dart';
import 'package:http/http.dart' as http;
import 'package:akhbar/constants/app_constants.dart';

Future<List<Poll>> fetchPolls() async {
  SavedAuth? authInfo;
  try {
    authInfo = await getSavedAuthInfo();
  } catch (error) {
    // @TODO Logout and redirect to login screen
  }

  final response = await http.get(
    Uri.parse(AppConstants.apiPollUrl),
    headers: {
      "Authorization": "Bearer ${authInfo!.token.plainTextToken}",
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

  return pollsFromJson(response.body);
}

Future<PollVote> postUserPollVote(Poll poll, int vote) async {
  SavedAuth? authInfo;
  try {
    authInfo = await getSavedAuthInfo();
  } catch (error) {
    // @TODO Logout and redirect to login screen
  }

  final response = await http.post(
    Uri.parse("${AppConstants.apiPollVoteUrl}/${poll.id}/votes"),
    headers: {
      "Authorization": "Bearer ${authInfo!.token.plainTextToken}",
      "content-type": "application/json",
      "accept": "application/json",
    },
    body: jsonEncode({"vote": vote}),
  );

  if (response.statusCode != 200) {
    // Extract server error message and use this as exception message
    throw Exception("Failed to load polls");
  }

  return pollVoteFromJson(response.body);
}