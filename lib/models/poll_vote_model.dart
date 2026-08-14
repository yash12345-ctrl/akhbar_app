import 'dart:convert';

class PollVote {
  final int yesCount;
  final int noCount;

  // @TODO Poll writer


  PollVote({
    required this.yesCount,
    required this.noCount,
  });

  factory PollVote.fromArray(List<dynamic> votes) {
    return PollVote(
      yesCount: votes.isNotEmpty ? votes[0] as int : 0,
      noCount: votes.length > 1 ? votes[1] as int : 0,
    );
  }
}

PollVote pollVoteFromJson(String json) {
  final data = jsonDecode(json);

  return PollVote.fromArray(data["data"]["votes"]);
}