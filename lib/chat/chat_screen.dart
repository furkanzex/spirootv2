import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/explore/explore_controller.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class ChatScreen extends StatelessWidget {
  final String chatId;
  final TextEditingController _messageController = TextEditingController();
  final ExploreController _exploreController = Get.find<ExploreController>();
  final UserController _userController = Get.find<UserController>();

  ChatScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _exploreController.endChat();
        return true;
      },
      child: Scaffold(
        backgroundColor: MyColor.darkBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: MyColor.white),
            onPressed: () => _exploreController.endChat(),
          ),
          title: Obx(() {
            final match = _exploreController.currentMatch.value;
            final currentUser = _userController.currentUser.value;
            if (match == null || currentUser == null) return const SizedBox();

            return Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.name,
                      style: MyStyle.s2.copyWith(
                        color: MyColor.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          currentUser.gender == 'male'
                              ? MingCute.male_line
                              : MingCute.female_line,
                          color: MyColor.textGreyColor,
                          size: MySize.iconSizeTiny,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentUser.zodiacSign.toUpperCase(),
                          style: MyStyle.s3.copyWith(
                            color: MyColor.textGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: MyColor.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${match.matchScore.toInt()}% ${easy.tr('chat.compatibility')}",
                    style: MyStyle.s3.copyWith(
                      color: MyColor.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: MyColor.white.withOpacity(0.1),
            ),
          ),
        ),
        body: Column(
          children: [
            // Eşleşme bilgisi banner'ı
            Container(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              color: MyColor.primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    MingCute.information_line,
                    color: MyColor.primaryColor,
                    size: MySize.iconSizeSmall,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      easy.tr('chat.match_made_by_zodiac'),
                      style: MyStyle.s3.copyWith(
                        color: MyColor.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Mesaj listesi
            Expanded(
              child: Obx(() {
                final messages = _exploreController.currentChatMessages;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(MySize.defaultPadding),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return _buildMessageBubble(message);
                  },
                );
              }),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: MySize.defaultPadding),
        padding: const EdgeInsets.all(MySize.defaultPadding),
        decoration: BoxDecoration(
          color: message.isMe
              ? MyColor.primaryColor.withOpacity(0.2)
              : MyColor.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MySize.defaultRadius),
        ),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: MyStyle.s2.copyWith(color: MyColor.white),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: MyStyle.s3.copyWith(
                color: MyColor.textGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: MyColor.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: MyStyle.s2.copyWith(color: MyColor.white),
              decoration: InputDecoration(
                hintText: easy.tr('chat.write_your_message'),
                hintStyle: MyStyle.s2.copyWith(
                  color: MyColor.textGreyColor,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _exploreController.sendMessage(_messageController.text);
                _messageController.clear();
              }
            },
            icon: const Icon(Icons.send, color: MyColor.primaryColor),
          ),
        ],
      ),
    );
  }
}
