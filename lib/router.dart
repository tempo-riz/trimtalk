// GoRouter configuration
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/files/permissions.dart';
import 'package:trim_talk/main.dart';
import 'package:trim_talk/types/result.dart';
import 'package:trim_talk/view/dashboard_screen.dart';
import 'package:trim_talk/view/explain_screen.dart';
import 'package:trim_talk/view/permissions_screen.dart';
import 'package:trim_talk/view/settings_screen.dart';
import 'package:trim_talk/view/transcript_screen.dart';

enum NamedRoutes {
  explain,
  permissions,
  dashboard,
  transcript,
  settings,
}

/// if user finished tuto and accepted permissions
Future<bool> isSetupOk() async {
  final ack = DB.getPref<bool>(Prefs.isTutoDone);
  if (!ack) return false;

  final allowed = await Permissions.isReadFilesAllowed();
  if (!allowed) return false;

  return true;
}

Future<String> getFirstRoute() async {
  final ack = DB.getPref(Prefs.isAcknowledged);
  if (!ack) return '/explain';

  final allowed = await Permissions.isReadFilesAllowed();
  if (!allowed) return '/permissions';

  return '/dashboard';
}

GoRoute buildRoute(NamedRoutes r, Widget Function(BuildContext, GoRouterState)? builder) {
  return GoRoute(
    path: "/${r.name}",
    name: r.name,
    builder: builder,
  );
}

final router = GoRouter(
  initialLocation: firstRoute,
  routes: [
    buildRoute(NamedRoutes.explain, (context, state) => const ExplainScreen()),
    buildRoute(NamedRoutes.permissions, (context, state) => const PermissionsScreen()),
    buildRoute(NamedRoutes.dashboard, (context, state) => const DashboardScreen()),
    buildRoute(NamedRoutes.settings, (context, state) => const SettingsScreen()),
    buildRoute(NamedRoutes.transcript, (context, state) => TranscriptScreen(result: state.extra as Result)),
  ],
);
