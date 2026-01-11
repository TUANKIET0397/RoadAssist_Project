import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/response/garage_model.dart';

final selectedGarageProvider = StateProvider<GarageModel?>((ref) => null);
