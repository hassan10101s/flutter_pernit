import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/features/home/domain/entities/home_menu_section.dart';

void main() {
  test('admin groups see settings and core operation tabs', () {
    final sections = HomeMenuPolicy(const ['System Admin']).visibleSections();

    expect(sections, contains(HomeMenuSection.overview));
    expect(sections, contains(HomeMenuSection.inventory));
    expect(sections, contains(HomeMenuSection.quality));
    expect(sections, contains(HomeMenuSection.production));
    expect(sections, contains(HomeMenuSection.commercial));
    expect(sections, contains(HomeMenuSection.settings));
  });

  test(
    'standard user sees overview only until backend group meaning is defined',
    () {
      final sections = HomeMenuPolicy(const [
        'Standard User',
      ]).visibleSections();

      expect(sections, contains(HomeMenuSection.overview));
      expect(sections, isNot(contains(HomeMenuSection.inventory)));
      expect(sections, isNot(contains(HomeMenuSection.quality)));
      expect(sections, isNot(contains(HomeMenuSection.settings)));
    },
  );

  test('specific business groups see only their matching menu', () {
    final sections = HomeMenuPolicy(const ['Quality']).visibleSections();

    expect(sections, contains(HomeMenuSection.overview));
    expect(sections, contains(HomeMenuSection.quality));
    expect(sections, isNot(contains(HomeMenuSection.inventory)));
    expect(sections, isNot(contains(HomeMenuSection.settings)));
  });

  test('inventory group can access raw material entry menu', () {
    final sections = HomeMenuPolicy(const ['Inventory']).visibleSections();

    expect(sections, contains(HomeMenuSection.commercial));
    expect(sections, contains(HomeMenuSection.inventory));
  });
}
