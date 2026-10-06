/// Drill-down taxonomy for the sell form (Depop-style).
/// Leaf nodes map onto [listingCatalog] category / subcategory ids.
class SellCategoryNode {
  const SellCategoryNode({
    required this.id,
    required this.label,
    this.children = const [],
    this.listingCategoryId,
    this.listingSubcategoryId,
  });

  final String id;
  final String label;
  final List<SellCategoryNode> children;
  final String? listingCategoryId;
  final String? listingSubcategoryId;

  bool get isLeaf => children.isEmpty;

  bool get mapsToListing =>
      listingCategoryId != null && listingCategoryId!.isNotEmpty;
}

class SellCategorySelection {
  const SellCategorySelection({
    required this.path,
    required this.listingCategoryId,
    this.listingSubcategoryId,
  });

  final List<SellCategoryNode> path;
  final String listingCategoryId;
  final String? listingSubcategoryId;

  String get displayLabel => path.map((n) => n.label).join(' · ');
}

SellCategoryNode _leaf(
  String id,
  String label, {
  required String categoryId,
  String? subcategoryId,
}) {
  return SellCategoryNode(
    id: id,
    label: label,
    listingCategoryId: categoryId,
    listingSubcategoryId: subcategoryId,
  );
}

SellCategoryNode _branch(
  String id,
  String label,
  List<SellCategoryNode> children,
) {
  return SellCategoryNode(id: id, label: label, children: children);
}

List<SellCategoryNode> _clothingLeaves(String genderSub) => [
      _branch('tops', 'Tops', [
        _leaf('tshirts', 'T-shirts', categoryId: 'mode', subcategoryId: genderSub),
        _leaf('jerseys', 'Jerseys', categoryId: 'mode', subcategoryId: genderSub),
        _leaf('hoodies', 'Hoodies', categoryId: 'mode', subcategoryId: genderSub),
        _leaf('sweatshirts', 'Sweatshirts',
            categoryId: 'mode', subcategoryId: genderSub),
        _leaf('jumpers', 'Jumpers', categoryId: 'mode', subcategoryId: genderSub),
        _leaf('cardigans', 'Cardigans',
            categoryId: 'mode', subcategoryId: genderSub),
        _leaf('shirts', 'Shirts', categoryId: 'mode', subcategoryId: genderSub),
        _leaf('polos', 'Polo shirts',
            categoryId: 'mode', subcategoryId: genderSub),
        _leaf('vests', 'Vests', categoryId: 'mode', subcategoryId: genderSub),
        _leaf('tops_other', 'Other',
            categoryId: 'mode', subcategoryId: genderSub),
      ]),
      _branch('bottoms', 'Bottoms', [
        _leaf('jeans', 'Jeans', categoryId: 'mode', subcategoryId: genderSub),
        _leaf('sweatpants', 'Sweatpants',
            categoryId: 'mode', subcategoryId: genderSub),
        _leaf('trousers', 'Trousers',
            categoryId: 'mode', subcategoryId: genderSub),
        _leaf('shorts', 'Shorts', categoryId: 'mode', subcategoryId: genderSub),
        _leaf('bottoms_other', 'Other',
            categoryId: 'mode', subcategoryId: genderSub),
      ]),
      _branch('coats', 'Coats and jackets', [
        _leaf('coats_item', 'Coats',
            categoryId: 'mode', subcategoryId: genderSub),
        _leaf('jackets', 'Jackets',
            categoryId: 'mode', subcategoryId: genderSub),
        _leaf('gilets', 'Gilets', categoryId: 'mode', subcategoryId: genderSub),
        _leaf('coats_other', 'Other',
            categoryId: 'mode', subcategoryId: genderSub),
      ]),
      _leaf('jumpsuits', 'Jumpsuits and playsuits',
          categoryId: 'mode', subcategoryId: genderSub),
      _leaf('suits', 'Suits', categoryId: 'mode', subcategoryId: genderSub),
      _leaf('footwear', 'Footwear',
          categoryId: 'shoes', subcategoryId: genderSub),
      _leaf('accessories', 'Accessories',
          categoryId: 'mode', subcategoryId: 'accessories'),
      _branch('nightwear', 'Nightwear', [
        _leaf('pyjamas', 'Pyjamas',
            categoryId: 'mode', subcategoryId: genderSub),
        _leaf('robes', 'Robes', categoryId: 'mode', subcategoryId: genderSub),
        _leaf('nightwear_other', 'Other',
            categoryId: 'mode', subcategoryId: genderSub),
      ]),
      _leaf('underwear', 'Underwear',
          categoryId: 'mode', subcategoryId: genderSub),
      _leaf('swimwear', 'Swimwear',
          categoryId: 'mode', subcategoryId: genderSub),
      _leaf('fancy_dress', 'Fancy dress',
          categoryId: 'mode', subcategoryId: genderSub),
    ];

/// Fashion-first sell taxonomy.
final List<SellCategoryNode> sellCategoryTree = [
  _branch('men', 'Men', _clothingLeaves('men')),
  _branch('women', 'Women', _clothingLeaves('women')),
  _branch('kids', 'Kids', _clothingLeaves('kids')),
  _branch('everything_else', 'Everything else', [
    _leaf('shoes', 'Shoes', categoryId: 'shoes'),
    _leaf('electronics', 'Electronics', categoryId: 'electronics'),
    _leaf('beauty', 'Beauty & cosmetics', categoryId: 'beauty'),
    _leaf('baby', 'Baby & maternity', categoryId: 'baby'),
    _leaf('home', 'Home & decor', categoryId: 'home'),
    _leaf('grocery', 'Grocery', categoryId: 'grocery'),
    _leaf('secondhand', 'Second-hand', categoryId: 'secondhand'),
  ]),
];
