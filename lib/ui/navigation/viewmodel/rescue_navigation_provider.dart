import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';

final selectedRescueProvider = StateProvider<RescueRequestModel?>((ref) => null);
