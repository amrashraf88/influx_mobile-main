/// Influencer profile fields that can be loaded from the backend (not menu rows).
class InfluencerSettingsProfile {
  const InfluencerSettingsProfile({
    required this.name,
    required this.title,
    required this.avatarUrl,
    required this.verificationPercent,
  });

  final String name;
  final String title;
  final String avatarUrl;
  final int verificationPercent;

  factory InfluencerSettingsProfile.fromJson(Map<String, dynamic> json) {
    return InfluencerSettingsProfile(
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      verificationPercent: json['verification_percent'] as int? ?? 0,
    );
  }

  double get verificationProgress {
    return (verificationPercent.clamp(0, 100)) / 100;
  }

  bool get shouldShowVerificationCard => verificationPercent < 100;
}
