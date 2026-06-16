import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/screen_records/pernit_screen_record.dart';
import 'package:flutter_pernit/features/screen_records/presentation/bloc/screen_records_state.dart';
import 'package:flutter_pernit/features/settings/presentation/bloc/settings_record_cubits.dart';

void main() {
  test('units cubit manages records through its own repository', () async {
    final cubit = UnitsRecordsCubit(
      UnitsRecordsRepository(const [
        PernitScreenRecord.api(
          title: 'KG',
          fields: {
            'short_code': 'KG',
            'name': 'Kilogram',
            'to_base_factor': '1.000000000',
          },
        ),
      ]),
    );

    await cubit.load();
    expect(cubit.state, isA<ScreenRecordsLoaded>());
    expect(cubit.state.records.single.title, 'KG');

    await cubit.addRecord(
      const PernitScreenRecord.api(
        title: 'TON',
        fields: {
          'short_code': 'TON',
          'name': 'Metric ton',
          'to_base_factor': '1000.000000000',
        },
      ),
    );
    expect(cubit.state.records, hasLength(2));

    await cubit.updateRecord(
      1,
      const PernitScreenRecord.api(
        title: 'MT',
        fields: {
          'short_code': 'MT',
          'name': 'Metric ton',
          'to_base_factor': '1000.000000000',
        },
      ),
    );
    expect(cubit.state.records.last.title, 'MT');

    await cubit.deleteRecord(0);
    expect(cubit.state.records.single.title, 'MT');

    await cubit.close();
  });
}
