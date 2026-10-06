import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';

/// Seller photo tips — layout from marketplace reference, FripCash colors.
class PhotoTipsScreen extends StatelessWidget {
  const PhotoTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final tips = <_PhotoTip>[
      _PhotoTip(
        title: t.getCoverShotTitle,
        body: t.getCoverShotBody,
        images: const [
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&h=400&fit=crop',
          'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400&h=400&fit=crop',
        ],
      ),
      _PhotoTip(
        title: t.captureAnglesTitle,
        body: t.captureAnglesBody,
        images: const [
          'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=400&h=400&fit=crop',
          'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400&h=400&fit=crop',
          'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&h=400&fit=crop',
        ],
      ),
      _PhotoTip(
        title: t.showTagsTitle,
        body: t.showTagsBody,
        images: const [
          'https://images.unsplash.com/photo-1558171813-4c088753af8f?w=400&h=400&fit=crop',
          'https://images.unsplash.com/photo-1441986300910-5031f32d2259?w=400&h=400&fit=crop',
          'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=400&h=400&fit=crop',
        ],
      ),
      _PhotoTip(
        title: t.showDetailsTitle,
        body: t.showDetailsBody,
        images: const [
          'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400&h=400&fit=crop',
          'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=400&h=400&fit=crop',
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400&h=400&fit=crop',
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          t.photoTipsTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: tips.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) => _PhotoTipCard(tip: tips[index]),
      ),
    );
  }
}

class _PhotoTip {
  const _PhotoTip({
    required this.title,
    required this.body,
    required this.images,
  });

  final String title;
  final String body;
  final List<String> images;
}

class _PhotoTipCard extends StatelessWidget {
  const _PhotoTipCard({required this.tip});

  final _PhotoTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < tip.images.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _TipThumb(url: tip.images[i])),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            tip.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tip.body,
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.72),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipThumb extends StatelessWidget {
  const _TipThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFF4F4F4),
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
