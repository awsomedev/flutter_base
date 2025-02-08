import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageItem {
  final File? file;
  final String? url;

  const ImageItem({this.file, this.url})
      : assert(
            file != null || url != null, 'Either file or url must be provided');

  bool get isFile => file != null;
  bool get isUrl => url != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageItem && other.file == file && other.url == url;
  }

  @override
  int get hashCode => file.hashCode ^ url.hashCode;
}

class ImageListPicker extends StatefulWidget {
  final List<ImageItem> initialImages;
  final Function(List<ImageItem> allImages, ImageItem newImage) onAdd;
  final Function(List<ImageItem> remainingImages, ImageItem removedImage)
      onRemove;
  final double imageSize;
  final double spacing;

  const ImageListPicker({
    super.key,
    this.initialImages = const [],
    required this.onAdd,
    required this.onRemove,
    this.imageSize = 100,
    this.spacing = 8,
  });

  @override
  State<ImageListPicker> createState() => _ImageListPickerState();
}

class _ImageListPickerState extends State<ImageListPicker> {
  late List<ImageItem> _images;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageItem = ImageItem(file: File(image.path));
        setState(() {
          _images.add(imageItem);
        });
        widget.onAdd(_images, imageItem);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removeImage(int index) {
    final removedImage = _images[index];
    setState(() {
      _images.removeAt(index);
    });
    widget.onRemove(_images, removedImage);
  }

  Widget _buildImageWidget(ImageItem source) {
    if (source.isFile) {
      return Image.file(
        source.file!,
        width: widget.imageSize,
        height: widget.imageSize,
        fit: BoxFit.cover,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: source.url!,
        width: widget.imageSize,
        height: widget.imageSize,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.error),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.imageSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + 1,
        separatorBuilder: (context, index) => SizedBox(width: widget.spacing),
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return SizedBox(
              width: widget.imageSize,
              height: widget.imageSize,
              child: Material(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _pickImage,
                  child: const Center(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(_images[index]),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
