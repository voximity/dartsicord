part of dartsicord;

/// An Embed object. Can be self-assembled and sent.
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

  Embed({this.title, this.description, this.url, this.color, this.footer, this.image, this.thumbnail, this.video, this.provider, this.author, this.fields});

  /// Give this embed a title.
  void withTitle(String title) => this.title = title;
  /// Give this embed a description.
  void withDescription(String description) => this.description = description;
  /// Give this embed a clickable URL.
  void withUrl(String url) => this.url = url;
  /// Give this embed a color.
  void withColor(int color) => this.color = color;
  /// Give this embed a footer, given [text] and [iconUrl].
  void withFooter(String text, {String iconUrl}) => footer = new EmbedFooter(text, iconUrl: iconUrl);
  /// Give this embed an image, given [url].
  void withImage(String url) => image = new EmbedImage(url);
  /// Give this embed a thumbnail, given [url].
  void withThumbnail(String url) => thumbnail = new EmbedThumbnail(url);
  /// Give this embed a video, given [url].
  void withVideo(String url) => video = new EmbedVideo(url);
  /// Give this embed a provider, given [name] and [url].
  void withProvider(String name, String url) => provider = new EmbedProvider(name, url);
  /// Give this embed an author, given [name], [url], and [iconUrl].
  void withAuthor(String name, {String url, String iconUrl}) => new EmbedAuthor(name, url: url, iconUrl: iconUrl);
  /// Add a field to this embed.
  void addField(String title, dynamic value, {bool inline = false}) => fields.add(new EmbedField(title, value.toString(), inline: inline));

  /// Converts the object-based embed definition to an internal API-usable JSON-encodable map.
  Map<String, dynamic> _toMap() {
    final fieldsList = fields.fold([], (p, c) => p..add(c._toMap()));
    final response = {
      "title": title,
      "type": type,
      "description": description,
      "url": url,

      "color": color,

      "footer": footer?._toMap(),
      "image": image?._toMap(),
      "thumbnail": thumbnail?._toMap(),
      "video": video?._toMap(),
      "provider": provider?._toMap(),
      "author": author?._toMap(),
      "fields": fieldsList
    };
    
    return response;
  }
}

/// An [Embed] footer object. Can be self-assembled for an [Embed], or chained on the original [Embed].
class EmbedFooter {
  String text;
  String iconUrl;
  String proxyIconUrl;

  /// The footer of the embed. [text] is required. You may specify [iconUrl].
  EmbedFooter(this.text, {this.iconUrl});

  Map<String, dynamic> _toMap() => {"text": text, "icon_url": iconUrl, "proxy_icon_url": proxyIconUrl};
}

/// An [Embed] image object. Can be self-assembled for an [Embed], or chained on the original [Embed].
class EmbedImage {
  String url;
  String proxyUrl;
  int height;
  int width;

  /// The image of the embed. [url] is required.
  EmbedImage(this.url, {this.height, this.width, this.proxyUrl});

  Map<String, dynamic> _toMap() => {"url": url, "proxy_url": proxyUrl, "height": height, "width": width};
}

/// An [Embed] thumbnail object. Can be self-assembled for an [Embed], or chained on the original [Embed].
class EmbedThumbnail {
  String url;
  String proxyUrl;
  int height;
  int width;

  /// The thumbnail of the embed. [url] is required.
  EmbedThumbnail(this.url, {this.height, this.width, this.proxyUrl});
  
  Map<String, dynamic> _toMap() => {"url": url, "proxy_url": proxyUrl, "height": height, "width": width};
}

/// An [Embed] video object. Can be self-assembled for an [Embed], or chained on the original [Embed].
class EmbedVideo {
  String url;
  String height;
  String width;

  /// The video of the embed. [url] is required.
  EmbedVideo(this.url);

  Map<String, dynamic> _toMap() => {"url": url, "height": height, "width": width};
}

/// An [Embed] provider object. Can be self-assembled for an [Embed], or chained on the original [Embed].
class EmbedProvider {
  String name;
  String url;

  /// The provider of the embed. [name] and [url] are required.
  EmbedProvider(this.name, this.url);

  Map<String, dynamic> _toMap() => {"name": url, "url": url};
}

/// An [Embed] author object. Can be self-assembled for an [Embed], or chained on the original [Embed].
class EmbedAuthor {
  String name;
  String url;
  String iconUrl;
  String proxyIconUrl;

  /// The author of the embed. [name] and [url] are required. You may specify [iconUrl].
  EmbedAuthor(this.name, {this.url, this.iconUrl});

  Map<String, dynamic> _toMap() => {"name": name, "url": url, "icon_url": iconUrl, "proxy_icon_url": proxyIconUrl};
}

/// An [Embed] field object. Can be self-assembled for an [Embed], or chained on the original [Embed].
class EmbedField {
  String name;
  String value;
  bool inline = false;

  /// A field (of many) in the embed. [name] and [value] are required. You may specify [inline].
  EmbedField(this.name, this.value, {this.inline = false});

  Map<String, dynamic> _toMap() => {"name": name, "value": value, "inline": inline};
}