import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:intl/intl.dart';
import 'package:spirootv2/core/service/revenuecat_services.dart';
import 'package:spirootv2/social/screens/my_content_screen.dart';
import 'dart:ui' as ui;
import '../services/social_service.dart';
import '../models/post_model.dart';
import '../models/event_model.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:spirootv2/profile/profile_onboarding.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';
import 'package:spirootv2/profile/user_controller.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final _postController = TextEditingController();
  bool _isPostsTab = true;
  final _userController = Get.find<UserController>();
  final Map<String, bool> _expandedPosts = {};
  final Map<String, bool> _expandedEvents = {};
  final _postsScrollController = ScrollController();
  final _eventsScrollController = ScrollController();

  Future<bool> _checkUserStatusAndRedirect() async {
    if (_userController.userName.isEmpty) {
      Get.to(() => const ProfileOnboarding());
      return false;
    }

    final isPremium = await PurchaseAPI.isPremium();
    if (!isPremium) {
      paywall();
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _postController.dispose();
    _postsScrollController.dispose();
    _eventsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: MyColor.transparent,
        appBar: TabBar(
          labelColor: MyColor.white,
          unselectedLabelColor: MyColor.white.withOpacity(0.5),
          dividerColor: MyColor.white.withOpacity(0.5),
          indicatorColor: MyColor.transparent,
          onTap: (index) {
            setState(() {
              _isPostsTab = index == 0;
            });
          },
          tabs: [
            Tab(text: easy.tr('social.posts')),
            Tab(text: easy.tr('social.events')),
          ],
        ),
        body: TabBarView(
          children: [
            _buildPostsTab(),
            _buildEventsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (await _checkUserStatusAndRedirect()) {
              if (_isPostsTab) {
                _showCreatePostSheet();
              } else {
                _showCreateEventSheet();
              }
            }
          },
          backgroundColor: MyColor.primaryPurpleColor,
          child: Icon(
            _isPostsTab ? Icons.post_add : Icons.event_available,
            color: MyColor.primaryDarkColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: MySize.halfPadding),
          child: GestureDetector(
            onTap: () => Get.to(() => const MyContentScreen()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  color: MyColor.primaryPurpleColor,
                  size: MySize.iconSizeTiny,
                ),
                SizedBox(width: MySize.quarterPadding),
                Text(
                  easy.tr('social.my_posts'),
                  style: MyStyle.s3.copyWith(color: MyColor.primaryPurpleColor),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Post>>(
            stream: SocialService.getPosts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    easy.tr("social.error_occurred"),
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
                    easy.tr("social.no_posts"),
                    style: MyStyle.s2.copyWith(color: MyColor.white),
                  ),
                );
              }

              return ListView.builder(
                controller: _postsScrollController,
                padding: EdgeInsets.all(MySize.defaultPadding),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPostCard(post);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: MySize.halfPadding),
          child: GestureDetector(
            onTap: () => Get.to(() => const MyContentScreen()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  color: MyColor.primaryPurpleColor,
                  size: MySize.iconSizeTiny,
                ),
                SizedBox(width: MySize.quarterPadding),
                Text(
                  easy.tr('social.my_events'),
                  style: MyStyle.s3.copyWith(color: MyColor.primaryPurpleColor),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Event>>(
            stream: SocialService.getEvents(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    easy.tr("social.error_occurred"),
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
                    easy.tr("social.no_events"),
                    style: MyStyle.s2.copyWith(color: MyColor.white),
                  ),
                );
              }

              return ListView.builder(
                controller: _eventsScrollController,
                padding: EdgeInsets.all(MySize.defaultPadding),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(event);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      color: MyColor.darkBackgroundColor,
      margin: EdgeInsets.only(bottom: MySize.defaultPadding),
      child: Padding(
        padding: EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: MyColor.primaryPurpleColor.withOpacity(0.2),
                  child: Text(
                    post.creatorName[0].toUpperCase(),
                    style: MyStyle.s2.copyWith(color: MyColor.white),
                  ),
                ),
                SizedBox(width: MySize.defaultPadding),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.creatorName,
                      style: MyStyle.s2.copyWith(
                        color: MyColor.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(post.createdAt),
                      style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                    ),
                  ],
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: MyColor.white),
                  color: MyColor.darkBackgroundColor,
                  itemBuilder: (context) {
                    final hasReported = post.reports
                        .contains(FirebaseAuth.instance.currentUser?.uid);
                    return [
                      PopupMenuItem(
                        value: hasReported ? 'unreport' : 'report',
                        child: Row(
                          children: [
                            Icon(
                              hasReported
                                  ? Icons.remove_circle_outline
                                  : Icons.report_problem_outlined,
                              color: hasReported
                                  ? MyColor.primaryPurpleColor
                                  : MyColor.errorColor,
                            ),
                            SizedBox(width: MySize.defaultPadding),
                            Text(
                              hasReported
                                  ? easy.tr("social.unreport")
                                  : easy.tr("social.report"),
                              style: MyStyle.s2.copyWith(color: MyColor.white),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  onSelected: (value) async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId == null) return;

                    if (value == 'report') {
                      if (!post.reports.contains(userId)) {
                        await SocialService.reportPost(post.id);
                        if (post.reports.length >= 49) {
                          await SocialService.deletePost(post.id);
                        }
                      }
                    } else if (value == 'unreport') {
                      await SocialService.unreportPost(post.id);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: MySize.defaultPadding),
            LayoutBuilder(
              builder: (context, constraints) {
                final textSpan = TextSpan(
                  text: post.content,
                  style: MyStyle.s2.copyWith(color: MyColor.white),
                );
                final textPainter = TextPainter(
                  text: textSpan,
                  textDirection: ui.TextDirection.ltr,
                  maxLines: 5,
                );
                textPainter.layout(maxWidth: constraints.maxWidth);

                final isTextOverflowing = textPainter.didExceedMaxLines;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.content,
                      style: MyStyle.s2.copyWith(color: MyColor.white),
                      maxLines: _expandedPosts[post.id] == true ? null : 5,
                      overflow: _expandedPosts[post.id] == true
                          ? null
                          : TextOverflow.ellipsis,
                    ),
                    if (isTextOverflowing || _expandedPosts[post.id] == true)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _expandedPosts[post.id] =
                                !(_expandedPosts[post.id] ?? false);
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _expandedPosts[post.id] == true
                                  ? easy.tr("social.show_less")
                                  : easy.tr("social.show_more"),
                              style: MyStyle.s3
                                  .copyWith(color: MyColor.primaryPurpleColor),
                            ),
                            Icon(
                              _expandedPosts[post.id] == true
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: MyColor.primaryPurpleColor,
                              size: MySize.iconSizeSmall,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: MySize.halfPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => SocialService.likePost(post.id),
                      icon: Icon(
                        post.likes.contains(
                                FirebaseAuth.instance.currentUser?.uid)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: MyColor.roseColor,
                      ),
                    ),
                    Text(
                      post.likes.length.toString(),
                      style: MyStyle.s3.copyWith(color: MyColor.white),
                    ),
                    SizedBox(width: MySize.defaultPadding),
                    IconButton(
                      onPressed: () => _showCommentsDialog(post.id),
                      icon: Icon(
                        Icons.comment_outlined,
                        color: MyColor.white,
                      ),
                    ),
                    Text(
                      post.commentCount.toString(),
                      style: MyStyle.s3.copyWith(color: MyColor.white),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      color: MyColor.darkBackgroundColor,
      margin: EdgeInsets.only(bottom: MySize.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.imageUrl.isNotEmpty)
            Image.network(
              event.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          MyColor.primaryPurpleColor.withOpacity(0.2),
                      child: Text(
                        event.creatorName[0].toUpperCase(),
                        style: MyStyle.s2.copyWith(color: MyColor.white),
                      ),
                    ),
                    SizedBox(width: MySize.defaultPadding),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.creatorName,
                          style: MyStyle.s2.copyWith(
                            color: MyColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm')
                              .format(event.createdAt),
                          style:
                              MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                        ),
                      ],
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: MyColor.white),
                      color: MyColor.darkBackgroundColor,
                      itemBuilder: (context) {
                        final hasReported = event.reports
                            .contains(FirebaseAuth.instance.currentUser?.uid);
                        return [
                          PopupMenuItem(
                            value: hasReported ? 'unreport' : 'report',
                            child: Row(
                              children: [
                                Icon(
                                  hasReported
                                      ? Icons.remove_circle_outline
                                      : Icons.report_problem_outlined,
                                  color: hasReported
                                      ? MyColor.primaryPurpleColor
                                      : MyColor.errorColor,
                                ),
                                SizedBox(width: MySize.defaultPadding),
                                Text(
                                  hasReported
                                      ? easy.tr("social.unreport")
                                      : easy.tr("social.report"),
                                  style:
                                      MyStyle.s2.copyWith(color: MyColor.white),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                      onSelected: (value) async {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId == null) return;

                        if (value == 'report') {
                          if (!event.reports.contains(userId)) {
                            await SocialService.reportEvent(event.id);
                            if (event.reports.length >= 49) {
                              await SocialService.deleteEvent(event.id);
                            }
                          }
                        } else if (value == 'unreport') {
                          await SocialService.unreportEvent(event.id);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: MySize.defaultPadding),
                Text(
                  event.title,
                  style: MyStyle.b4.copyWith(color: MyColor.white),
                ),
                SizedBox(height: MySize.quarterPadding),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textSpan = TextSpan(
                      text: event.description,
                      style: MyStyle.s2.copyWith(color: MyColor.white),
                    );
                    final textPainter = TextPainter(
                      text: textSpan,
                      textDirection: ui.TextDirection.ltr,
                      maxLines: 5,
                    );
                    textPainter.layout(maxWidth: constraints.maxWidth);

                    final isTextOverflowing = textPainter.didExceedMaxLines;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.description,
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                          maxLines:
                              _expandedEvents[event.id] == true ? null : 5,
                          overflow: _expandedEvents[event.id] == true
                              ? null
                              : TextOverflow.ellipsis,
                        ),
                        if (isTextOverflowing ||
                            _expandedEvents[event.id] == true)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _expandedEvents[event.id] =
                                    !(_expandedEvents[event.id] ?? false);
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _expandedEvents[event.id] == true
                                      ? easy.tr("social.show_less")
                                      : easy.tr("social.show_more"),
                                  style: MyStyle.s3.copyWith(
                                      color: MyColor.primaryPurpleColor),
                                ),
                                Icon(
                                  _expandedEvents[event.id] == true
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: MyColor.primaryPurpleColor,
                                  size: MySize.iconSizeSmall,
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: MySize.halfPadding),
                Row(
                  children: [
                    Icon(Icons.location_on, color: MyColor.primaryPurpleColor),
                    SizedBox(width: MySize.quarterPadding),
                    Expanded(
                      child: Text(
                        event.location,
                        style: MyStyle.s3.copyWith(color: MyColor.white),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MySize.quarterPadding),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: MyColor.primaryPurpleColor),
                    SizedBox(width: MySize.quarterPadding),
                    Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(event.eventDate),
                      style: MyStyle.s3.copyWith(color: MyColor.white),
                    ),
                  ],
                ),
                SizedBox(height: MySize.defaultPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${event.participants.length} ${easy.tr("social.participants")}',
                      style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showEventCommentsDialog(event.id),
                          icon: Icon(
                            Icons.comment_outlined,
                            color: MyColor.white,
                          ),
                        ),
                        Text(
                          event.commentCount.toString(),
                          style: MyStyle.s3.copyWith(color: MyColor.white),
                        ),
                        SizedBox(width: MySize.defaultPadding),
                        ElevatedButton(
                          onPressed: () => SocialService.joinEvent(event.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: event.participants.contains(
                                    FirebaseAuth.instance.currentUser?.uid)
                                ? MyColor.roseColor
                                : MyColor.primaryPurpleColor,
                          ),
                          child: Text(
                            event.participants.contains(
                                    FirebaseAuth.instance.currentUser?.uid)
                                ? easy.tr("social.leave")
                                : easy.tr("social.join"),
                            style: MyStyle.s3.copyWith(color: MyColor.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MyColor.primaryDarkColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(MySize.halfRadius)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              MySize.defaultPadding,
              MySize.defaultPadding,
              MySize.defaultPadding,
              MediaQuery.of(context).viewInsets.bottom + MySize.defaultPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  easy.tr("social.new_post"),
                  style: MyStyle.b4.copyWith(color: MyColor.white),
                ),
                SizedBox(height: MySize.defaultPadding),
                TextField(
                  controller: _postController,
                  style: MyStyle.s2.copyWith(color: MyColor.white),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: easy.tr("social.what_thinking"),
                    hintStyle:
                        MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyColor.textGreyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyColor.primaryPurpleColor),
                    ),
                  ),
                ),
                SizedBox(height: MySize.defaultPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        easy.tr("common.cancel"),
                        style:
                            MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                      ),
                    ),
                    SizedBox(width: MySize.defaultPadding),
                    ElevatedButton(
                      onPressed: () async {
                        if (_postController.text.trim().isNotEmpty) {
                          await SocialService.createPost(
                            _postController.text.trim(),
                            _userController.userName,
                          );
                          _postController.clear();
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryPurpleColor,
                      ),
                      child: Text(
                        easy.tr("social.share"),
                        style: MyStyle.s2.copyWith(color: MyColor.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateEventSheet() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final imageUrlController = TextEditingController();
    final initialDate = DateTime.now();
    DateTime selectedDate = initialDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(initialDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MyColor.primaryDarkColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(MySize.halfRadius)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              MySize.defaultPadding,
              MySize.defaultPadding,
              MySize.defaultPadding,
              MediaQuery.of(context).viewInsets.bottom + MySize.defaultPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  easy.tr("social.new_event"),
                  style: MyStyle.b4.copyWith(color: MyColor.white),
                ),
                SizedBox(height: MySize.defaultPadding),
                TextField(
                  controller: titleController,
                  style: MyStyle.s2.copyWith(color: MyColor.white),
                  decoration: InputDecoration(
                    labelText: easy.tr("social.event.title"),
                    labelStyle:
                        MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                  ),
                ),
                SizedBox(height: MySize.defaultPadding),
                TextField(
                  controller: descriptionController,
                  style: MyStyle.s2.copyWith(color: MyColor.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: easy.tr("social.event.description"),
                    labelStyle:
                        MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                  ),
                ),
                SizedBox(height: MySize.defaultPadding),
                TextField(
                  controller: locationController,
                  style: MyStyle.s2.copyWith(color: MyColor.white),
                  decoration: InputDecoration(
                    labelText: easy.tr("social.event.location"),
                    labelStyle:
                        MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                  ),
                ),
                SizedBox(height: MySize.defaultPadding),
                TextField(
                  controller: imageUrlController,
                  style: MyStyle.s2.copyWith(color: MyColor.white),
                  decoration: InputDecoration(
                    labelText: easy.tr("social.event.image_url"),
                    labelStyle:
                        MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                  ),
                ),
                SizedBox(height: MySize.defaultPadding),
                Container(
                  padding: EdgeInsets.all(MySize.defaultPadding),
                  decoration: BoxDecoration(
                    color: MyColor.darkBackgroundColor,
                    borderRadius: BorderRadius.circular(MySize.halfRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        easy.tr("social.event.select_date"),
                        style: MyStyle.s2.copyWith(color: MyColor.white),
                      ),
                      SizedBox(height: MySize.defaultPadding),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: MyColor.transparent,
                          borderRadius:
                              BorderRadius.circular(MySize.quarterRadius),
                        ),
                        child: CupertinoTheme(
                          data: CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: MyStyle.s1.copyWith(
                                color: MyColor.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            itemExtent: MySize.tenQuartersPadding,
                            mode: CupertinoDatePickerMode.dateAndTime,
                            initialDateTime: initialDate,
                            maximumDate:
                                initialDate.add(const Duration(days: 365)),
                            onDateTimeChanged: (DateTime value) {
                              selectedDate = value;
                              selectedTime = TimeOfDay.fromDateTime(value);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: MySize.defaultPadding),
                      Text(
                        '${easy.tr("social.event.selected_date")}: ${DateFormat('dd.MM.yyyy').format(selectedDate)}',
                        style:
                            MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                      ),
                      Text(
                        '${easy.tr("social.event.selected_time")}: ${selectedTime.format(context)}',
                        style:
                            MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MySize.defaultPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        easy.tr("common.cancel"),
                        style:
                            MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                      ),
                    ),
                    SizedBox(width: MySize.defaultPadding),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isNotEmpty &&
                            descriptionController.text.trim().isNotEmpty &&
                            locationController.text.trim().isNotEmpty) {
                          final eventDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );

                          await SocialService.createEvent(
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            location: locationController.text.trim(),
                            eventDate: eventDate,
                            imageUrl: imageUrlController.text.trim(),
                            creatorName: _userController.userName,
                          );

                          if (mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryPurpleColor,
                      ),
                      child: Text(
                        easy.tr("social.event.create"),
                        style: MyStyle.s2.copyWith(color: MyColor.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCommentsDialog(String postId) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MyColor.primaryDarkColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(MySize.halfRadius)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: EdgeInsets.fromLTRB(
            MySize.defaultPadding,
            MySize.defaultPadding,
            MySize.defaultPadding,
            MediaQuery.of(context).viewInsets.bottom + MySize.defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                easy.tr("social.comments"),
                style: MyStyle.b4.copyWith(color: MyColor.white),
              ),
              SizedBox(height: MySize.defaultPadding),
              Expanded(
                child: StreamBuilder(
                  stream: SocialService.getComments(postId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data!;
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                MyColor.primaryPurpleColor.withOpacity(0.2),
                            child: Text(
                              comment.creatorName[0].toUpperCase(),
                              style: MyStyle.s2.copyWith(color: MyColor.white),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.creatorName,
                                style: MyStyle.s2.copyWith(
                                  color: MyColor.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                comment.content,
                                style:
                                    MyStyle.s2.copyWith(color: MyColor.white),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            DateFormat('dd.MM.yyyy HH:mm')
                                .format(comment.createdAt),
                            style: MyStyle.s3
                                .copyWith(color: MyColor.textGreyColor),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: MyColor.white),
                            color: MyColor.darkBackgroundColor,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'report',
                                child: Row(
                                  children: [
                                    Icon(Icons.report_problem_outlined,
                                        color: MyColor.errorColor),
                                    SizedBox(width: MySize.defaultPadding),
                                    Text(
                                      easy.tr("social.report"),
                                      style: MyStyle.s2
                                          .copyWith(color: MyColor.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'report') {
                                if (!comment.reports.contains(
                                    FirebaseAuth.instance.currentUser?.uid)) {
                                  await SocialService.reportComment(
                                      postId, comment.id);
                                  if (comment.reports.length >= 49) {
                                    await SocialService.deleteComment(
                                        postId, comment.id);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          easy.tr("social.already_reported")),
                                      backgroundColor: MyColor.errorColor,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: MySize.defaultPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        style: MyStyle.s2.copyWith(color: MyColor.white),
                        decoration: InputDecoration(
                          hintText: easy.tr("social.comment_placeholder"),
                          hintStyle:
                              MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(MySize.halfRadius),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(MySize.halfRadius),
                            borderSide:
                                BorderSide(color: MyColor.textGreyColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(MySize.halfRadius),
                            borderSide:
                                BorderSide(color: MyColor.primaryPurpleColor),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MySize.defaultPadding),
                    IconButton(
                      onPressed: () async {
                        if (commentController.text.trim().isNotEmpty) {
                          await SocialService.addComment(
                            postId,
                            commentController.text.trim(),
                            _userController.userName,
                          );
                          commentController.clear();
                        }
                      },
                      icon: Icon(Icons.send, color: MyColor.primaryPurpleColor),
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

  void _showEventCommentsDialog(String eventId) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MyColor.primaryDarkColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(MySize.halfRadius)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: EdgeInsets.fromLTRB(
            MySize.defaultPadding,
            MySize.defaultPadding,
            MySize.defaultPadding,
            MediaQuery.of(context).viewInsets.bottom + MySize.defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                easy.tr("social.comments"),
                style: MyStyle.b4.copyWith(color: MyColor.white),
              ),
              SizedBox(height: MySize.defaultPadding),
              Expanded(
                child: StreamBuilder(
                  stream: SocialService.getEventComments(eventId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data!;
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                MyColor.primaryPurpleColor.withOpacity(0.2),
                            child: Text(
                              comment.creatorName[0].toUpperCase(),
                              style: MyStyle.s2.copyWith(color: MyColor.white),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.creatorName,
                                style: MyStyle.s2.copyWith(
                                  color: MyColor.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                comment.content,
                                style:
                                    MyStyle.s2.copyWith(color: MyColor.white),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            DateFormat('dd.MM.yyyy HH:mm')
                                .format(comment.createdAt),
                            style: MyStyle.s3
                                .copyWith(color: MyColor.textGreyColor),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: MyColor.white),
                            color: MyColor.darkBackgroundColor,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'report',
                                child: Row(
                                  children: [
                                    Icon(Icons.report_problem_outlined,
                                        color: MyColor.errorColor),
                                    SizedBox(width: MySize.defaultPadding),
                                    Text(
                                      easy.tr("social.report"),
                                      style: MyStyle.s2
                                          .copyWith(color: MyColor.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'report') {
                                if (!comment.reports.contains(
                                    FirebaseAuth.instance.currentUser?.uid)) {
                                  await SocialService.reportEventComment(
                                      eventId, comment.id);
                                  if (comment.reports.length >= 49) {
                                    await SocialService.deleteComment(
                                        eventId, comment.id);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          easy.tr("social.already_reported")),
                                      backgroundColor: MyColor.errorColor,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: MySize.defaultPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        style: MyStyle.s2.copyWith(color: MyColor.white),
                        decoration: InputDecoration(
                          hintText: easy.tr("social.comment_placeholder"),
                          hintStyle:
                              MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(MySize.halfRadius),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(MySize.halfRadius),
                            borderSide:
                                BorderSide(color: MyColor.textGreyColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(MySize.halfRadius),
                            borderSide:
                                BorderSide(color: MyColor.primaryPurpleColor),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MySize.defaultPadding),
                    IconButton(
                      onPressed: () async {
                        if (commentController.text.trim().isNotEmpty) {
                          await SocialService.addEventComment(
                            eventId,
                            commentController.text.trim(),
                            _userController.userName,
                          );
                          commentController.clear();
                        }
                      },
                      icon: Icon(Icons.send, color: MyColor.primaryPurpleColor),
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
}
