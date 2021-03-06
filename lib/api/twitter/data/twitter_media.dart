import 'package:harpy/api/twitter/data/media_size.dart';
import 'package:harpy/api/twitter/data/video_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'twitter_media.g.dart';

@JsonSerializable()
class TwitterMedia {
  TwitterMedia();

  factory TwitterMedia.fromJson(Map<String, dynamic> json) =>
      _$TwitterMediaFromJson(json);

  int id;
  @JsonKey(name: "id_str")
  String idStr;
  List<int> indices;
  @JsonKey(name: "media_url")
  String mediaUrl;
  @JsonKey(name: "media_url_https")
  String mediaUrlHttps;
  String url;
  @JsonKey(name: "display_url")
  String displayUrl;
  @JsonKey(name: "expanded_url")
  String expandedUrl;
  String type;
  Map<String, MediaSize> sizes;
  @JsonKey(name: "video_info")
  VideoInfo videoInfo;

  int get thumbWidth => sizes["thumb"]?.w;
  int get thumbHeight => sizes["thumb"]?.h;
  String get thumbResize => sizes["thumb"]?.resize;

  int get smallWidth => sizes["small"]?.w;
  int get smallHeight => sizes["small"]?.h;
  String get smallResize => sizes["small"]?.resize;

  int get mediumWidth => sizes["medium"]?.w;
  int get mediumHeight => sizes["medium"]?.h;
  String get mediumResize => sizes["medium"]?.resize;

  int get largeWidth => sizes["large"]?.w;
  int get largeHeight => sizes["large"]?.h;
  String get largeResize => sizes["large"]?.resize;

  Map<String, dynamic> toJson() => _$TwitterMediaToJson(this);
}
