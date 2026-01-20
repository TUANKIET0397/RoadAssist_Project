import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/account_garage/viewmodel/garage_vm.dart';
import 'package:road_assist/ui/account_garage/widgets/garage_card.dart';
import 'package:road_assist/ui/account_garage/widgets/garage_text_field.dart';
import 'package:road_assist/ui/account_garage/widgets/working_days_selector.dart';
import 'package:road_assist/ui/account_garage/widgets/working_time_selector.dart';
import 'package:road_assist/ui/account_garage/widgets/services_selector.dart';
import 'package:road_assist/ui/account_garage/widgets/save_garage_button.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(garageProvider);
    final savedGarage = state.savedGarage; // Hiển thị trên card
    final draftGarage = state.draftGarage; // Dùng trong form

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'Thông tin Garage',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(right: 16, bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(79, 172, 254, 1),
                  Color.fromRGBO(126, 245, 251, 1),
                ],
              ),
            ),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GarageCard(garage: savedGarage), // Card dùng savedGarage
            const SizedBox(height: 20),

            GarageTextField(
              label: 'Tên Garage',
              subLabel: 'Nhập tên garage của bạn',
              value: draftGarage.name,
              onChanged: (v) => ref
                  .read(garageProvider.notifier)
                  .updateGarage(draftGarage.copyWith(name: v)),
            ),

            GarageTextField(
              label: 'Mã số thuế',
              subLabel: 'Nhập mã số thuế của bạn',
              value: state.taxCode ?? '',
              onChanged: (v) => ref
                  .read(garageProvider.notifier)
                  .updateTaxCode(v.isEmpty ? null : v),
            ),

            GarageTextField(
              label: 'Số điện thoại',
              subLabel: 'Nhập số điện thoại của bạn',
              value: draftGarage.phone,
              onChanged: (v) => ref
                  .read(garageProvider.notifier)
                  .updateGarage(draftGarage.copyWith(phone: v)),
            ),

            GarageTextField(
              label: 'Địa chỉ',
              subLabel: 'Chọn địa chỉ phù hợp',
              value: draftGarage.address,
              onChanged: (v) => ref
                  .read(garageProvider.notifier)
                  .updateGarage(draftGarage.copyWith(address: v)),
            ),

            const SizedBox(height: 10),
            WorkingDaysSelector(),

            const SizedBox(height: 16),
            WorkingTimeSelector(
              open: draftGarage.openTime,
              close: draftGarage.closeTime,
            ),

            const SizedBox(height: 20),
            ServicesSelector(selected: draftGarage.issues),

            const SizedBox(height: 32),
            const SaveGarageButton(),
          ],
        ),
      ),
    );
  }
}
