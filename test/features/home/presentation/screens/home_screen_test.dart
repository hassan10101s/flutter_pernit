import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/core/localization/generated/app_localizations.dart';
import 'package:flutter_pernit/design_system/tokens/pernit_colors.dart';
import 'package:flutter_pernit/design_system/tokens/pernit_text_theme.dart';
import 'package:flutter_pernit/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_pernit/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_pernit/features/auth/domain/entities/login_credentials.dart';
import 'package:flutter_pernit/features/auth/domain/repos/auth_repository.dart';
import 'package:flutter_pernit/features/auth/domain/usecases/logout_use_case.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/logout_cubit.dart';
import 'package:flutter_pernit/features/home/presentation/screens/home_screen.dart';

void main() {
  const adminUser = AuthUser(
    id: 1,
    username: 'admin',
    email: 'admin@example.com',
    firstName: 'Ahmed',
    lastName: 'Hassan',
    groups: ['System Admin'],
  );

  testWidgets('wide home layout shows branded side menu', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpHome(adminUser);

    expect(find.text('Pernit ERP'), findsOneWidget);
    expect(find.text('Ahmed Hassan'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });

  testWidgets('mobile home layout uses compact bottom menu', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpHome(adminUser);

    expect(find.text('Pernit ERP'), findsNothing);
    expect(find.byIcon(Icons.grid_view_rounded), findsNothing);
    expect(find.text('Overview'), findsWidgets);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpHome(AuthUser user) async {
    await pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: false,
        splitScreenMode: true,
        builder: (context, child) {
          final textTheme = PernitTextTheme.build();

          return MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: PernitTextTheme.cairoFontFamily,
              textTheme: textTheme,
              colorScheme: ColorScheme.fromSeed(
                seedColor: PernitColors.primary,
              ),
            ),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: BlocProvider(
              create: (_) => LogoutCubit(LogoutUseCase(_FakeAuthRepository())),
              child: HomeScreen(user: user),
            ),
          );
        },
      ),
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<AuthSession>> login(LoginCredentials credentials) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<ApiResult<AuthSession>> restoreSession() {
    throw UnimplementedError();
  }
}
