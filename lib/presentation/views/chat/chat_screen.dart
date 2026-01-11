import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:road_assist/presentation/viewmodels/chat/chat_viewmodel.dart';
import 'package:road_assist/presentation/widgets/chat/message_bubble.dart';
import 'package:road_assist/presentation/widgets/chat/date_divider.dart';
import 'package:road_assist/presentation/widgets/chat/triangle_gradient_painter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _handleSend(ChatViewModel viewModel) {
    final text = _textController.text;
    if (text.trim().isNotEmpty) {
      viewModel.addMessage(text, true);
      _textController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF242C3B),
          appBar: AppBar(
            backgroundColor: const Color(0xFF242C3B),
            // FIX LỖI ĐỔI MÀU Ở ĐÂY:
            elevation: 0,
            scrolledUnderElevation: 0, // Ngăn AppBar đổi màu khi có nội dung cuộn bên dưới
            surfaceTintColor: Colors.transparent, // Đảm bảo không bị ám màu theo Material 3
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {},
            ),
            title: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34495e),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      viewModel.user.avatar,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    viewModel.user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // Tạo hiệu ứng viền gradient 1px
                  border: Border.all(color: Colors.transparent, width: 1.25),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x33FFFFFF), // Trắng với opacity thấp (Overlay effect)
                      Color(0x1A000000), // Đen với opacity thấp
                    ],
                  ),
                ),
                child: Container(
                  // Lớp nền phía trong để tạo khoảng trống cho viền
                  decoration: BoxDecoration(
                    color: const Color(0xFF242C3B), // Cùng màu với background AppBar
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.phone_outlined, // Icon rỗng theo thiết kế
                      color: Color(0xFF37B6E9), // Màu Cyan đặc trưng
                      size: 20,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // LỚP 1: NỀN TAM GIÁC XUẤT HIỆN LUÂN PHIÊN (CỐ ĐỊNH BACKGROUND)
                    AnimatedBuilder(
                      animation: _scrollController,
                      builder: (context, child) {
                        double offset = _scrollController.hasClients ? _scrollController.offset : 0;

                        return Stack(
                          children: List.generate(20, (index) {
                            double appearancePoint = index * 400.0;
                            bool isLeft = index % 2 == 0;

                            // Logic hiện dần (Fade-in)
                            double opacity = ((offset - appearancePoint + 500) / 500).clamp(0.0, 0.4);

                            return Positioned(
                              top: isLeft ? 60 : 380, // Các vị trí cố định so le trên màn hình
                              left: isLeft ? -130 : null,
                              right: !isLeft ? -130 : null,
                              child: Opacity(
                                opacity: opacity,
                                child: CustomPaint(
                                  size: const Size(300, 450),
                                  painter: TriangleGradientPainter(
                                    color1: const Color(0xFF37B6E9),
                                    color2: const Color(0xFF4B4CED),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    // LỚP 2: NỘI DUNG TIN NHẮN
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: viewModel.messages.length,
                      itemBuilder: (context, index) {
                        if (index == 7) {
                          return Column(
                            children: [
                              const DateDivider(date: '15:00 13/12/2025'),
                              MessageBubble(message: viewModel.messages[index]),
                            ],
                          );
                        }
                        return MessageBubble(message: viewModel.messages[index]);
                      },
                    ),
                  ],
                ),
              ),

              // THANH INPUT
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF242C3B),
                  border: Border(
                    top: BorderSide(color: Color(0xFF2d3748), width: 1),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text('😊', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'IAa',
                            hintStyle: TextStyle(color: Color(0xFF64748b)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                          ),
                          onSubmitted: (_) => _handleSend(viewModel),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _handleSend(viewModel),
                        child: const Icon(
                          Icons.send,
                          color: Color(0xFF3b82f6),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}