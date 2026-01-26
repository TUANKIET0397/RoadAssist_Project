import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _initialized = false;

  Future<void> init(int uid) async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      throw Exception('Microphone permission denied');
    }

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      const RtcEngineContext(
        appId: '7efeeb463fc344e8afecca26dfafe301',
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    await _engine!.enableAudio();
    _initialized = true;
  }

  Future<void> join(String channel, int uid) async {
    if (!_initialized) {
      await init(uid);
    }

    await _engine!.joinChannel(
      token: '',
      channelId: channel,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> leave() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
      _initialized = false;
    }
  }
}
