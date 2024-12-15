import 'package:flutter/material.dart';
import 'package:spirootv2/blog/models/blog_post.dart';
import 'package:spirootv2/blog/services/blog_service.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:easy_localization/easy_localization.dart';

class EditBlogPostScreen extends StatefulWidget {
  final BlogPost post;

  const EditBlogPostScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<EditBlogPostScreen> createState() => _EditBlogPostScreenState();
}

class _EditBlogPostScreenState extends State<EditBlogPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _blogService = BlogService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title;
    _contentController.text = widget.post.content;
    _imageUrlController.text = widget.post.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _blogService.updateBlogPost(
        postId: widget.post.id,
        title: _titleController.text,
        content: _contentController.text,
        imageUrl: _imageUrlController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('Blog yazınız başarıyla güncellendi')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: MyColor.transparent,
        elevation: 0,
        title: Text(
          tr("Blog Yazısını Düzenle"),
          style: MyStyle.b4.copyWith(color: MyColor.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(MyIcon.back,
              color: MyColor.white, size: MySize.iconSizeSmall),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MySize.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: MyColor.white),
                decoration: InputDecoration(
                  labelText: tr("Başlık"),
                  labelStyle: TextStyle(color: MyColor.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: MyColor.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColor.primaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr("Başlık zorunludur");
                  }
                  return null;
                },
              ),
              SizedBox(height: MySize.defaultPadding),
              TextFormField(
                controller: _imageUrlController,
                style: TextStyle(color: MyColor.white),
                decoration: InputDecoration(
                  labelText: tr("Görsel URL'si"),
                  labelStyle: TextStyle(color: MyColor.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: MyColor.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColor.primaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr("Görsel URL'si zorunludur");
                  }

                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.isAbsolute) {
                    return tr("Geçerli bir URL giriniz");
                  }

                  final validExtensions = [
                    '.jpg',
                    '.jpeg',
                    '.png',
                    '.gif',
                    '.webp'
                  ];
                  final hasValidExtension = validExtensions
                      .any((ext) => value.toLowerCase().endsWith(ext));

                  if (!hasValidExtension) {
                    return tr(
                        "Desteklenen görsel formatları: JPG, JPEG, PNG, GIF, WEBP");
                  }

                  return null;
                },
              ),
              SizedBox(height: MySize.defaultPadding),
              TextFormField(
                controller: _contentController,
                style: TextStyle(color: MyColor.white),
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: tr("İçerik"),
                  labelStyle: TextStyle(color: MyColor.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: MyColor.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColor.primaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr("İçerik zorunludur");
                  }
                  if (value.length < 500) {
                    return tr("İçerik en az 500 karakter olmalıdır");
                  }
                  return null;
                },
              ),
              SizedBox(height: MySize.defaultPadding * 2),
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryColor,
                  padding:
                      EdgeInsets.symmetric(vertical: MySize.defaultPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.quarterRadius),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: MyColor.white)
                    : Text(
                        tr("Güncelle"),
                        style: MyStyle.b4.copyWith(color: MyColor.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
