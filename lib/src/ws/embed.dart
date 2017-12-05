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

  dynamic toDynamic() {
    final fieldsMap = [];
    fields.forEach((f) => fieldsMap.add(f.toDynamic()));
    
    final finalDynamic = {
      "title": title,
      "type": type,
      "description": description,
      "url": url,

      "color": color,

      "footer": footer?.toDynamic(),
      "image": image?.toDynamic(),
      "thumbnail": thumbnail?.toDynamic(),
      "video": video?.toDynamic(),
      "provider": provider?.toDynamic(),
      "author": author?.toDynamic(),
      "fields": fieldsMap
    };
    return finalDynamic;
  }
}
class EmbedFooter {
  String text;
  String iconUrl;
  String proxyIconUrl;

  EmbedFooter(this.text, {this.iconUrl, this.proxyIconUrl});

  dynamic toDynamic() => {"text": text, "icon_url": iconUrl, "proxy_icon_url": proxyIconUrl};
}
class EmbedImage {
  String url;
  String proxyUrl;
  int height;
  int width;

  EmbedImage(this.url, this.height, this.width, {this.proxyUrl});

  dynamic toDynamic() => {"url": url, "proxy_url": proxyUrl, "height": height, "width": width};
}
class EmbedThumbnail {
  String url;
  String proxyUrl;
  int height;
  int width;

  EmbedThumbnail(this.url, this.height, this.width, {this.proxyUrl});
  
  dynamic toDynamic() => {"url": url, "proxy_url": proxyUrl, "height": height, "width": width};
}
class EmbedVideo {
  String url;
  String height;
  String width;

  EmbedVideo(this.url, this.height, this.width);

  dynamic toDynamic() => {"url": url, "height": height, "width": width};
}
class EmbedProvider {
  String name;
  String url;

  EmbedProvider(this.name, this.url);

  dynamic toDynamic() => {"name": url, "url": url};
}
class EmbedAuthor {
  String name;
  String url;
  String iconUrl;
  String proxyIconUrl;

  EmbedAuthor(this.name, this.url, {this.iconUrl, this.proxyIconUrl});

  dynamic toDynamic() => {"name": name, "url": url, "icon_url": iconUrl, "proxy_icon_url": proxyIconUrl};
}
class EmbedField {
  String name;
  String value;
  bool inline;

  EmbedField(this.name, this.value, {this.inline});

  dynamic toDynamic() => {"name": name, "value": value, "inline": inline};
}