import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/profile/user_controller.dart';
import '../services/social_service.dart';
import '../models/post_model.dart';
import '../models/event_model.dart';
import 'package:intl/intl.dart';

class MyContentScreen extends StatefulWidget {
  const MyContentScreen({super.key});

  @override
  State<MyContentScreen> createState() => _MyContentScreenState();
}

class _MyContentScreenState extends State<MyContentScreen> {
  final _userController = Get.find<UserController>();
  bool _isPostsTab = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: MyColor.primaryDarkColor,
        appBar: AppBar(
          backgroundColor: MyColor.transparent,
          elevation: 0,
          title: Text(
            'İçeriklerim',
            style: MyStyle.b4.copyWith(color: MyColor.white),
          ),
          bottom: TabBar(
            labelColor: MyColor.white,
            unselectedLabelColor: MyColor.white.withOpacity(0.5),
            dividerColor: MyColor.white.withOpacity(0.5),
            indicatorColor: MyColor.primaryPurpleColor,
            onTap: (index) {
              setState(() {
                _isPostsTab = index == 0;
              });
            },
            tabs: const [
              Tab(text: 'Gönderilerim'),
              Tab(text: 'Etkinliklerim'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMyPosts(),
            _buildMyEvents(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPosts() {
    return StreamBuilder<List<Post>>(
      stream: SocialService.getUserPosts(_userController.userName),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Bir hata oluştu',
              style: MyStyle.s2.copyWith(color: MyColor.white),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;
        if (posts.isEmpty) {
          return Center(
            child: Text(
              'Henüz gönderi paylaşmadınız',
              style: MyStyle.s2.copyWith(color: MyColor.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              color: MyColor.darkBackgroundColor,
              margin: const EdgeInsets.only(bottom: MySize.defaultPadding),
              child: ListTile(
                contentPadding: const EdgeInsets.all(MySize.defaultPadding),
                title: Text(
                  post.content,
                  style: MyStyle.s2.copyWith(color: MyColor.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(post.createdAt),
                  style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: MyColor.errorColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: MyColor.darkBackgroundColor,
                        title: Text(
                          'Gönderiyi Sil',
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                        ),
                        content: Text(
                          'Bu gönderiyi silmek istediğinize emin misiniz?',
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'İptal',
                              style: MyStyle.s2
                                  .copyWith(color: MyColor.textGreyColor),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              SocialService.deletePost(post.id);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Sil',
                              style: MyStyle.s2
                                  .copyWith(color: MyColor.errorColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyEvents() {
    return StreamBuilder<List<Event>>(
      stream: SocialService.getUserEvents(_userController.userName),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Bir hata oluştu',
              style: MyStyle.s2.copyWith(color: MyColor.white),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;
        if (events.isEmpty) {
          return Center(
            child: Text(
              'Henüz etkinlik oluşturmadınız',
              style: MyStyle.s2.copyWith(color: MyColor.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              color: MyColor.darkBackgroundColor,
              margin: const EdgeInsets.only(bottom: MySize.defaultPadding),
              child: ListTile(
                contentPadding: const EdgeInsets.all(MySize.defaultPadding),
                leading: event.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(MySize.quarterRadius),
                        child: Image.network(
                          event.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: MyColor.primaryPurpleColor.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(MySize.quarterRadius),
                        ),
                        child: Icon(
                          Icons.event,
                          color: MyColor.primaryPurpleColor,
                          size: MySize.iconSizeMedium,
                        ),
                      ),
                title: Text(
                  event.title,
                  style: MyStyle.s2.copyWith(
                    color: MyColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.location,
                      style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                    ),
                    Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(event.eventDate),
                      style: MyStyle.s3
                          .copyWith(color: MyColor.primaryPurpleColor),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: MyColor.errorColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: MyColor.darkBackgroundColor,
                        title: Text(
                          'Etkinliği Sil',
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                        ),
                        content: Text(
                          'Bu etkinliği silmek istediğinize emin misiniz?',
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'İptal',
                              style: MyStyle.s2
                                  .copyWith(color: MyColor.textGreyColor),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              SocialService.deleteEvent(event.id);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Sil',
                              style: MyStyle.s2
                                  .copyWith(color: MyColor.errorColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
