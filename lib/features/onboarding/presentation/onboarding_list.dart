import 'package:adzmavall/features/onboarding/presentation/models/onboarding_model.dart';
import 'package:adzmavall/utils/imageassets.dart';

const List<OnboardingModel> onboardingList = <OnboardingModel>[
  OnboardingModel(
    imagePath: ImageAssets.onboarding1Image,
    titleImagePath: ImageAssets.onboarding1Title,
    descriptionKey: 'onboarding_list_description_1',
  ),
  OnboardingModel(
    imagePath: ImageAssets.onboarding2Image,
    titleImagePath: ImageAssets.onboarding2Title,
    descriptionKey: 'onboarding_list_description_2',
  ),
  OnboardingModel(
    imagePath: ImageAssets.onboarding3Image,
    titleImagePath: ImageAssets.onboarding3Title,
    descriptionKey: 'onboarding_list_description_3',
  ),
];
