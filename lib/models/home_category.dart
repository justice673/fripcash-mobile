export 'package:frip_cash/models/marketplace_category.dart'
    show categoryPills, marketplaceCategories;

class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.label,
    required this.imageAsset,
  });

  final String id;
  final String label;
  final String imageAsset;
}

/// Grid cards reuse existing home assets; labels aligned with spec categories.
const homeCategories = <HomeCategory>[
  HomeCategory(
    id: 'mode',
    label: 'Mode & Accessoires',
    imageAsset: 'assets/images/home/woman.png',
  ),
  HomeCategory(
    id: 'shoes',
    label: 'Chaussures',
    imageAsset: 'assets/images/home/sports.png',
  ),
  HomeCategory(
    id: 'secondhand',
    label: 'Seconde main',
    imageAsset: 'assets/images/home/man.png',
  ),
  HomeCategory(
    id: 'baby',
    label: 'Bébé & Maternité',
    imageAsset: 'assets/images/home/kids.jpg',
  ),
  HomeCategory(
    id: 'home',
    label: 'Maison & Décoration',
    imageAsset: 'assets/images/home/home_decor.jpg',
  ),
  HomeCategory(
    id: 'electronics',
    label: 'Électronique',
    imageAsset: 'assets/images/home/electronics.png',
  ),
  HomeCategory(
    id: 'beauty',
    label: 'Beauté',
    imageAsset: 'assets/images/home/hobbies.png',
  ),
  HomeCategory(
    id: 'grocery',
    label: 'Épicerie',
    imageAsset: 'assets/images/home/hobbies.png',
  ),
];
