import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' as io;

/// Use app data on linux and windows if rootPath is null
///
/// Throw if no path defined
DatabaseFactory getDatabaseFactory() => io.databaseFactoryIo;
