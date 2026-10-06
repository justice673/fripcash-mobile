/// Shared FripCash catalog items that neighborhood shops can list.
class LibraryProduct {
  const LibraryProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.unitLabel,
    this.defaultCategoryId = 'grocery',
  });

  final String id;
  final String name;
  final String imageUrl;
  final String unitLabel;
  final String defaultCategoryId;
}

/// Stock value meaning “Disponible” (unlimited / in stock without a count).
const availableStockSentinel = 9999;

const mockProductLibrary = <LibraryProduct>[
  LibraryProduct(
    id: 'lib_riz_25',
    name: 'Riz parfumé 25 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&h=600&fit=crop',
    unitLabel: 'sac 25 kg',
  ),
  LibraryProduct(
    id: 'lib_riz_50',
    name: 'Riz parfumé 50 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&h=600&fit=crop',
    unitLabel: 'sac 50 kg',
  ),
  LibraryProduct(
    id: 'lib_huile_1l',
    name: 'Huile de palme 1 L',
    imageUrl:
        'https://images.unsplash.com/photo-1474979266404-7ea320f7824a?w=600&h=600&fit=crop',
    unitLabel: 'bouteille 1 L',
  ),
  LibraryProduct(
    id: 'lib_huile_5l',
    name: 'Huile végétale 5 L',
    imageUrl:
        'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=600&h=600&fit=crop',
    unitLabel: 'bidon 5 L',
  ),
  LibraryProduct(
    id: 'lib_sucre_1kg',
    name: 'Sucre blanc 1 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1587049352846-4a7b264b3b8f?w=600&h=600&fit=crop',
    unitLabel: 'paquet 1 kg',
  ),
  LibraryProduct(
    id: 'lib_sucre_5kg',
    name: 'Sucre blanc 5 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1481391319762-47dff72954d9?w=600&h=600&fit=crop',
    unitLabel: 'sac 5 kg',
  ),
  LibraryProduct(
    id: 'lib_lait_400',
    name: 'Lait en poudre 400 g',
    imageUrl:
        'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=600&h=600&fit=crop',
    unitLabel: 'boîte 400 g',
  ),
  LibraryProduct(
    id: 'lib_lait_1l',
    name: 'Lait UHT 1 L',
    imageUrl:
        'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600&h=600&fit=crop',
    unitLabel: 'brique 1 L',
  ),
  LibraryProduct(
    id: 'lib_pain',
    name: 'Pain de mie',
    imageUrl:
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&h=600&fit=crop',
    unitLabel: 'paquet',
  ),
  LibraryProduct(
    id: 'lib_oeufs',
    name: 'Œufs (plateau x30)',
    imageUrl:
        'https://images.unsplash.com/photo-1582722879130-628aa126cb4a?w=600&h=600&fit=crop',
    unitLabel: 'plateau',
  ),
  LibraryProduct(
    id: 'lib_coca_33',
    name: 'Coca-Cola 33 cl',
    imageUrl:
        'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=600&h=600&fit=crop',
    unitLabel: 'canette',
  ),
  LibraryProduct(
    id: 'lib_coca_1_5',
    name: 'Coca-Cola 1,5 L',
    imageUrl:
        'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=600&h=600&fit=crop',
    unitLabel: 'bouteille 1,5 L',
  ),
  LibraryProduct(
    id: 'lib_eau_1_5',
    name: 'Eau minérale 1,5 L',
    imageUrl:
        'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=600&h=600&fit=crop',
    unitLabel: 'bouteille',
  ),
  LibraryProduct(
    id: 'lib_eau_pack',
    name: 'Eau minérale (pack x6)',
    imageUrl:
        'https://images.unsplash.com/photo-1560023907-5f339617ea55?w=600&h=600&fit=crop',
    unitLabel: 'pack',
  ),
  LibraryProduct(
    id: 'lib_maggi',
    name: 'Cube Maggi (x24)',
    imageUrl:
        'https://images.unsplash.com/photo-1596040033229-a0b34b8a8b8a?w=600&h=600&fit=crop',
    unitLabel: 'boîte',
  ),
  LibraryProduct(
    id: 'lib_tomate',
    name: 'Concentré de tomate 400 g',
    imageUrl:
        'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=600&h=600&fit=crop',
    unitLabel: 'boîte',
  ),
  LibraryProduct(
    id: 'lib_pate',
    name: 'Pâtes spaghetti 500 g',
    imageUrl:
        'https://images.unsplash.com/photo-1551462147-6382f7d5f1e7?w=600&h=600&fit=crop',
    unitLabel: 'paquet',
  ),
  LibraryProduct(
    id: 'lib_farine',
    name: 'Farine de blé 1 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&h=600&fit=crop',
    unitLabel: 'paquet 1 kg',
  ),
  LibraryProduct(
    id: 'lib_mais',
    name: 'Farine de maïs 1 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=600&h=600&fit=crop',
    unitLabel: 'paquet 1 kg',
  ),
  LibraryProduct(
    id: 'lib_haricot',
    name: 'Haricots blancs 1 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&h=600&fit=crop',
    unitLabel: 'sac 1 kg',
  ),
  LibraryProduct(
    id: 'lib_pois',
    name: 'Pois chiches 1 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1515543904379-3d757afe72e4?w=600&h=600&fit=crop',
    unitLabel: 'sac 1 kg',
  ),
  LibraryProduct(
    id: 'lib_oignon',
    name: 'Oignons (filet 2 kg)',
    imageUrl:
        'https://images.unsplash.com/photo-1518977956812-cd3d11e2f5b1?w=600&h=600&fit=crop',
    unitLabel: 'filet',
  ),
  LibraryProduct(
    id: 'lib_ail',
    name: 'Ail (filet)',
    imageUrl:
        'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=600&h=600&fit=crop',
    unitLabel: 'filet',
  ),
  LibraryProduct(
    id: 'lib_piment',
    name: 'Piment sec 100 g',
    imageUrl:
        'https://images.unsplash.com/photo-1588252303782-cb80119abc45?w=600&h=600&fit=crop',
    unitLabel: 'sachet',
  ),
  LibraryProduct(
    id: 'lib_sel',
    name: 'Sel de cuisine 1 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1518110925499-d1f3a7c7f1f2?w=600&h=600&fit=crop',
    unitLabel: 'paquet',
  ),
  LibraryProduct(
    id: 'lib_the',
    name: 'Thé vert (boîte)',
    imageUrl:
        'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=600&h=600&fit=crop',
    unitLabel: 'boîte',
  ),
  LibraryProduct(
    id: 'lib_cafe',
    name: 'Café moulu 250 g',
    imageUrl:
        'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=600&h=600&fit=crop',
    unitLabel: 'paquet',
  ),
  LibraryProduct(
    id: 'lib_biscuit',
    name: 'Biscuits assortis',
    imageUrl:
        'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=600&h=600&fit=crop',
    unitLabel: 'paquet',
  ),
  LibraryProduct(
    id: 'lib_chocolat',
    name: 'Chocolat en tablette',
    imageUrl:
        'https://images.unsplash.com/photo-1511381939415-e44015466834?w=600&h=600&fit=crop',
    unitLabel: 'tablette',
  ),
  LibraryProduct(
    id: 'lib_savon',
    name: 'Savon de lessive (x3)',
    imageUrl:
        'https://images.unsplash.com/photo-1585659722983-3a675dabf23d?w=600&h=600&fit=crop',
    unitLabel: 'paquet',
    defaultCategoryId: 'home',
  ),
  LibraryProduct(
    id: 'lib_lessive',
    name: 'Lessive en poudre 1 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1610557892470-55d9e80c0bce?w=600&h=600&fit=crop',
    unitLabel: 'sachet',
    defaultCategoryId: 'home',
  ),
  LibraryProduct(
    id: 'lib_papier',
    name: 'Papier toilette (x12)',
    imageUrl:
        'https://images.unsplash.com/photo-1584556812952-905ffd0e8d6a?w=600&h=600&fit=crop',
    unitLabel: 'pack',
    defaultCategoryId: 'home',
  ),
  LibraryProduct(
    id: 'lib_dentifrice',
    name: 'Dentifrice',
    imageUrl:
        'https://images.unsplash.com/photo-1622383563227-04401ab4c8e2?w=600&h=600&fit=crop',
    unitLabel: 'tube',
    defaultCategoryId: 'beauty',
  ),
  LibraryProduct(
    id: 'lib_savon_corps',
    name: 'Savon de toilette',
    imageUrl:
        'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?w=600&h=600&fit=crop',
    unitLabel: 'unité',
    defaultCategoryId: 'beauty',
  ),
  LibraryProduct(
    id: 'lib_couches',
    name: 'Couches bébé (paquet)',
    imageUrl:
        'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=600&h=600&fit=crop',
    unitLabel: 'paquet',
    defaultCategoryId: 'baby',
  ),
  LibraryProduct(
    id: 'lib_lait_bebe',
    name: 'Lait infantile 400 g',
    imageUrl:
        'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600&h=600&fit=crop',
    unitLabel: 'boîte',
    defaultCategoryId: 'baby',
  ),
  LibraryProduct(
    id: 'lib_jus',
    name: 'Jus de fruits 1 L',
    imageUrl:
        'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&h=600&fit=crop',
    unitLabel: 'brique',
  ),
  LibraryProduct(
    id: 'lib_yaourt',
    name: 'Yaourt nature (x4)',
    imageUrl:
        'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600&h=600&fit=crop',
    unitLabel: 'pack',
  ),
  LibraryProduct(
    id: 'lib_beurre',
    name: 'Beurre 200 g',
    imageUrl:
        'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=600&h=600&fit=crop',
    unitLabel: 'plaquette',
  ),
  LibraryProduct(
    id: 'lib_fromage',
    name: 'Fromage fondu',
    imageUrl:
        'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=600&h=600&fit=crop',
    unitLabel: 'boîte',
  ),
  LibraryProduct(
    id: 'lib_sardine',
    name: 'Sardines en conserve',
    imageUrl:
        'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=600&h=600&fit=crop',
    unitLabel: 'boîte',
  ),
  LibraryProduct(
    id: 'lib_thon',
    name: 'Thon en conserve',
    imageUrl:
        'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=600&h=600&fit=crop',
    unitLabel: 'boîte',
  ),
  LibraryProduct(
    id: 'lib_allumettes',
    name: 'Allumettes',
    imageUrl:
        'https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=600&h=600&fit=crop',
    unitLabel: 'boîte',
    defaultCategoryId: 'home',
  ),
  LibraryProduct(
    id: 'lib_bougie',
    name: 'Bougies (paquet)',
    imageUrl:
        'https://images.unsplash.com/photo-1603006905004-7c7f5e4f8c5e?w=600&h=600&fit=crop',
    unitLabel: 'paquet',
    defaultCategoryId: 'home',
  ),
  LibraryProduct(
    id: 'lib_pile',
    name: 'Piles AA (x4)',
    imageUrl:
        'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=600&h=600&fit=crop',
    unitLabel: 'blister',
    defaultCategoryId: 'electronics',
  ),
  LibraryProduct(
    id: 'lib_gaz',
    name: 'Recharge gaz cuisine',
    imageUrl:
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600&h=600&fit=crop',
    unitLabel: 'bouteille',
    defaultCategoryId: 'home',
  ),
  LibraryProduct(
    id: 'lib_charbon',
    name: 'Charbon de bois (sac)',
    imageUrl:
        'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?w=600&h=600&fit=crop',
    unitLabel: 'sac',
    defaultCategoryId: 'home',
  ),
  LibraryProduct(
    id: 'lib_mangue',
    name: 'Mangues (kg)',
    imageUrl:
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&h=600&fit=crop',
    unitLabel: 'kg',
  ),
  LibraryProduct(
    id: 'lib_banane',
    name: 'Bananes (régime)',
    imageUrl:
        'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&h=600&fit=crop',
    unitLabel: 'régime',
  ),
  LibraryProduct(
    id: 'lib_pomme_terre',
    name: 'Pommes de terre 2 kg',
    imageUrl:
        'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&h=600&fit=crop',
    unitLabel: 'sac 2 kg',
  ),
];

LibraryProduct? libraryProductById(String id) {
  for (final product in mockProductLibrary) {
    if (product.id == id) return product;
  }
  return null;
}
