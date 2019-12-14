import 'package:harpy/api/twitter/data/direct_message_event.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_message_list.g.dart';

@JsonSerializable()
class DirectMessageList {
  DirectMessageList();

  factory DirectMessageList.fromJson(Map<String, dynamic> json) =>
      _$DirectMessageListFromJson(json);

  List<DirectMessageEvent> events;
  @JsonKey(name: "next_cursor")
  String nextCursor;
  @JsonKey(name: "previous_cursor")
  int previousCursor;

  Map<String, dynamic> toJson() => _$DirectMessageListToJson(this);
}
