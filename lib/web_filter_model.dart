
class WebFilterSettings {
  bool blockAdultContent;
  bool blockSocialMedia;
  List<String> allowedWebsites;
  List<String> blockedWebsites;

  WebFilterSettings({
    this.blockAdultContent = true,
    this.blockSocialMedia = false,
    this.allowedWebsites = const [],
    this.blockedWebsites = const [],
  });

  factory WebFilterSettings.fromMap(Map<String, dynamic> map) {
    return WebFilterSettings(
      blockAdultContent: map['blockAdultContent'] ?? true,
      blockSocialMedia: map['blockSocialMedia'] ?? false,
      allowedWebsites: List<String>.from(map['allowedWebsites'] ?? []),
      blockedWebsites: List<String>.from(map['blockedWebsites'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blockAdultContent': blockAdultContent,
      'blockSocialMedia': blockSocialMedia,
      'allowedWebsites': allowedWebsites,
      'blockedWebsites': blockedWebsites,
    };
  }
}
