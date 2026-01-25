import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/user/rescue/view/user_rescue_tracking_screen.dart';

class UserRescueSuccessScreen extends ConsumerWidget {
  final String rescueRequestId;
  final String? garageId;
  final String? garageName;
  final Function() onBack;
  //final RescueRequestModel? request;

  const UserRescueSuccessScreen({
    super.key,
    required this.rescueRequestId,
    this.garageId,
    this.garageName,
    required this.onBack, //this.request,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //if (request != null) {
      // Use the provided request data
     // return _buildSuccessContent(context, ref, request!);
    //}


    final rescueRequest = ref.watch(
      currentRescueRequestProvider(rescueRequestId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage đã nhận'),
        centerTitle: true,
        leading: SizedBox.shrink(),
      ),
      body: rescueRequest.when(
        data: (request) {
          if (request == null) {
            return const Center(child: Text('Không tìm thấy yêu cầu'));
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0f172a), Color(0xFF1e3a8a)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    /// Shield icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.withOpacity(0.15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.6),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.lightBlueAccent,
                        size: 64,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Gửi yêu cầu cứu hộ thành công',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Garage sẽ sớm liên hệ với bạn',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade200,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Vehicle card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.motorcycle,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.vehicleType,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      request.vehicleModel,
                                      style: TextStyle(
                                        color: Colors.blue.shade200,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          /// Issue chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: request.issues
                                .map(
                                  (e) => Chip(
                                    backgroundColor: Colors.blueAccent
                                        .withOpacity(0.2),
                                    label: Text(
                                      e,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildFixedStatusChecklist(),
                    /// Status checklist
                    const SizedBox(height: 20),

                    /// Location
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vị trí của bạn',
                            style: TextStyle(color: Colors.blue.shade200),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.lightBlueAccent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  request.location,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            request.userPhone,
                            style: TextStyle(color: Colors.blue.shade300),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Primary button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserRescueTrackingScreen(
                                rescueRequestId: request.id,
                                garageId: request.garageId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Theo dõi trạng thái cứu hộ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Widget _buildFixedStatusChecklist() {
    final items = [
      'Garage Minh Thuận đã nhận cứu hộ',
      'Có thể theo dõi hoặc chat trực tiếp',
      'Garage sẽ liên hệ trong ít phút',
    ];

    return Column(
      children: items
          .map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF22c55e), // green-500
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
  
  Widget _buildSuccessContent(BuildContext context, WidgetRef ref, RescueRequestModel rescueRequestModel) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage đã nhận'),
        centerTitle: true,
        leading: SizedBox.shrink(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f172a), Color(0xFF1e3a8a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 12),

                /// Shield icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.6),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.lightBlueAccent,
                    size: 64,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Gửi yêu cầu cứu hộ thành công',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Garage sẽ sớm liên hệ với bạn',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade200,
                  ),
                ),

                const SizedBox(height: 24),

                /// Vehicle card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.motorcycle,
                              color: Colors.white,
                              size: 40,
                            ),  
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rescueRequestModel.vehicleType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  rescueRequestModel.vehicleModel,
                                  style: TextStyle(
                                    color: Colors.blue.shade200,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      /// Issue chips
                      Wrap( 
                        spacing: 8,
                        runSpacing: 8,
                        children: rescueRequestModel.issues
                            .map(
                              (e) => Chip(
                                backgroundColor: Colors.blueAccent
                                    .withOpacity(0.2),
                                label: Text(
                                  e,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),  
                ),
                const SizedBox(height: 20), 
                _buildFixedStatusChecklist(),
                /// Status checklist
                const SizedBox(height: 20),
                /// Location
                /// Location
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vị trí của bạn',
                        style: TextStyle(color: Colors.blue.shade200),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.lightBlueAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rescueRequestModel.location,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rescueRequestModel.userPhone,
                        style: TextStyle(color: Colors.blue.shade300),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                /// Primary button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserRescueTrackingScreen(
                            rescueRequestId: rescueRequestId,
                            garageId: garageId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Theo dõi trạng thái cứu hộ'),
                  ),
                ),
                const SizedBox(height: 12),
                /// Secondary button
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Chat với garage',
                    style: TextStyle(color: Colors.lightBlueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
