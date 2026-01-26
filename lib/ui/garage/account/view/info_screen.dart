import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/ui/auth/widgets/day_selector.dart';
import 'package:road_assist/ui/auth/widgets/service_chip.dart';
import 'package:road_assist/ui/auth/widgets/time_picker_field.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';
import 'package:road_assist/ui/garage/account/widgets/garage_card.dart';
import 'package:road_assist/ui/garage/account/widgets/garage_text_field.dart';
import 'package:road_assist/ui/garage/account/widgets/save_garage_button.dart';

import '../../../auth/widgets/section_header.dart' show SectionHeader;

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Chưa đăng nhập')),
      );
    }
    final state = ref.watch(garageProvider(userId));
    final notifier = ref.read(garageProvider(userId).notifier);
    final draftGarage = state.draftGarage;

    // Tạm thời hardcode ở đây, lý tưởng hơn là lấy từ 1 config file hoặc remote config
    final allServices = [
      'Hết xăng',
      'Bể lốp',
      'Mất chìa khóa',
      'Hư máy',
      'Vận chuyển xe',
      'Xẹp lốp',
      'Không rõ nguyên nhân',
    ];

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPalette.bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GarageCard(garage: state.savedGarage), // Card dùng savedGarage
              const SizedBox(height: 20),

              GarageTextField(
                label: 'Tên Garage',
                subLabel: 'Nhập tên garage của bạn',
                value: draftGarage.name,
                onChanged: (v) =>
                    notifier.updateGarage(draftGarage.copyWith(name: v)),
              ),

              GarageTextField(
                label: 'Mã số thuế',
                subLabel: 'Nhập mã số thuế của bạn',
                value: state.taxCode ?? '',
                onChanged: (v) => notifier.updateTaxCode(v.isEmpty ? null : v),
              ),

              GarageTextField(
                label: 'Số điện thoại',
                subLabel: 'Nhập số điện thoại của bạn',
                value: draftGarage.phone,
                onChanged: (v) =>
                    notifier.updateGarage(draftGarage.copyWith(phone: v)),
              ),

              GarageTextField(
                label: 'Địa chỉ',
                subLabel: 'Chọn địa chỉ phù hợp',
                value: draftGarage.address,
                onChanged: (v) =>
                    notifier.updateGarage(draftGarage.copyWith(address: v)),
              ),

              const SizedBox(height: 10),
              const SectionHeader(title: 'Ngày hoạt động'),
              DaySelector(
                selectedDays: state.workingDays.toSet(),
                onDayTap: notifier.toggleWorkingDay,
              ),

              // Operating Hours Section
              const SectionHeader(title: 'Giờ hoạt động'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF243158),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF34CAE8),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TimePickerField(
                      time: TimeOfDay(
                        hour: int.parse(draftGarage.openTime.split(':')[0]),
                        minute: int.parse(draftGarage.openTime.split(':')[1]),
                      ),
                      onTimeSelected: notifier.setOpenTime,
                    ),
                    const Text(
                      '  —  ',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    TimePickerField(
                      time: TimeOfDay(
                        hour: int.parse(draftGarage.closeTime.split(':')[0]),
                        minute: int.parse(draftGarage.closeTime.split(':')[1]),
                      ),
                      onTimeSelected: notifier.setCloseTime,
                    ),
                  ],
                ),
              ),

              // Services Section
              const SectionHeader(title: 'Dịch vụ hỗ trợ'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: allServices.map((s) {
                  return ServiceChip(
                    label: s,
                    isSelected: draftGarage.issues.contains(s),
                    onTap: () => notifier.toggleService(s),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              const SaveGarageButton(),
              SizedBox(height: 120),

            ],
          ),
        ),
      ),
    );
  }
}
