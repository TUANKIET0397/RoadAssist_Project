import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/presentation/views/garage/viewmodel/garage_vm.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garages = ref.watch(garageViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Garage')),
      body: ListView(children: garages.map(Text.new).toList()),
    );
  }
}
