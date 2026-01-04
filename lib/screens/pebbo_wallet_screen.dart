import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class PebboCoinProduct {
  final String amountStr;
  final String productId;
  final double price;
  int get amount => int.tryParse(amountStr) ?? 0;
  const PebboCoinProduct(this.amountStr, this.productId, this.price);
}


class PebboCoinProducts {
  static const List<PebboCoinProduct> all = [
    PebboCoinProduct('32', 'Pebbo', 0.99),
    PebboCoinProduct('60', 'Pebbo1', 1.99),
    PebboCoinProduct('96', 'Pebbo2', 2.99),
    PebboCoinProduct('155', 'Pebbo4', 4.99),
    PebboCoinProduct('189', 'Pebbo5', 5.99),
    PebboCoinProduct('359', 'Pebbo9', 9.99),
    PebboCoinProduct('729', 'Pebbo19', 19.99),
    PebboCoinProduct('1869', 'Pebbo49', 49.99),
    PebboCoinProduct('3799', 'Pebbo99', 99.99),
  ];
}

class PebboWalletScreen extends StatefulWidget {
  const PebboWalletScreen({super.key});

  @override
  State<PebboWalletScreen> createState() => _PebboWalletScreenState();
}

class _PebboWalletScreenState extends State<PebboWalletScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _purchasePending = false;
  int _coins = 0;
  final Set<String> _processedPurchases = {};
  bool _isInitialized = false;
  int _selectedProductIndex = 0;

  List<PebboCoinProduct> get _pebboCoinProducts => PebboCoinProducts.all;

  @override
  void initState() {
    super.initState();
    
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(_listenToPurchaseUpdated, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Error in IAP Stream: $error");
    });
    _loadPebboCoins();
    _initPebboInAppPurchase();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _loadPebboCoins() async {
    final prefs = await SharedPreferences.getInstance();
    int coins = prefs.getInt('pebboCoins') ?? 0;
    debugPrint('Loading Pebbo coins: $coins');
      setState(() {
        _coins = coins;
        if (!_isInitialized) {
          _isInitialized = true;
          debugPrint('Initialized from _loadPebboCoins');
        }
      });
  }

  Future<void> _savePebboCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Saving Pebbo coins: current=$_coins, adding=$amount, new=${_coins + amount}');
    debugPrint('Call stack: ${StackTrace.current}');
    setState(() {
      _coins += amount;
    });
    await prefs.setInt('pebboCoins', _coins);
  }

  Future<void> _initPebboInAppPurchase() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    debugPrint('Store availability: $isAvailable');
    
    if (!isAvailable) {
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
      return;
    }
    
    final Set<String> productIds = _pebboCoinProducts.map((e) => e.productId).toSet();
    debugPrint('Querying products: $productIds');
    
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      debugPrint('Found ${response.productDetails.length} products');
      debugPrint('Product IDs: ${response.productDetails.map((p) => p.id).toList()}');
      
      setState(() {
        _products = response.productDetails;
        _isLoading = false;
        _isInitialized = true; // Mark initialization complete
      });
      debugPrint('InAppPurchase initialized successfully');
      
      if (response.productDetails.isEmpty) {
        // _showSnackBar("No products available");
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      setState(() {
        _isLoading = false;
        _isInitialized = true; // Mark as initialized even on error
      });
      _showSnackBar("Failed to load products: $e");
    }
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    if (!_isInitialized) {
      debugPrint('Ignoring purchase updates during initialization');
      return;
    }
    
    for (var purchaseDetails in purchaseDetailsList) {
      debugPrint('Purchase status: ${purchaseDetails.status} for product: ${purchaseDetails.productID}');
      
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          _purchasePending = true;
        });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          setState(() {
            _purchasePending = false;
          });
          _showSnackBar("Purchase failed: ${purchaseDetails.error?.message ?? 'Unknown error'}");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          _handleSuccessfulPurchase(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          setState(() {
            _purchasePending = false;
          });
        }
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    String purchaseKey = '${purchaseDetails.productID}_${purchaseDetails.purchaseID}_${purchaseDetails.status}';
    if (_processedPurchases.contains(purchaseKey)) {
      debugPrint('Purchase already processed: $purchaseKey');
      return;
    }
    
    _processedPurchases.add(purchaseKey);
    
    debugPrint('Handling successful purchase: ${purchaseDetails.productID} (${purchaseDetails.status})');
    debugPrint('Available product IDs: ${_pebboCoinProducts.map((p) => p.productId).toList()}');
    
    setState(() {
      _purchasePending = false;
    });
    
    final product = _pebboCoinProducts.firstWhere(
      (e) => e.productId == purchaseDetails.productID, 
      orElse: () {
        debugPrint('Product not found in configuration: ${purchaseDetails.productID}');
        return PebboCoinProduct('', '', 0);
      }
    );
    
    if (product.amount > 0) {
      debugPrint('Processing purchase: ${product.amount} coins for product ${purchaseDetails.productID}');
      await _savePebboCoins(product.amount);
      _showSnackBar("Purchase successful! +${product.amount} Coins");
    } else {
      debugPrint('Product amount is 0 or product not found: ${purchaseDetails.productID}');
    }
    
    debugPrint('Completing purchase: ${purchaseDetails.productID}');
    await _inAppPurchase.completePurchase(purchaseDetails);
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _processPebboPurchase(String productId) async {
    debugPrint('Attempting to purchase product: $productId');
    debugPrint('Available products: ${_products.map((p) => p.id).toList()}');
    
    ProductDetails? product;
    try {
      product = _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      product = null;
    }
    if (product == null) {
      debugPrint('Product not found: $productId');
      _showSnackBar("Product not available");
      return;
    }
    
    debugPrint('Product found: ${product.id} - ${product.title} - ${product.price}');
    
    setState(() {
      _purchasePending = true;
    });
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      debugPrint('Starting purchase for: ${product.id}');
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      debugPrint('Purchase initiated successfully');
    } catch (e) {
      debugPrint('Error starting purchase: $e');
      setState(() {
        _purchasePending = false;
      });
      _showSnackBar("Error starting purchase: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pebbo_allbg.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: 3,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Custom AppBar
                        _buildCustomAppBar(),
                        const SizedBox(height: 24),
                        
                        // Wallet balance card
                        _buildPebboWalletBalanceCard(),
                        const SizedBox(height: 36),
                        
                        // Select top-up amount title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.primaryColor.withOpacity(0.5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Select Amount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Product grid
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildPebboProductGrid(),
                        ),
                        const SizedBox(height: 36),
                        
                        // Recharge button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildPebboRechargeButton(),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.asset(
              'assets/pebbo_all_back.webp',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'My Wallet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPebboWalletBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.25),
              AppTheme.primaryColor.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white.withOpacity(0.9),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Balance',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_coins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'Coins',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Coin icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/pebbo_wallet_gold.webp',
                  width: 55,
                  height: 55,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.monetization_on,
                      size: 45,
                      color: Colors.white.withOpacity(0.9),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPebboProductGrid() {
    return Column(
      children: _pebboCoinProducts.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        ProductDetails? product;
        try {
          product = _products.firstWhere((p) => p.id == item.productId);
        } catch (e) {
          product = null;
        }
        final priceStr = product != null 
            ? product.price.replaceAll('US\$', '\$')
            : '\$${item.price.toStringAsFixed(2)}';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildPebboProductCard(item, priceStr, index == _selectedProductIndex),
        );
      }).toList(),
    );
  }

  Widget _buildPebboProductCard(PebboCoinProduct item, String priceStr, bool isSelected) {
    return GestureDetector(
      onTap: _purchasePending ? null : () {
        setState(() {
          _selectedProductIndex = _pebboCoinProducts.indexOf(item);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 88,
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.35),
                    AppTheme.primaryColor.withOpacity(0.2),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor.withOpacity(0.8)
                : Colors.white.withOpacity(0.15), 
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              // Left coin icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/pebbo_wallet_gold.webp',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.monetization_on,
                        size: 32,
                        color: Colors.white.withOpacity(0.9),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Center coin amount info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.amount} Coins',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Premium Currency',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Right price button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.6),
                      AppTheme.primaryColor.withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  priceStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Selected indicator
              if (isSelected) ...[
                const SizedBox(width: 12),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPebboRechargeButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(29),
          onTap: _purchasePending ? null : () {
            if (_selectedProductIndex < _pebboCoinProducts.length) {
              final selectedProduct = _pebboCoinProducts[_selectedProductIndex];
              _processPebboPurchase(selectedProduct.productId);
            }
          },
          child: Center(
            child: _purchasePending
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Recharge Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
