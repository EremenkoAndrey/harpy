import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:harpy/api/twitter/data/direct_message_event.dart';
import 'package:harpy/api/twitter/data/direct_message_list.dart';
import 'package:harpy/api/twitter/twitter_client.dart';
import 'package:harpy/harpy.dart';
import 'package:logging/logging.dart';

class DirectMessagesService {
  final TwitterClient twitterClient = app<TwitterClient>();

  static final Logger _log = Logger("DirectMessagesService");

  /// Returns the [DirectMessageList] (both sent and received events) within the
  /// last 30 days. Sorted in reverse-chronological order.
  Future<DirectMessageList> list({
    int cursor,
  }) async {
    _log.fine("getting direct message list");

    final params = <String, String>{
      "count": "1", // max 50, default 20 // todo: set
    };

    if (cursor != null) {
      params["cursor"] = "$cursor";
    }

    return twitterClient
        .get(
          "https://api.twitter.com/1.1/direct_messages/events/list.json",
          params: params,
        )
        .then(
          (response) => compute<String, DirectMessageList>(
            _handleDirectMessageListResponse,
            response.body,
          ),
        );
  }

  /// Returns a single [DirectMessageEvent] by the given id.
  Future<DirectMessageEvent> show({
    @required int id,
  }) async {
    _log.fine("getting direct message list");

    final params = <String, String>{
      "id": "$id",
    };

    return twitterClient
        .get(
          "https://api.twitter.com/1.1/direct_messages/events/show.json",
          params: params,
        )
        .then(
          (response) => compute<String, DirectMessageEvent>(
            _handleDirectMessageEventResponse,
            response.body,
          ),
        );
  }
}

DirectMessageList _handleDirectMessageListResponse(String body) {
  return DirectMessageList.fromJson(jsonDecode(body));
}

DirectMessageEvent _handleDirectMessageEventResponse(String body) {
  final Map<String, dynamic> json = jsonDecode(body);

  return DirectMessageEvent.fromJson(json["event"]);
}
