// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectMessageEvent _$DirectMessageEventFromJson(Map<String, dynamic> json) {
  return DirectMessageEvent()
    ..type = json['type'] as String
    ..id = json['id'] as String
    ..createdTimestamp = json['created_timestamp']
    ..initiatedVia = json['initiated_via'] as Map<String, dynamic>
    ..messageCreate = json['message_create'] == null
        ? null
        : DirectMessageCreate.fromJson(
            json['message_create'] as Map<String, dynamic>);
}

Map<String, dynamic> _$DirectMessageEventToJson(DirectMessageEvent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'created_timestamp': instance.createdTimestamp,
      'initiated_via': instance.initiatedVia,
      'message_create': instance.messageCreate,
    };

DirectMessageCreate _$DirectMessageCreateFromJson(Map<String, dynamic> json) {
  return DirectMessageCreate()
    ..target = json['target'] as Map<String, dynamic>
    ..senderId = json['sender_id'] as int
    ..sourceAppId = json['source_app_id'] as int;
}

Map<String, dynamic> _$DirectMessageCreateToJson(
        DirectMessageCreate instance) =>
    <String, dynamic>{
      'target': instance.target,
      'sender_id': instance.senderId,
      'source_app_id': instance.sourceAppId,
    };

DirectMessageData _$DirectMessageDataFromJson(Map<String, dynamic> json) {
  return DirectMessageData()
    ..text = json['text'] as String
    ..entities = json['entities'] == null
        ? null
        : Entities.fromJson(json['entities'] as Map<String, dynamic>)
    ..quickReplyResponse = json['quick_reply_response'] as Map<String, dynamic>
    ..attachment = json['attachment'] == null
        ? null
        : DirectMessageAttachment.fromJson(
            json['attachment'] as Map<String, dynamic>);
}

Map<String, dynamic> _$DirectMessageDataToJson(DirectMessageData instance) =>
    <String, dynamic>{
      'text': instance.text,
      'entities': instance.entities,
      'quick_reply_response': instance.quickReplyResponse,
      'attachment': instance.attachment,
    };

DirectMessageAttachment _$DirectMessageAttachmentFromJson(
    Map<String, dynamic> json) {
  return DirectMessageAttachment()
    ..type = json['type'] as String
    ..media = json['media'] == null
        ? null
        : TwitterMedia.fromJson(json['media'] as Map<String, dynamic>);
}

Map<String, dynamic> _$DirectMessageAttachmentToJson(
        DirectMessageAttachment instance) =>
    <String, dynamic>{
      'type': instance.type,
      'media': instance.media,
    };
