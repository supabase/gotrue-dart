/// Define [getDatabaseFactory] for a common support on Flutter and Flutter Web
export 'sembast_stub.dart'
    if (dart.library.html) 'sembast_web.dart'
    if (dart.library.io) 'sembast_io.dart';
