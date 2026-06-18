import 'package:adzmavall/features/influencer_settings/presentation/models/influencer_settings_models.dart';
import 'package:adzmavall/utils/imageassets.dart';

/// Tap targets for static settings rows (navigation / shell actions — not from DB).
enum InfluencerSettingsAction {
  verifyAccount,
  editProfile,
  mawthooqLicense,
  wallet,
  language,
  shareApp,
  contactUs,
  settings,
  about,
}

/// One static row in the settings list; opens another screen/tab when tapped.
class InfluencerSettingsMenuItem {
  const InfluencerSettingsMenuItem({
    required this.title,
    required this.image,
    required this.action,
    this.trailingText,
    this.trailingAsset,
    this.statusLabel,
  });

  final String title;
  final String image;
  final InfluencerSettingsAction action;
  final String? trailingText;
  final String? trailingAsset;
  final String? statusLabel;
}

class InfluencerSettingsSection {
  const InfluencerSettingsSection({required this.title, required this.items});

  final String title;
  final List<InfluencerSettingsMenuItem> items;
}

/// Hard-coded settings menu and demo profile header (replace profile with API/cubit later).
abstract final class InfluencerSettingsStaticMenu {
  static const InfluencerSettingsProfile demoProfile = InfluencerSettingsProfile(
    name: 'Alya Mostafa',
    title: 'Professional fashion influencer',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=240&q=80',
    verificationPercent: 90,
  );

  static const List<InfluencerSettingsSection> sections =
      <InfluencerSettingsSection>[
        InfluencerSettingsSection(
          title: 'Account',
          items: <InfluencerSettingsMenuItem>[
            InfluencerSettingsMenuItem(
              title: 'Mawthooq License',
              image: ImageAssets.settingsMawthoqIcon,
              action: InfluencerSettingsAction.mawthooqLicense,
              statusLabel: 'Active',
            ),
            InfluencerSettingsMenuItem(
              title: 'Wallet',
              image: ImageAssets.settingsWalletIcon,
              action: InfluencerSettingsAction.wallet,
              trailingText: '17,600',
            ),
          ],
        ),
        InfluencerSettingsSection(
          title: 'General',
          items: <InfluencerSettingsMenuItem>[
            InfluencerSettingsMenuItem(
              title: 'Language',
              image: ImageAssets.settingsLanguageIcon,
              action: InfluencerSettingsAction.language,
            ),
            InfluencerSettingsMenuItem(
              title: 'Share App',
              image: ImageAssets.settingsShareIcon,
              action: InfluencerSettingsAction.shareApp,
            ),
          ],
        ),
        InfluencerSettingsSection(
          title: 'Support',
          items: <InfluencerSettingsMenuItem>[
            InfluencerSettingsMenuItem(
              title: 'Contact Us',
              image: ImageAssets.settingsContactIcon,
              action: InfluencerSettingsAction.contactUs,
            ),
            InfluencerSettingsMenuItem(
              title: 'Settings',
              image: ImageAssets.homeBottomNavSettings,
              action: InfluencerSettingsAction.settings,
            ),
            InfluencerSettingsMenuItem(
              title: 'About',
              image: ImageAssets.settingsInfoIcon,
              action: InfluencerSettingsAction.about,
            ),
          ],
        ),
      ];
}
