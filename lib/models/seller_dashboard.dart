class SellerDashboardKpis {
  const SellerDashboardKpis({
    this.todaySalesGnf = 0,
    this.todaySalesNetGnf = 0,
    this.listingsActiveCount = 0,
    this.listingsDraftCount = 0,
    this.listingsTotalCount = 0,
    this.toPrepareCount = 0,
    this.shippedCount = 0,
    this.soldCount = 0,
    this.offersPendingCount = 0,
    this.openEscrowOrderCount = 0,
    this.lowStockCount = 0,
  });

  final int todaySalesGnf;
  final int todaySalesNetGnf;
  final int listingsActiveCount;
  final int listingsDraftCount;
  final int listingsTotalCount;
  final int toPrepareCount;
  final int shippedCount;
  final int soldCount;
  final int offersPendingCount;
  final int openEscrowOrderCount;
  final int lowStockCount;

  factory SellerDashboardKpis.fromJson(Map<String, dynamic>? json) {
    int n(dynamic v) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    final m = json ?? {};
    return SellerDashboardKpis(
      todaySalesGnf: n(m['todaySalesGnf']),
      todaySalesNetGnf: n(m['todaySalesNetGnf']),
      listingsActiveCount: n(m['listingsActiveCount']),
      listingsDraftCount: n(m['listingsDraftCount']),
      listingsTotalCount: n(m['listingsTotalCount']),
      toPrepareCount: n(m['toPrepareCount']),
      shippedCount: n(m['shippedCount']),
      soldCount: n(m['soldCount']),
      offersPendingCount: n(m['offersPendingCount']),
      openEscrowOrderCount: n(m['openEscrowOrderCount']),
      lowStockCount: n(m['lowStockCount']),
    );
  }

  String get todaySalesLabel {
    final amount =
        todaySalesNetGnf > 0 ? todaySalesNetGnf : todaySalesGnf;
    return '${_formatCompact(amount)} GNF';
  }

  static String _formatCompact(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class SellerDashboardShare {
  const SellerDashboardShare({
    this.publicShopSlug,
    this.publicShopUrl,
    this.sellerProfileId,
  });

  final String? publicShopSlug;
  final String? publicShopUrl;
  final String? sellerProfileId;

  factory SellerDashboardShare.fromJson(Map<String, dynamic>? json) {
    final m = json ?? {};
    return SellerDashboardShare(
      publicShopSlug:
          (m['publicShopSlug'] ?? m['slug'])?.toString(),
      publicShopUrl:
          (m['publicShopUrl'] ?? m['url'])?.toString(),
      sellerProfileId: m['sellerProfileId']?.toString(),
    );
  }
}

class SellerDashboardWalletSnap {
  const SellerDashboardWalletSnap({
    this.availableGnf = 0,
    this.pendingEscrowGnf = 0,
    this.minWithdrawalGnf = 10000,
    this.defaultPayoutMsisdn,
  });

  final int availableGnf;
  final int pendingEscrowGnf;
  final int minWithdrawalGnf;
  final String? defaultPayoutMsisdn;

  factory SellerDashboardWalletSnap.fromJson(Map<String, dynamic>? json) {
    int n(dynamic v) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    final m = json ?? {};
    return SellerDashboardWalletSnap(
      availableGnf: n(m['availableGnf']),
      pendingEscrowGnf: n(m['pendingEscrowGnf'] ?? m['escrowGnf']),
      minWithdrawalGnf: n(m['minWithdrawalGnf'] ?? 10000),
      defaultPayoutMsisdn: m['defaultPayoutMsisdn']?.toString(),
    );
  }
}

class SellerDashboard {
  const SellerDashboard({
    required this.sellerProfileId,
    this.shopName,
    this.shopKind,
    this.verificationStatus = 'NONE',
    this.wallet = const SellerDashboardWalletSnap(),
    this.kpis = const SellerDashboardKpis(),
    this.share = const SellerDashboardShare(),
  });

  final String sellerProfileId;
  final String? shopName;
  final String? shopKind;
  final String verificationStatus;
  final SellerDashboardWalletSnap wallet;
  final SellerDashboardKpis kpis;
  final SellerDashboardShare share;

  factory SellerDashboard.fromJson(Map<String, dynamic> json) {
    final walletRaw = json['wallet'];
    final kpisRaw = json['kpis'];
    final shareRaw = json['share'];
    return SellerDashboard(
      sellerProfileId: (json['sellerProfileId'] ?? '').toString(),
      shopName: json['shopName']?.toString(),
      shopKind: json['shopKind']?.toString(),
      verificationStatus:
          (json['verificationStatus'] ?? 'NONE').toString().toUpperCase(),
      wallet: SellerDashboardWalletSnap.fromJson(
        walletRaw is Map ? Map<String, dynamic>.from(walletRaw) : null,
      ),
      kpis: SellerDashboardKpis.fromJson(
        kpisRaw is Map ? Map<String, dynamic>.from(kpisRaw) : null,
      ),
      share: SellerDashboardShare.fromJson(
        shareRaw is Map ? Map<String, dynamic>.from(shareRaw) : null,
      ),
    );
  }
}
