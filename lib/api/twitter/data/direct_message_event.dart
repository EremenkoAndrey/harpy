import 'package:harpy/api/twitter/data/entities.dart';
import 'package:harpy/api/twitter/data/twitter_media.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_message_event.g.dart';

@JsonSerializable()
class DirectMessageEvent {
  DirectMessageEvent();

  factory DirectMessageEvent.fromJson(Map<String, dynamic> json) =>
      _$DirectMessageEventFromJson(json);

  String type;
  String id;
  @JsonKey(name: "created_timestamp")
  dynamic createdTimestamp;
  @JsonKey(name: "initiated_via")
  Map<String, dynamic> initiatedVia;
  @JsonKey(name: "message_create")
  DirectMessageCreate messageCreate;

  Map<String, dynamic> toJson() => _$DirectMessageEventToJson(this);
}

@JsonSerializable()
class DirectMessageCreate {
  DirectMessageCreate();

  factory DirectMessageCreate.fromJson(Map<String, dynamic> json) =>
      _$DirectMessageCreateFromJson(json);

  Map<String, dynamic> target;
  @JsonKey(name: "sender_id")
  String senderId;
  @JsonKey(name: "source_app_id")
  String sourceAppId;

  Map<String, dynamic> toJson() => _$DirectMessageCreateToJson(this);
}

@JsonSerializable()
class DirectMessageData {
  DirectMessageData();

  factory DirectMessageData.fromJson(Map<String, dynamic> json) =>
      _$DirectMessageDataFromJson(json);

  String text;
  Entities entities;
  @JsonKey(name: "quick_reply_response")
  Map<String, dynamic> quickReplyResponse;
  DirectMessageAttachment attachment;

  Map<String, dynamic> toJson() => _$DirectMessageDataToJson(this);
}

@JsonSerializable()
class DirectMessageAttachment {
  DirectMessageAttachment();

  factory DirectMessageAttachment.fromJson(Map<String, dynamic> json) =>
      _$DirectMessageAttachmentFromJson(json);

  String type;
  TwitterMedia media;

  Map<String, dynamic> toJson() => _$DirectMessageAttachmentToJson(this);
}
