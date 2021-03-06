import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:harpy/api/translate/data/translation.dart';
import 'package:harpy/api/translate/translate_service.dart';
import 'package:harpy/api/twitter/data/tweet.dart';
import 'package:harpy/api/twitter/services/tweet_service.dart';
import 'package:harpy/api/twitter/twitter_error_handler.dart';
import 'package:harpy/core/cache/tweet_database.dart';
import 'package:harpy/core/misc/flushbar_service.dart';
import 'package:harpy/core/utils/string_utils.dart';
import 'package:harpy/harpy.dart';
import 'package:harpy/models/login_model.dart';
import 'package:harpy/models/timeline_model.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

typedef OnTweetUpdated = void Function(Tweet tweet);

/// The model for a single [Tweet].
///
/// Handles changes on the [Tweet] including actions (favorite, retweet,
/// translate, ...) and rebuilds the listeners when the state changes.
class TweetModel extends ChangeNotifier {
  TweetModel({
    @required this.originalTweet,
    @required this.loginModel,
    this.timelineModel,
    this.onTweetUpdated,
    this.isQuote = false,
  });

  final LoginModel loginModel;

  /// The closest [TimelineModel] for the tweet.
  final TimelineModel timelineModel;

  final Tweet originalTweet;

  /// Used as a callback when a tweet is updated.
  final OnTweetUpdated onTweetUpdated;

  /// Whether or not the [TweetModel] is showing a quoted [Tweet].
  final bool isQuote;

  final TweetService tweetService = app<TweetService>();
  final TranslationService translationService = app<TranslationService>();
  final FlushbarService flushbarService = app<FlushbarService>();
  final TweetDatabase tweetDatabase = app<TweetDatabase>();

  static final Logger _log = Logger("TweetModel");

  static TweetModel of(BuildContext context) {
    return Provider.of<TweetModel>(context);
  }

  /// True while the [tweet] is being translated.
  bool translating = false;

  /// The names of the user that replied to this [tweet] in a formatted string.
  ///
  /// `null` if the [tweet] does not have any replies.
  String replyAuthors;

  /// Returns the [Tweet.retweetedStatus] if the [originalTweet] is a retweet
  /// else the [originalTweet].
  Tweet get tweet => originalTweet.retweetedStatus ?? originalTweet;

  /// Returns the text of the tweet.
  ///
  /// The text is reduced when the [tweet] is a quote.
  String get text => isQuote ? reduceText(tweet.fullText) : tweet.fullText;

  /// Whether or not the [originalTweet] is a retweet.
  bool get isRetweet => originalTweet.retweetedStatus != null;

  /// Whether or not the [originalTweet] is a reply.
  bool get isReply => originalTweet.harpyData.childOfReply == true;

  /// Whether or not the [tweet] has quoted another tweet.
  bool get hasQuote => tweet.quotedStatus != null;

  /// Returns the [Tweet.quotedStatus] of the [originalTweet].
  Tweet get quote => tweet.quotedStatus;

  /// Whether or not the [tweet] contains [TweetMedia].
  bool get hasMedia => tweet.extendedEntities?.media != null;

  /// A formatted number of the retweet count.
  String get retweetCount => "${prettyPrintNumber(tweet.retweetCount)}";

  /// A formatted number of the favorite count.
  String get favoriteCount => "${prettyPrintNumber(tweet.favoriteCount)}";

  /// @username · time since tweet in hours
  String get screenNameAndTime =>
      "@${tweet.user.screenName} \u00b7 ${tweetTimeDifference(tweet.createdAt)}";

  /// Returns the [Translation] to the [tweet].
  Translation get translation => originalTweet.harpyData.translation;

  /// Whether or not the [tweet] has been translated.
  bool get isTranslated => translation != null;

  /// True if the [tweet] is translated and unchanged.
  bool get translationUnchanged => translation?.unchanged ?? false;

  /// Whether or not this tweet can be translated.
  bool get allowTranslation => !tweet.emptyText && tweet.lang != "en";

  /// Whether or not this tweet is from the authorized user.
  bool get isAuthorizedUserTweet => tweet.user.id == loginModel.loggedInUser.id;

  /// Whether or not the tweet should be hidden.
  ///
  /// Hidden tweets appear collapsed but can be shown again with an action.
  bool get hidden => originalTweet.harpyData.hide == true;

  @override
  void notifyListeners() {
    super.notifyListeners();

    // also call onTweetUpdated when notifying listeners
    if (onTweetUpdated != null) {
      onTweetUpdated(tweet);
    }
  }

  /// Retweet this [tweet].
  void retweet() {
    tweet.retweeted = true;
    tweet.retweetCount++;
    notifyListeners();

    tweetService
        .retweet(tweet.idStr)
        .then((_) => tweetDatabase.recordTweet(originalTweet))
        .catchError((error) {
      if (!_actionPerformed(error)) {
        tweet.retweeted = false;
        tweet.retweetCount--;
        notifyListeners();
      }
    });
  }

  /// Unretweet this [tweet].
  void unretweet() {
    tweet.retweeted = false;
    tweet.retweetCount--;
    notifyListeners();

    tweetService
        .unretweet(tweet.idStr)
        .then((_) => tweetDatabase.recordTweet(originalTweet))
        .catchError((error) {
      if (!_actionPerformed(error)) {
        tweet.retweeted = true;
        tweet.retweetCount++;
        notifyListeners();
      }
    });
  }

  /// Favorite this [tweet].
  void favorite() {
    tweet.favorited = true;
    tweet.favoriteCount++;
    notifyListeners();

    tweetService
        .favorite(tweet.idStr)
        .then((_) => tweetDatabase.recordTweet(originalTweet))
        .catchError((error) {
      if (!_actionPerformed(error)) {
        tweet.favorited = false;
        tweet.favoriteCount--;
        notifyListeners();
      }
    });
  }

  /// Unfavorite this [tweet].
  void unfavorite() {
    tweet.favorited = false;
    tweet.favoriteCount--;
    notifyListeners();

    tweetService
        .unfavorite(tweet.idStr)
        .then((_) => tweetDatabase.recordTweet(originalTweet))
        .catchError((error) {
      if (!_actionPerformed(error)) {
        tweet.favorited = true;
        tweet.favoriteCount++;
        notifyListeners();
      }
    });
  }

  /// Translate this [tweet].
  ///
  /// The [Translation] is always saved in the [originalTweet], even if the
  /// [Tweet] is a retweet.
  Future<void> translate() async {
    translating = true;
    notifyListeners();

    final Translation translation = await translationService
        .translate(text: tweet.fullText)
        .catchError((_) {
      translating = false;
      notifyListeners();
    });

    originalTweet.harpyData.translation = translation;

    if (translation == null || translationUnchanged) {
      flushbarService.info("Tweet not translated");
    }

    if (translation != null) {
      tweetDatabase.recordTweet(originalTweet);
    }

    translating = false;
    notifyListeners();
  }

  /// Share this [tweet].
  ///
  /// Uses the [Share] plugin to show the share menu of the underlying OS.
  void share() {
    Share.share(
      "https://twitter.com/${tweet.user.screenName}/status/${tweet.idStr}",
    );
  }

  /// Hides this [tweet] or shows it if it has been hidden before.
  void toggleVisibility() {
    final hidden = originalTweet.harpyData.hide == true;

    originalTweet.harpyData.hide = !hidden;
    tweetDatabase.recordTweet(originalTweet);
    notifyListeners();
  }

  /// Deletes this [tweet].
  ///
  /// Only available if the [isAuthorizedUserTweet] is `true`.
  Future<void> delete() async {
    if (timelineModel == null) {
      _log.warning("timeline model not defined");
      return;
    }

    bool deleted;

    final resultTweet =
        await tweetService.deleteTweet(originalTweet.idStr).catchError((e) {
      if (_actionPerformed(e)) {
        _log.info("tweet already deleted");
        deleted = true;
      } else {
        twitterClientErrorHandler(e);
      }
    });

    deleted ??= resultTweet != null;

    if (deleted) {
      // remove the tweet from the database and the timeline
      tweetDatabase.deleteTweet(originalTweet.id);
      timelineModel.removeTweet(originalTweet);
    }
  }

  /// Returns `true` if the error contains any of the following error codes:
  ///
  /// 139: already favorited (trying to favorite a tweet twice)
  /// 327: already retweeted
  /// 144: tweet with id not found (trying to unfavorite a tweet twice) or
  /// trying to delete a tweet that has already been deleted before.
  bool _actionPerformed(dynamic error) {
    try {
      final List errors = jsonDecode((error as Response).body)["errors"];
      return errors.any((error) =>
          error["code"] == 139 || // already favorited
          error["code"] == 327 || // already retweeted
          error["code"] == 144); // not found
    } catch (e) {
      // unexpected error format
      return false;
    }
  }
}
