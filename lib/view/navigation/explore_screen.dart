import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/model/post/post_model.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:extended_image/extended_image.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Arama çubuğu
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchHeaderDelegate(),
            ),
            // Trend olan etiketler
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: MySize.defaultPadding,
                  vertical: MySize.halfPadding,
                ),
                child: Row(
                  children: [
                    _buildTrendTag("spirituel", 1542),
                    _buildTrendTag("meditasyon", 856),
                    _buildTrendTag("astroloji", 743),
                    _buildTrendTag("tarot", 621),
                    _buildTrendTag("reiki", 432),
                  ],
                ),
              ),
            ),
            // Post Listesi
            SliverPadding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPostCard(_dummyPosts[index]),
                  childCount: _dummyPosts.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: MyColor.primaryColor,
        child: const Icon(Icons.add, color: MyColor.white),
      ),
    );
  }

  Widget _buildTrendTag(String tag, int postCount) {
    return Container(
      margin: const EdgeInsets.only(right: MySize.defaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: MySize.defaultPadding,
        vertical: MySize.halfPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.primaryColor.withOpacity(0.8),
            MyColor.primaryColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "#$tag",
            style: MyStyle.s2.copyWith(
              color: MyColor.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${postCount.toString()} gönderi",
            style: MyStyle.s3.copyWith(
              color: MyColor.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    String _formatDate(DateTime date) {
      final difference = DateTime.now().difference(date);
      if (difference.inDays == 0) {
        return "Bugün";
      } else if (difference.inDays == 1) {
        return "Dün";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} gün önce";
      } else {
        return "${date.day}.${date.month}.${date.year}";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: MySize.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MySize.halfRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kullanıcı bilgileri
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: ExtendedNetworkImageProvider(
                          post.userImage,
                          cache: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.userName,
                              style: MyStyle.s2.copyWith(
                                color: MyColor.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDate(post.createdAt),
                              style: MyStyle.s3.copyWith(
                                color: MyColor.textGreyColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  verticalGap(MySize.defaultPadding),
                  // Post içeriği
                  Text(
                    post.content,
                    style: MyStyle.s2.copyWith(
                      color: MyColor.white,
                      height: 1.5,
                    ),
                  ),
                  // Etiketler
                  if (post.tags.isNotEmpty) ...[
                    verticalGap(MySize.defaultPadding),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: post.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: MyColor.primaryDarkColor,
                                  borderRadius: BorderRadius.circular(
                                      MySize.quarterRadius),
                                ),
                                child: Text(
                                  "#$tag",
                                  style: MyStyle.s2.copyWith(
                                    color: MyColor.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  verticalGap(MySize.defaultPadding),
                  // Etkileşim butonları
                  Row(
                    children: [
                      _buildInteractionButton(
                        icon: post.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: post.isLiked ? Colors.red : MyColor.white,
                        count: post.likeCount,
                      ),
                      const SizedBox(width: 24),
                      _buildInteractionButton(
                        icon: Icons.chat_bubble_outline,
                        count: post.commentCount,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildInteractionButton({
  required IconData icon,
  required int count,
  Color color = MyColor.white,
}) {
  return Row(
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 8),
      Text(
        count.toString(),
        style: MyStyle.s3.copyWith(
          color: MyColor.white,
        ),
      ),
    ],
  );
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: MyColor.transparent,
      padding: const EdgeInsets.all(MySize.defaultPadding),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MySize.halfRadius),
        ),
        child: TextField(
          style: MyStyle.s2.copyWith(color: MyColor.white),
          decoration: InputDecoration(
            hintText: easy.tr("explore.search_hint"),
            hintStyle: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
            prefixIcon: const Icon(Icons.search, color: MyColor.textGreyColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MySize.defaultPadding,
              vertical: 8,
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 76;

  @override
  double get minExtent => 76;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

// Örnek veriler
final List<Post> _dummyPosts = [
  Post(
    id: "1",
    userId: "user1",
    userName: "Ruhsal Rehber",
    userImage: "https://apptoic.com/spiroot/images/users/user1.jpg",
    content:
        "Bugün meditasyon seansımızda harika enerjiler aldık! Katılan herkese teşekkürler 🙏",
    image: "https://apptoic.com/spiroot/images/posts/meditation.jpg",
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    likeCount: 128,
    commentCount: 23,
    isLiked: true,
    tags: ["meditasyon", "spirituel", "enerji"],
  ),
  // Diğer örnek postlar...
];
