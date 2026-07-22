import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AreaType { medical, psychology }

final areaProvider = StateProvider<AreaType?>((ref) => null);
