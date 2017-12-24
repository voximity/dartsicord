class Embed {
  /// The title of the embed.
  String title;
  /// The type of the embed. Defaults to `rich`.
  String type = "rich";
  /// The description of the embed.
  String description;
  /// The url of the embed.
  String url;
  /// The color of the embed. Use hexadecimal to define this property.
  int color;

  /// The [EmbedFooter] linked to this embed.
  EmbedFooter footer;
  /// The [EmbedImage] linked to this embed.
  EmbedImage image;
  /// The [EmbedThumbnail] linked to this embed.
  EmbedThumbnail thumbnail;
  /// The [EmbedVideo] linked to this embed.
  EmbedVideo video;
  /// The [EmbedProvider] linked to this embed.
  EmbedProvider provider;
  /// The [EmbedAuthor] linked to this embed.
  EmbedAuthor author;
  /// A [List] of [EmbedField] objects linked to this embed.
  List<EmbedField> fields = [];

  /// Converts the object-based embed definition to an internal API-usable JSON-encodable map.
  Map<String, dynamic> toMap() {
    final finalMap = {
      "title": title,
      "type": type,
      "description": description,
      "url": url,

      "color": color,

      "footer": footer?.toMap(),
      "image": image?.toMap(),
      "thumbnail": thumbnail?.toMap(),
      "video": video?.toMap(),
      "provider": provider?.toMap(),
      "author": author?.toMap(),
      "fields": fields.map((f) => f.toMap())
    };
    return finalMap;
  }
}
class EmbedFooter {
  String text;
  String iconUrl;
  String proxyIconUrl;

  /// The footer of the embed. [text] is required. You may specify [iconUrl] and [proxyIconUrl].
  EmbedFooter(this.text, {this.iconUrl, this.proxyIconUrl});

  dynamic toMap() => {"text": text, "icon_url": iconUrl, "proxy_icon_url": proxyIconUrl};
}
class EmbedImage {
  String url;
  String proxyUrl;
  int height;
  int width;

  /// The image of the embed. [url], [height] and [width] are required. You may specify the [proxyUrl].
  EmbedImage(this.url, this.height, this.width, {this.proxyUrl});

  dynamic toMap() => {"url": url, "proxy_url": proxyUrl, "height": height, "width": width};
}
class EmbedThumbnail {
  String url;
  String proxyUrl;
  int height;
  int width;

  /// The thumbnail of the embed. [url], [height] and [width] are required. You may specify the [proxyUrl].
  EmbedThumbnail(this.url, this.height, this.width, {this.proxyUrl});
  
  dynamic toMap() => {"url": url, "proxy_url": proxyUrl, "height": height, "width": width};
}
class EmbedVideo {
  String url;
  String height;
  String width;

  /// The video of the embed. [url], [height] and [width] are required.
  EmbedVideo(this.url, this.height, this.width);

  dynamic toMap() => {"url": url, "height": height, "width": width};
}
class EmbedProvider {
  String name;
  String url;

  /// The provider of the embed. [name] and [url] are required.
  EmbedProvider(this.name, this.url);

  dynamic toMap() => {"name": url, "url": url};
}
class EmbedAuthor {
  String name;
  String url;
  String iconUrl;
  String proxyIconUrl;

  /// The author of the embed. [name] and [url] are required. You may specify [iconUrl] and [proxyIconUrl].
  EmbedAuthor(this.name, this.url, {this.iconUrl, this.proxyIconUrl});

  dynamic toMap() => {"name": name, "url": url, "icon_url": iconUrl, "proxy_icon_url": proxyIconUrl};
}
class EmbedField {
  String name;
  String value;
  bool inline = false;

  /// A field (of many) in the embed. [name] and [value] are required. You may specify [inline].
  EmbedField(this.name, this.value, {this.inline});

  dynamic toMap() => {"name": name, "value": value, "inline": inline};
}