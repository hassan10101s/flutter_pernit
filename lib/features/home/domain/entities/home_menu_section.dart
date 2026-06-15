import 'package:equatable/equatable.dart';

enum HomeMenuSection {
  overview,
  inventory,
  quality,
  production,
  commercial,
  settings,
}

class HomeMenuPolicy extends Equatable {
  final Set<String> groups;

  HomeMenuPolicy(List<String> groups)
    : groups = groups.map((group) => group.trim().toLowerCase()).toSet();

  bool get isAdmin {
    return groups.contains('admin') ||
        groups.contains('system admin') ||
        groups.contains('superuser');
  }

  List<HomeMenuSection> visibleSections() {
    final sections = <HomeMenuSection>{HomeMenuSection.overview};

    if (isAdmin) {
      sections.addAll(const [
        HomeMenuSection.inventory,
        HomeMenuSection.quality,
        HomeMenuSection.production,
        HomeMenuSection.commercial,
        HomeMenuSection.settings,
      ]);
      return sections.toList(growable: false);
    }

    if (groups.contains('inventory')) {
      sections.add(HomeMenuSection.inventory);
    }

    if (groups.contains('quality')) {
      sections.add(HomeMenuSection.quality);
    }

    if (groups.contains('production')) {
      sections.add(HomeMenuSection.production);
    }

    if (groups.contains('sales') ||
        groups.contains('purchase') ||
        groups.contains('purchases')) {
      sections.add(HomeMenuSection.commercial);
    }

    if (groups.contains('standard user')) {
      return sections.toList(growable: false);
    }

    return sections.toList(growable: false);
  }

  @override
  List<Object?> get props => [groups];
}
