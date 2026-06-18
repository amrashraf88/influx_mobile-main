import 'package:adzmavall/core/lookup/lookup_item.dart';
import 'package:adzmavall/core/lookup/lookup_page_result.dart';
import 'package:adzmavall/core/lookup/lookup_repository.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LookupLoadStatus { initial, loading, loaded, failure }

class ProfileLookupsState extends Equatable {
  const ProfileLookupsState({
    this.categoriesStatus = LookupLoadStatus.initial,
    this.citiesStatus = LookupLoadStatus.initial,
    this.directionsStatus = LookupLoadStatus.initial,
    this.socialPlatformsStatus = LookupLoadStatus.initial,
    this.creatorTypesStatus = LookupLoadStatus.initial,
    this.modelAccentsStatus = LookupLoadStatus.initial,
    this.modelSizesStatus = LookupLoadStatus.initial,
    this.modelSkinTonesStatus = LookupLoadStatus.initial,
    this.categories = const <LookupItem>[],
    this.cities = const <LookupItem>[],
    this.directions = const <LookupItem>[],
    this.socialPlatforms = const <LookupItem>[],
    this.creatorTypes = const <LookupItem>[],
    this.modelAccents = const <LookupItem>[],
    this.modelSizes = const <LookupItem>[],
    this.modelSkinTones = const <LookupItem>[],
    this.adContentTypesByPlatform = const <String, List<LookupItem>>{},
    this.adContentTypesStatusByPlatform =
        const <String, LookupLoadStatus>{},
    this.adContentTypesErrorByPlatform = const <String, String?>{},
    this.categoriesHasMore = false,
    this.categoriesLoadingMore = false,
    this.categoriesCurrentPage = 1,
    this.categoriesError,
    this.citiesError,
    this.directionsError,
    this.socialPlatformsError,
    this.creatorTypesError,
    this.modelAccentsError,
    this.modelSizesError,
    this.modelSkinTonesError,
  });

  final LookupLoadStatus categoriesStatus;
  final LookupLoadStatus citiesStatus;
  final LookupLoadStatus directionsStatus;
  final LookupLoadStatus socialPlatformsStatus;
  final LookupLoadStatus creatorTypesStatus;
  final LookupLoadStatus modelAccentsStatus;
  final LookupLoadStatus modelSizesStatus;
  final LookupLoadStatus modelSkinTonesStatus;
  final List<LookupItem> categories;
  final List<LookupItem> cities;
  final List<LookupItem> directions;
  final List<LookupItem> socialPlatforms;
  final List<LookupItem> creatorTypes;
  final List<LookupItem> modelAccents;
  final List<LookupItem> modelSizes;
  final List<LookupItem> modelSkinTones;
  final Map<String, List<LookupItem>> adContentTypesByPlatform;
  final Map<String, LookupLoadStatus> adContentTypesStatusByPlatform;
  final Map<String, String?> adContentTypesErrorByPlatform;
  final bool categoriesHasMore;
  final bool categoriesLoadingMore;
  final int categoriesCurrentPage;
  final String? categoriesError;
  final String? citiesError;
  final String? directionsError;
  final String? socialPlatformsError;
  final String? creatorTypesError;
  final String? modelAccentsError;
  final String? modelSizesError;
  final String? modelSkinTonesError;

  bool get categoriesLoading => categoriesStatus == LookupLoadStatus.loading;
  bool get citiesLoading => citiesStatus == LookupLoadStatus.loading;
  bool get directionsLoading => directionsStatus == LookupLoadStatus.loading;
  bool get socialPlatformsLoading =>
      socialPlatformsStatus == LookupLoadStatus.loading;
  bool get creatorTypesLoading =>
      creatorTypesStatus == LookupLoadStatus.loading;
  bool get modelAccentsLoading =>
      modelAccentsStatus == LookupLoadStatus.loading;
  bool get modelSizesLoading => modelSizesStatus == LookupLoadStatus.loading;
  bool get modelSkinTonesLoading =>
      modelSkinTonesStatus == LookupLoadStatus.loading;

  LookupLoadStatus adContentTypesStatusFor(String platform) {
    final String key = platform.trim().toLowerCase();
    return adContentTypesStatusByPlatform[key] ?? LookupLoadStatus.initial;
  }

  List<LookupItem> adContentTypesFor(String platform) {
    final String key = platform.trim().toLowerCase();
    return adContentTypesByPlatform[key] ?? const <LookupItem>[];
  }

  String? adContentTypesErrorFor(String platform) {
    final String key = platform.trim().toLowerCase();
    return adContentTypesErrorByPlatform[key];
  }

  @override
  List<Object?> get props => <Object?>[
    categoriesStatus,
    citiesStatus,
    directionsStatus,
    socialPlatformsStatus,
    creatorTypesStatus,
    modelAccentsStatus,
    modelSizesStatus,
    modelSkinTonesStatus,
    categories,
    cities,
    directions,
    socialPlatforms,
    creatorTypes,
    modelAccents,
    modelSizes,
    modelSkinTones,
    adContentTypesByPlatform,
    adContentTypesStatusByPlatform,
    adContentTypesErrorByPlatform,
    categoriesHasMore,
    categoriesLoadingMore,
    categoriesCurrentPage,
    categoriesError,
    citiesError,
    directionsError,
    socialPlatformsError,
    creatorTypesError,
    modelAccentsError,
    modelSizesError,
    modelSkinTonesError,
  ];

  ProfileLookupsState copyWith({
    LookupLoadStatus? categoriesStatus,
    LookupLoadStatus? citiesStatus,
    LookupLoadStatus? directionsStatus,
    LookupLoadStatus? socialPlatformsStatus,
    LookupLoadStatus? creatorTypesStatus,
    LookupLoadStatus? modelAccentsStatus,
    LookupLoadStatus? modelSizesStatus,
    LookupLoadStatus? modelSkinTonesStatus,
    List<LookupItem>? categories,
    List<LookupItem>? cities,
    List<LookupItem>? directions,
    List<LookupItem>? socialPlatforms,
    List<LookupItem>? creatorTypes,
    List<LookupItem>? modelAccents,
    List<LookupItem>? modelSizes,
    List<LookupItem>? modelSkinTones,
    Map<String, List<LookupItem>>? adContentTypesByPlatform,
    Map<String, LookupLoadStatus>? adContentTypesStatusByPlatform,
    Map<String, String?>? adContentTypesErrorByPlatform,
    bool? categoriesHasMore,
    bool? categoriesLoadingMore,
    int? categoriesCurrentPage,
    String? categoriesError,
    String? citiesError,
    String? directionsError,
    String? socialPlatformsError,
    String? creatorTypesError,
    String? modelAccentsError,
    String? modelSizesError,
    String? modelSkinTonesError,
    bool clearCategoriesError = false,
    bool clearCitiesError = false,
    bool clearDirectionsError = false,
    bool clearSocialPlatformsError = false,
    bool clearCreatorTypesError = false,
    bool clearModelAccentsError = false,
    bool clearModelSizesError = false,
    bool clearModelSkinTonesError = false,
  }) {
    return ProfileLookupsState(
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      citiesStatus: citiesStatus ?? this.citiesStatus,
      directionsStatus: directionsStatus ?? this.directionsStatus,
      socialPlatformsStatus:
          socialPlatformsStatus ?? this.socialPlatformsStatus,
      creatorTypesStatus: creatorTypesStatus ?? this.creatorTypesStatus,
      modelAccentsStatus: modelAccentsStatus ?? this.modelAccentsStatus,
      modelSizesStatus: modelSizesStatus ?? this.modelSizesStatus,
      modelSkinTonesStatus: modelSkinTonesStatus ?? this.modelSkinTonesStatus,
      categories: categories ?? this.categories,
      cities: cities ?? this.cities,
      directions: directions ?? this.directions,
      socialPlatforms: socialPlatforms ?? this.socialPlatforms,
      creatorTypes: creatorTypes ?? this.creatorTypes,
      modelAccents: modelAccents ?? this.modelAccents,
      modelSizes: modelSizes ?? this.modelSizes,
      modelSkinTones: modelSkinTones ?? this.modelSkinTones,
      adContentTypesByPlatform:
          adContentTypesByPlatform ?? this.adContentTypesByPlatform,
      adContentTypesStatusByPlatform: adContentTypesStatusByPlatform ??
          this.adContentTypesStatusByPlatform,
      adContentTypesErrorByPlatform: adContentTypesErrorByPlatform ??
          this.adContentTypesErrorByPlatform,
      categoriesHasMore: categoriesHasMore ?? this.categoriesHasMore,
      categoriesLoadingMore:
          categoriesLoadingMore ?? this.categoriesLoadingMore,
      categoriesCurrentPage:
          categoriesCurrentPage ?? this.categoriesCurrentPage,
      categoriesError: clearCategoriesError
          ? null
          : categoriesError ?? this.categoriesError,
      citiesError: clearCitiesError ? null : citiesError ?? this.citiesError,
      directionsError: clearDirectionsError
          ? null
          : directionsError ?? this.directionsError,
      socialPlatformsError: clearSocialPlatformsError
          ? null
          : socialPlatformsError ?? this.socialPlatformsError,
      creatorTypesError: clearCreatorTypesError
          ? null
          : creatorTypesError ?? this.creatorTypesError,
      modelAccentsError: clearModelAccentsError
          ? null
          : modelAccentsError ?? this.modelAccentsError,
      modelSizesError: clearModelSizesError
          ? null
          : modelSizesError ?? this.modelSizesError,
      modelSkinTonesError: clearModelSkinTonesError
          ? null
          : modelSkinTonesError ?? this.modelSkinTonesError,
    );
  }
}

class ProfileLookupsCubit extends Cubit<ProfileLookupsState> {
  ProfileLookupsCubit(this._repository) : super(const ProfileLookupsState()) {
    loadAll();
  }

  final LookupRepository _repository;

  Future<void> loadAll() async {
    await Future.wait(<Future<void>>[
      loadCategories(),
      loadCities(),
      loadDirections(),
      loadSocialPlatforms(),
      loadCreatorTypes(),
      loadModelAccents(),
      loadModelSizes(),
      loadModelSkinTones(),
    ]);
  }

  Future<void> loadCategories() async {
    emit(
      state.copyWith(
        categoriesStatus: LookupLoadStatus.loading,
        categoriesLoadingMore: false,
        categoriesHasMore: false,
        categoriesCurrentPage: 1,
        clearCategoriesError: true,
      ),
    );
    try {
      final LookupPageResult page = await _repository.fetchCategories(page: 1);
      emit(
        state.copyWith(
          categoriesStatus: LookupLoadStatus.loaded,
          categories: page.items,
          categoriesHasMore: page.hasMore,
          categoriesCurrentPage: page.currentPage,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          categoriesStatus: LookupLoadStatus.failure,
          categoriesError: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          categoriesStatus: LookupLoadStatus.failure,
          categoriesError: 'Could not load categories. Please try again.',
        ),
      );
    }
  }

  Future<void> loadMoreCategories() async {
    if (!state.categoriesHasMore ||
        state.categoriesLoadingMore ||
        state.categoriesLoading) {
      return;
    }

    final int nextPage = state.categoriesCurrentPage + 1;
    emit(state.copyWith(categoriesLoadingMore: true, clearCategoriesError: true));
    try {
      final LookupPageResult page = await _repository.fetchCategories(
        page: nextPage,
      );
      emit(
        state.copyWith(
          categoriesLoadingMore: false,
          categories: _mergeLookupItems(state.categories, page.items),
          categoriesHasMore: page.hasMore,
          categoriesCurrentPage: page.currentPage,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          categoriesLoadingMore: false,
          categoriesError: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          categoriesLoadingMore: false,
          categoriesError: 'Could not load more categories. Please try again.',
        ),
      );
    }
  }

  Future<void> loadCities() => _load(
    fetch: _repository.fetchCities,
    onLoading: (ProfileLookupsState s) => s.copyWith(
      citiesStatus: LookupLoadStatus.loading,
      clearCitiesError: true,
    ),
    onSuccess: (ProfileLookupsState s, List<LookupItem> items) => s.copyWith(
      citiesStatus: LookupLoadStatus.loaded,
      cities: items,
    ),
    onFailure: (ProfileLookupsState s, String message) => s.copyWith(
      citiesStatus: LookupLoadStatus.failure,
      citiesError: message,
    ),
    fallbackError: 'Could not load cities. Please try again.',
  );

  Future<void> loadDirections() => _load(
    fetch: _repository.fetchCityDirections,
    onLoading: (ProfileLookupsState s) => s.copyWith(
      directionsStatus: LookupLoadStatus.loading,
      clearDirectionsError: true,
    ),
    onSuccess: (ProfileLookupsState s, List<LookupItem> items) => s.copyWith(
      directionsStatus: LookupLoadStatus.loaded,
      directions: items,
    ),
    onFailure: (ProfileLookupsState s, String message) => s.copyWith(
      directionsStatus: LookupLoadStatus.failure,
      directionsError: message,
    ),
    fallbackError: 'Could not load directions. Please try again.',
  );

  Future<void> loadSocialPlatforms() => _load(
    fetch: _repository.fetchSocialPlatforms,
    onLoading: (ProfileLookupsState s) => s.copyWith(
      socialPlatformsStatus: LookupLoadStatus.loading,
      clearSocialPlatformsError: true,
    ),
    onSuccess: (ProfileLookupsState s, List<LookupItem> items) => s.copyWith(
      socialPlatformsStatus: LookupLoadStatus.loaded,
      socialPlatforms: items,
    ),
    onFailure: (ProfileLookupsState s, String message) => s.copyWith(
      socialPlatformsStatus: LookupLoadStatus.failure,
      socialPlatformsError: message,
    ),
    fallbackError: 'Could not load social platforms. Please try again.',
  );

  Future<void> loadCreatorTypes() => _load(
    fetch: _repository.fetchContentCreatorTypes,
    onLoading: (ProfileLookupsState s) => s.copyWith(
      creatorTypesStatus: LookupLoadStatus.loading,
      clearCreatorTypesError: true,
    ),
    onSuccess: (ProfileLookupsState s, List<LookupItem> items) => s.copyWith(
      creatorTypesStatus: LookupLoadStatus.loaded,
      creatorTypes: items,
    ),
    onFailure: (ProfileLookupsState s, String message) => s.copyWith(
      creatorTypesStatus: LookupLoadStatus.failure,
      creatorTypesError: message,
    ),
    fallbackError: 'Could not load creator types. Please try again.',
  );

  Future<void> loadModelAccents() => _load(
    fetch: _repository.fetchModelCreatorAccents,
    onLoading: (ProfileLookupsState s) => s.copyWith(
      modelAccentsStatus: LookupLoadStatus.loading,
      clearModelAccentsError: true,
    ),
    onSuccess: (ProfileLookupsState s, List<LookupItem> items) => s.copyWith(
      modelAccentsStatus: LookupLoadStatus.loaded,
      modelAccents: items,
    ),
    onFailure: (ProfileLookupsState s, String message) => s.copyWith(
      modelAccentsStatus: LookupLoadStatus.failure,
      modelAccentsError: message,
    ),
    fallbackError: 'Could not load accents. Please try again.',
  );

  Future<void> loadModelSizes() => _load(
    fetch: _repository.fetchModelCreatorSizes,
    onLoading: (ProfileLookupsState s) => s.copyWith(
      modelSizesStatus: LookupLoadStatus.loading,
      clearModelSizesError: true,
    ),
    onSuccess: (ProfileLookupsState s, List<LookupItem> items) => s.copyWith(
      modelSizesStatus: LookupLoadStatus.loaded,
      modelSizes: items,
    ),
    onFailure: (ProfileLookupsState s, String message) => s.copyWith(
      modelSizesStatus: LookupLoadStatus.failure,
      modelSizesError: message,
    ),
    fallbackError: 'Could not load sizes. Please try again.',
  );

  Future<void> loadModelSkinTones() => _load(
    fetch: _repository.fetchModelCreatorSkinTones,
    onLoading: (ProfileLookupsState s) => s.copyWith(
      modelSkinTonesStatus: LookupLoadStatus.loading,
      clearModelSkinTonesError: true,
    ),
    onSuccess: (ProfileLookupsState s, List<LookupItem> items) => s.copyWith(
      modelSkinTonesStatus: LookupLoadStatus.loaded,
      modelSkinTones: items,
    ),
    onFailure: (ProfileLookupsState s, String message) => s.copyWith(
      modelSkinTonesStatus: LookupLoadStatus.failure,
      modelSkinTonesError: message,
    ),
    fallbackError: 'Could not load skin tones. Please try again.',
  );

  Future<void> loadAdContentTypes(
    String socialPlatform, {
    bool force = false,
  }) async {
    final String platform = socialPlatform.trim().toLowerCase();
    if (platform.isEmpty) {
      return;
    }

    final LookupLoadStatus? current =
        state.adContentTypesStatusByPlatform[platform];
    if (!force &&
        (current == LookupLoadStatus.loading ||
            current == LookupLoadStatus.loaded)) {
      return;
    }

    emit(
      state.copyWith(
        adContentTypesStatusByPlatform: <String, LookupLoadStatus>{
          ...state.adContentTypesStatusByPlatform,
          platform: LookupLoadStatus.loading,
        },
        adContentTypesErrorByPlatform: <String, String?>{
          ...state.adContentTypesErrorByPlatform,
          platform: null,
        },
      ),
    );

    try {
      final List<LookupItem> items = await _repository.fetchAdContentTypes(
        socialPlatform: platform,
      );
      emit(
        state.copyWith(
          adContentTypesStatusByPlatform: <String, LookupLoadStatus>{
            ...state.adContentTypesStatusByPlatform,
            platform: LookupLoadStatus.loaded,
          },
          adContentTypesByPlatform: <String, List<LookupItem>>{
            ...state.adContentTypesByPlatform,
            platform: items,
          },
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          adContentTypesStatusByPlatform: <String, LookupLoadStatus>{
            ...state.adContentTypesStatusByPlatform,
            platform: LookupLoadStatus.failure,
          },
          adContentTypesErrorByPlatform: <String, String?>{
            ...state.adContentTypesErrorByPlatform,
            platform: e.message,
          },
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          adContentTypesStatusByPlatform: <String, LookupLoadStatus>{
            ...state.adContentTypesStatusByPlatform,
            platform: LookupLoadStatus.failure,
          },
          adContentTypesErrorByPlatform: <String, String?>{
            ...state.adContentTypesErrorByPlatform,
            platform: 'Could not load ad content types. Please try again.',
          },
        ),
      );
    }
  }

  static List<LookupItem> _mergeLookupItems(
    List<LookupItem> existing,
    List<LookupItem> incoming,
  ) {
    final Map<String, LookupItem> merged = <String, LookupItem>{
      for (final LookupItem item in existing) item.value: item,
    };
    for (final LookupItem item in incoming) {
      merged[item.value] = item;
    }
    return merged.values.toList();
  }

  Future<void> _load({
    required Future<List<LookupItem>> Function() fetch,
    required ProfileLookupsState Function(ProfileLookupsState) onLoading,
    required ProfileLookupsState Function(ProfileLookupsState, List<LookupItem>)
    onSuccess,
    required ProfileLookupsState Function(ProfileLookupsState, String)
    onFailure,
    required String fallbackError,
  }) async {
    emit(onLoading(state));
    try {
      final List<LookupItem> items = await fetch();
      emit(onSuccess(state, items));
    } on ApiException catch (e) {
      emit(onFailure(state, e.message));
    } catch (_) {
      emit(onFailure(state, fallbackError));
    }
  }
}
