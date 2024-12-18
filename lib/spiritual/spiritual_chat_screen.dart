import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/core/constant/my_text.dart';
import 'package:spirootv2/spiritual/spiritual_chat_controller.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';

class SpiritualChatScreen extends StatefulWidget {
  const SpiritualChatScreen({super.key});

  @override
  State<SpiritualChatScreen> createState() => _SpiritualChatScreenState();
}

class _SpiritualChatScreenState extends State<SpiritualChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SpiritualChatController _chatController =
      Get.put(SpiritualChatController());
  final AstrologyController _astrologyController =
      Get.find<AstrologyController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _messageController.clear();
      _chatController.sendMessage(message);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MingCute.magic_2_line,
            size: 64,
            color: MyColor.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: MySize.defaultPadding),
          Text(
            easy.tr('spiritual_chat.empty_state.title'),
            style: MyStyle.s2.copyWith(
              color: MyColor.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            easy.tr('spiritual_chat.empty_state.subtitle'),
            textAlign: TextAlign.center,
            style: MyStyle.s3.copyWith(
              color: MyColor.textGreyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.darkBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: MyColor.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(MySize.defaultRadius),
                border: Border.all(
                  color: MyColor.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => TextField(
                          controller: _messageController,
                          enabled: !_chatController.isThinking.value,
                          style: MyStyle.s2.copyWith(
                            color: MyColor.white.withOpacity(
                                _chatController.isThinking.value ? 0.5 : 1.0),
                          ),
                          decoration: InputDecoration(
                            hintText: _chatController.isThinking.value
                                ? easy.tr("spiritual_chat.thinking_message")
                                : easy.tr("spiritual_chat.ask_message"),
                            hintStyle: MyStyle.s2.copyWith(
                              color: MyColor.textGreyColor.withOpacity(
                                _chatController.isThinking.value ? 0.5 : 0.7,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: MySize.defaultPadding,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _chatController.isThinking.value
                              ? null
                              : _sendMessage(),
                        )),
                  ),
                  Obx(() {
                    final bool isSubscribed =
                        _astrologyController.isSubscribed.value;
                    final bool isThinking = _chatController.isThinking.value;

                    return IconButton(
                      onPressed: isThinking
                          ? null
                          : () {
                              if (!isSubscribed) {
                                paywall();
                                return;
                              }
                              _sendMessage();
                            },
                      icon: Icon(
                        isSubscribed
                            ? MingCute.send_plane_fill
                            : MingCute.lock_line,
                        color: isThinking
                            ? MyColor.primaryLightColor.withOpacity(0.3)
                            : isSubscribed
                                ? MyColor.primaryLightColor
                                : MyColor.primaryLightColor.withOpacity(0.5),
                        size: MySize.iconSizeSmall,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          MyText.appName,
          style: MyStyle.s1.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(MyIcon.back, color: MyColor.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _showClearChatDialog(context),
            icon: const Icon(MingCute.delete_2_line, color: MyColor.white),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMessageList(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: MyColor.darkBackgroundColor,
        title: Text(
          easy.tr("spiritual_chat.clear_chat"),
          style: MyStyle.s1.copyWith(color: MyColor.white),
        ),
        content: Text(
          easy.tr("spiritual_chat.clear_chat_dialog.content"),
          style: MyStyle.s2.copyWith(color: MyColor.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              easy.tr("common.cancel"),
              style: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
            ),
          ),
          TextButton(
            onPressed: () {
              _chatController.clearChat();
              Get.back();
            },
            child: Text(
              easy.tr("common.clear"),
              style: MyStyle.s2.copyWith(color: MyColor.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  // Mesaj listesi widget'ını güncelle
  Widget _buildMessageList() {
    return Expanded(
      child: Obx(() {
        final messages = _chatController.messages;
        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        // Yeni mesaj geldiğinde otomatik kaydır
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(MySize.defaultPadding),
          itemCount:
              messages.length + (_chatController.isThinking.value ? 1 : 0),
          itemBuilder: (context, index) {
            // Düşünme animasyonu için ekstra item
            if (_chatController.isThinking.value && index == 0) {
              return const ThinkingBubble();
            }

            // Gerçek mesaj indeksini ayarla
            final messageIndex =
                _chatController.isThinking.value ? index - 1 : index;
            final message = messages[messageIndex];

            return AnimatedMessageBubble(message: message);
          },
        );
      }),
    );
  }
}

// Animasyonlu mesaj balonu widget'ı
class AnimatedMessageBubble extends StatefulWidget {
  final SpiritualChatMessage message;

  const AnimatedMessageBubble({
    super.key,
    required this.message,
  });

  @override
  State<AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<AnimatedMessageBubble> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1.0,
        child: Container(
          margin: EdgeInsets.only(
            bottom: MySize.defaultPadding,
            left: widget.message.isMe ? Get.width * 0.15 : 0,
            right: widget.message.isMe ? 0 : Get.width * 0.15,
          ),
          child: Column(
            crossAxisAlignment: widget.message.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(MySize.defaultPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.message.isMe
                        ? [
                            MyColor.white.withOpacity(0.05),
                            MyColor.white.withOpacity(0.1),
                          ]
                        : [
                            MyColor.primaryLightColor.withOpacity(0.5),
                            MyColor.primaryLightColor.withOpacity(0.1),
                          ],
                  ),
                  borderRadius:
                      BorderRadius.circular(MySize.halfRadius).copyWith(
                    bottomRight: widget.message.isMe ? Radius.zero : null,
                    bottomLeft: !widget.message.isMe ? Radius.zero : null,
                  ),
                  border: Border.all(
                    color: widget.message.isMe
                        ? MyColor.primaryColor.withOpacity(0.2)
                        : MyColor.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: widget.message.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.text,
                      style: MyStyle.s2.copyWith(
                        color: MyColor.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!widget.message.isMe)
                          Icon(
                            MingCute.magic_2_line,
                            color: MyColor.white,
                            size: 14,
                          ),
                        if (!widget.message.isMe) const SizedBox(width: 4),
                        Text(
                          _formatTime(widget.message.timestamp),
                          style: MyStyle.s4.copyWith(
                            color: MyColor.textGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}

// Düşünme animasyonu widget'ı
class ThinkingAnimation extends StatefulWidget {
  const ThinkingAnimation({super.key});

  @override
  State<ThinkingAnimation> createState() => _ThinkingAnimationState();
}

class _ThinkingAnimationState extends State<ThinkingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MySize.halfRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.translate(
                  offset: Offset(
                    0,
                    sin((_controller.value * 2 * pi) + (index * pi / 2)) * 4,
                  ),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: MyColor.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Yeni ThinkingBubble widget'ı
class ThinkingBubble extends StatelessWidget {
  const ThinkingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MySize.defaultPadding,
        left: 0,
        right: Get.width * 0.15,
      ),
      child: Container(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MyColor.primaryLightColor.withOpacity(0.5),
              MyColor.primaryLightColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(MySize.halfRadius)
              .copyWith(bottomLeft: Radius.zero),
          border: Border.all(
            color: MyColor.white.withOpacity(0.1),
          ),
        ),
        child: const ThinkingAnimation(),
      ),
    );
  }
}
