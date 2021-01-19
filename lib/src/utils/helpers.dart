import 'uuid.dart';

String uuid() {
  final uuid = Uuid();
  return uuid.generateV4();
}
