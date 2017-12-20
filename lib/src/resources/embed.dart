import "dart:convert";

class Embed {
  String title;
  String type = "rich";
  String description;
  String url;
  int color;

  EmbedFooter footer;
  EmbedImage image;
  EmbedThumbnail thumbnail;
  EmbedVideo video;
  EmbedProvider provider;
  EmbedAuthor author;
  List<EmbedField> fields = [];

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

  EmbedFooter(this.text, {this.iconUrl, this.proxyIconUrl});

  dynamic toMap() => {"text": text, "icon_url": iconUrl, "proxy_icon_url": proxyIconUrl};
}
class EmbedImage {
  String url;
  String proxyUrl;
  int height;
  int width;

  EmbedImage(this.url, this.height, this.width, {this.proxyUrl});

  dynamic toMap() => {"url": url, "proxy_url": proxyUrl, "height": height, "width": width};
}
class EmbedThumbnail {
  String url;
  String proxyUrl;
  int height;
  int width;

  EmbedThumbnail(this.url, this.height, this.width, {this.proxyUrl});
  
  dynamic toMap() => {"url": url, "proxy_url": proxyUrl, "height": height, "width": width};
}
class EmbedVideo {
  String url;
  String height;
  String width;

  EmbedVideo(this.url, this.height, this.width);

  dynamic toMap() => {"url": url, "height": height, "width": width};
}
class EmbedProvider {
  String name;
  String url;

  EmbedProvider(this.name, this.url);

  dynamic toMap() => {"name": url, "url": url};
}
class EmbedAuthor {
  String name;
  String url;
  String iconUrl;
  String proxyIconUrl;

  EmbedAuthor(this.name, this.url, {this.iconUrl, this.proxyIconUrl});

  dynamic toMap() => {"name": name, "url": url, "icon_url": iconUrl, "proxy_icon_url": proxyIconUrl};
}
class EmbedField {
  String name;
  String value;
  bool inline;

  EmbedField(this.name, this.value, {this.inline});

  dynamic toMap() => {"name": name, "value": value, "inline": inline};
}