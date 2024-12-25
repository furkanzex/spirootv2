import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

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
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: MyColor.primaryDarkColor,
        appBar: AppBar(
          backgroundColor: MyColor.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(easy.tr("social.my_content"),
              style: MyStyle.b4.copyWith(color: MyColor.white)),
          bottom: TabBar(
            labelColor: MyColor.white,
            unselectedLabelColor: MyColor.white.withOpacity(0.5),
            dividerColor: MyColor.white.withOpacity(0.5),
            indicatorColor: MyColor.primaryPurpleColor,
            onTap: (index) {
              setState(() {});
            },
            tabs: [
              Tab(text: easy.tr("social.my_posts")),
              Tab(text: easy.tr("social.my_events")),
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
      stream: SocialService.getUserPosts(_auth.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              easy.tr("errors.error"),
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
              easy.tr("social.no_shared_posts"),
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
                  style: MyStyle.s3.copyWith(color: MyColor.primaryPurpleColor),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: MyColor.errorColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: MyColor.darkBackgroundColor,
                        title: Text(
                          easy.tr("social.delete_post"),
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                        ),
                        content: Text(
                          easy.tr("social.delete_post_confirmation"),
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              easy.tr("common.cancel"),
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
                              easy.tr("common.delete"),
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
      stream: SocialService.getUserEvents(_auth.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: MyColor.errorColor, size: 48),
                SizedBox(height: MySize.defaultPadding),
                Text(
                  easy.tr("social.error_occurred_events"),
                  style: MyStyle.s2.copyWith(color: MyColor.white),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: Text(
                    easy.tr("common.try_again"),
                    style:
                        MyStyle.s2.copyWith(color: MyColor.primaryPurpleColor),
                  ),
                ),
              ],
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
              easy.tr("social.no_shared_events"),
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
                      event.description,
                      style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                          easy.tr("social.delete_event"),
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                        ),
                        content: Text(
                          easy.tr("social.delete_event_confirmation"),
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              easy.tr("common.cancel"),
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
                              easy.tr("common.delete"),
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
