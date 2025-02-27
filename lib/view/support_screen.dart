import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/router.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:trim_talk/view/settings_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

const coffeeId = 'support.tip.coffee';
const cookieId = 'support.tip.cookie';
const sandwichId = 'support.tip.sandwich';
const coffeeSubscriptionId = 'support.subscription.coffee';

class _SupportScreenState extends State<SupportScreen> {
  List<ProductDetails> purchaseProducts = [];

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    flushTransactionsIOS();
    _subscription = InAppPurchase.instance.purchaseStream.listen(handlePurchaseUpdates);
    fetchProducts();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    final response = await InAppPurchase.instance.queryProductDetails({coffeeId, cookieId, sandwichId, coffeeSubscriptionId});

    // order by price, subscription last
    final sorted = response.productDetails.toList()
      ..sort((a, b) {
        if (a.id.contains('subscription')) return 1;
        if (b.id.contains('subscription')) return -1;

        return a.rawPrice.compareTo(b.rawPrice);
      });

    setState(() {
      purchaseProducts = sorted;
    });
  }

  void buyProduct(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    if (isConsumable(product)) {
      InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    } else {
      InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  /// tips are consumable
  bool isConsumable(ProductDetails product) {
    return product.id.contains('tip');
  }

  void flushTransactionsIOS() async {
    if (!Platform.isIOS) return;

    try {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final t in transactions) {
        await SKPaymentQueueWrapper().finishTransaction(t);
      }
    } catch (e) {
      print('Error restoring transactions: $e');
    }
  }

  void handlePurchaseUpdates(List<PurchaseDetails> purchaseList) async {
    for (final p in purchaseList) {
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }

      if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
        print('purchase succes: ${p.productID}');
        // show thank you dialog
        if (!mounted) return;

        return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(context.t.hugeThanks),
              content: Icon(
                Icons.volunteer_activism_outlined,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                    context.goNamed(NamedRoutes.dashboard.name);
                  },
                  child: Text(context.t.close),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.t.supportMyWork),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(
              Icons.adaptive.arrow_back,
              size: 30,
              color: Theme.of(context).colorScheme.surface,
            ),
            onPressed: () {
              context.goNamed(NamedRoutes.dashboard.name);
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.t.trimtalkWillAlwaysBeFreeAndAdFreeButYourSupportIsAppreciatedThankYou),
            gapH24,
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: purchaseProducts.length,
              itemBuilder: (context, index) {
                final product = purchaseProducts[index];

                return ListTile(
                  leading: switch (product.id) {
                    coffeeId => Icon(Icons.local_cafe_outlined),
                    cookieId => Icon(Icons.cookie_outlined),
                    sandwichId => Icon(Icons.lunch_dining_outlined),
                    coffeeSubscriptionId => Icon(Icons.coffee_maker_outlined),
                    _ => null,
                  },
                  title: Text(
                    product.title.replaceAll("(TrimTalk)", ""), // for some reason google play adds (TrimTalk) to the title
                  ),
                  subtitle: Text(product.price),
                  trailing: ElevatedButton(
                    onPressed: () => buyProduct(product),
                    child: Icon(Icons.volunteer_activism_outlined),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
            gapH16,
            SeeOnGithubButton(),
            gapH12,
            TextButton.icon(
              onPressed: () => InAppPurchase.instance.restorePurchases(),
              label: Text(context.t.restorePurchases),
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
