import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/request_model.dart';

final activeRequestProvider = StateProvider<RequestModel?>((ref) => null);
