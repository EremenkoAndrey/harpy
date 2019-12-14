// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectMessageList _$DirectMessageListFromJson(Map<String, dynamic> json) {
  return DirectMessageList()
    ..events = (json['events'] as List)
        ?.map((e) => e == null
            ? null
            : DirectMessageEvent.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..nextCursor = json['next_cursor'] as String
    ..previousCursor = json['previous_cursor'] as int;
}

Map<String, dynamic> _$DirectMessageListToJson(DirectMessageList instance) =>
    <String, dynamic>{
      'events': instance.events,
      'next_cursor': instance.nextCursor,
      'previous_cursor': instance.previousCursor,
    };
