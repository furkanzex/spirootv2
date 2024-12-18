import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:animate_do/animate_do.dart';
import 'package:spirootv2/core/helper/device_helper.dart';
import 'package:spirootv2/enlightenment/ritual_detail_screen.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/enlightenment/services/ritual_service.dart';
import 'package:shimmer/shimmer.dart';

class RitualListScreen extends StatefulWidget {
  final Map<String, dynamic> category;

  const RitualListScreen({super.key, required this.category});

  @override
  State<RitualListScreen> createState() => _RitualListScreenState();
}

class _RitualListScreenState extends State<RitualListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredRituals = [];
  List<Map<String, dynamic>> _allRituals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRituals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRituals() async {
    setState(() => _isLoading = true);

    try {
      final rituals = widget.category['rituals'] as List;
      _allRituals = List<Map<String, dynamic>>.from(rituals);
      _filterRituals();
    } catch (e) {
      throw Exception(easy.tr('errors.data_not_loaded'));
    }

    setState(() => _isLoading = false);
  }

  void _filterRituals() {
    if (_searchQuery.isEmpty) {
      _filteredRituals = List.from(_allRituals);
      setState(() {});
      return;
    }

    final query = _searchQuery.toLowerCase();
    _filteredRituals = _allRituals.where((ritual) {
      final title = ritual['title'].toString().toLowerCase();
      final materials = (ritual['materials'] as List?)
              ?.map((m) => m.toString().toLowerCase())
              .join(' ') ??
          '';

      return title.contains(query) || materials.contains(query);
    }).toList();

    setState(() {});
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
      ),
      child: TextField(
        controller: _searchController,
        style: MyStyle.s2.copyWith(color: MyColor.white),
        decoration: InputDecoration(
          hintText: easy.tr('enlightenment.ritual.search'),
          hintStyle: MyStyle.s2.copyWith(color: MyColor.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: MyColor.white),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: MyColor.white),
                  onPressed: () {
                    _searchController.clear();
                    _searchQuery = '';
                    _filterRituals();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: MySize.defaultPadding,
            vertical: MySize.halfPadding,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterRituals();
          });
        },
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: MyColor.white.withOpacity(0.1),
      highlightColor: MyColor.white.withOpacity(0.2),
      child: Container(
        margin: EdgeInsets.only(bottom: MySize.defaultPadding),
        decoration: BoxDecoration(
          color: MyColor.white,
          borderRadius: BorderRadius.circular(MySize.halfRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: MyColor.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(MySize.halfRadius),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(MySize.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 24,
                    decoration: BoxDecoration(
                      color: MyColor.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: MySize.halfPadding),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 20,
                        decoration: BoxDecoration(
                          color: MyColor.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: MySize.halfPadding),
                      Container(
                        width: 80,
                        height: 20,
                        decoration: BoxDecoration(
                          color: MyColor.white,
                          borderRadius: BorderRadius.circular(4),
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
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(MySize.defaultPadding),
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return GestureDetector(
      onTap: () => DeviceHelper.hideKeyboard(),
      child: ScaffoldGradientBackground(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            MyColor.darkBackgroundColor,
            MyColor.primaryColor,
          ],
        ),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          surfaceTintColor: MyColor.transparent,
          backgroundColor: MyColor.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.category['title'],
              style: MyStyle.b4.copyWith(color: MyColor.white)),
        ),
        body: Stack(
          children: [
            // Arkaplan dekorasyonu
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: SvgPicture.asset(
                  'assets/svg/stars.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Ana içerik
            SafeArea(
              child: Column(
                children: [
                  _buildSearchBar(),
                  if (_isLoading)
                    Expanded(
                      child: _buildShimmerList(),
                    )
                  else if (_filteredRituals.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          easy.tr('errors.no_results_found'),
                          style: MyStyle.s1.copyWith(color: MyColor.white),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(MySize.defaultPadding),
                        itemCount: _filteredRituals.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<Map<String, dynamic>>(
                            future: RitualService.translateRitualDetails(
                              _filteredRituals[index],
                              locale,
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final ritual = snapshot.data!;
                              return FadeInUp(
                                delay: Duration(milliseconds: 100 * index),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RitualDetailScreen(ritual: ritual),
                                    ),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        bottom: MySize.defaultPadding),
                                    decoration: BoxDecoration(
                                      color: MyColor.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                          MySize.halfRadius),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(
                                                MySize.halfRadius),
                                          ),
                                          child: RitualService.getCachedImage(
                                              widget.category['image']
                                                  as String,
                                              height: 200),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(
                                              MySize.defaultPadding),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ritual['title'] as String,
                                                style: MyStyle.b4.copyWith(
                                                    color: MyColor.white),
                                              ),
                                              SizedBox(
                                                  height: MySize.halfPadding),
                                              Row(
                                                children: [
                                                  _buildInfoChip(
                                                      ritual['duration']
                                                          as String),
                                                  SizedBox(
                                                      width:
                                                          MySize.halfPadding),
                                                  _buildInfoChip(
                                                      ritual['difficulty']
                                                          as String),
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
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MySize.defaultPadding,
        vertical: MySize.quarterPadding,
      ),
      decoration: BoxDecoration(
        color: MyColor.primaryLightColor,
        borderRadius: BorderRadius.circular(MySize.quarterRadius),
      ),
      child: Text(
        text,
        style: MyStyle.s3.copyWith(color: MyColor.white),
      ),
    );
  }
}
