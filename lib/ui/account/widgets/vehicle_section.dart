import 'package:flutter/material.dart';
import '../model/vehicle_model.dart';
import 'vehicle_item.dart';

class VehicleSection extends StatelessWidget {
  final List<Vehicle> vehicles;
  final void Function(Vehicle) onEdit;
  final void Function(Vehicle) onRemove;

  const VehicleSection({
    super.key,
    required this.vehicles,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        ...vehicles.map(
          (v) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: VehicleItem(
              vehicle: v,
              onEdit: () => onEdit(v),
              onDelete: () => onRemove(v),
            ),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () {
            print('press');
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: EdgeInsets.symmetric(horizontal: 74),
            decoration: BoxDecoration(
              color: Color.fromRGBO(10, 15, 32, 1),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(10, 15, 32, 1),
                  offset: const Offset(1, 3),
                  blurRadius: 7,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.add, color: Colors.white),
                Text(
                  'Thêm phương tiện',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
