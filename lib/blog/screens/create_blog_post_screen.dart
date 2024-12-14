import 'package:flutter/material.dart';
import 'package:spirootv2/blog/services/blog_service.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateBlogPostScreen extends StatefulWidget {
  const CreateBlogPostScreen({Key? key}) : super(key: key);

  @override
  State<CreateBlogPostScreen> createState() => _CreateBlogPostScreenState();
}

class _CreateBlogPostScreenState extends State<CreateBlogPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _blogService = BlogService();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _blogService.createBlogPost(
        title: _titleController.text,
        content: _contentController.text,
        imageUrl: _imageUrlController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Blog yazınız başarıyla oluşturuldu'),
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
          tr("Yeni Blog Yazısı"),
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
                  if (!Uri.tryParse(value)!.isAbsolute) {
                    return tr("Geçerli bir URL giriniz");
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
                onPressed: _isLoading ? null : _submitPost,
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
                        tr("Yayınla"),
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
