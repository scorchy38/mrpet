import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/model/data/bannerAds.dart';
import 'package:mrpet/model/data/brands.dart';
import 'package:mrpet/model/data/cart.dart';
import 'package:mrpet/model/data/orders.dart';
import 'package:mrpet/model/data/wishlist.dart';
import 'package:mrpet/model/notifiers/bannerAd_notifier.dart';
import 'package:mrpet/model/notifiers/brands_notifier.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/orders_notifier.dart';
import 'package:mrpet/model/notifiers/products_notifier.dart';
import 'package:mrpet/model/notifiers/wishlist_notifier.dart';
import 'package:mrpet/model/services/auth_service.dart';
import 'package:mrpet/widgets/allWidgets.dart';

final db = FirebaseFirestore.instance;
var id = '';

Future<void> initPlatformState() async {
  Map<String, dynamic> deviceData;

  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.id}');

      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.model}');
      id = iosInfo.model;
    }
  } on PlatformException {
    deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
  }
}

//Getting products
getProdProducts(ProductsNotifier productsNotifier) async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("food").get();

  List<ProdProducts> _prodProductsList = [];

  snapshot.docs.forEach((document) {
    ProdProducts prodProducts = ProdProducts.fromMap(document.data());

    _prodProductsList.add(prodProducts);
  });

  productsNotifier.productsList = _prodProductsList;
}

getCat(CategoryNotifier categoryNotifier) async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("Categories").get();

  List<Cat> _cat = [];

  snapshot.docs.forEach((document) {
    Cat c = Cat.fromMap(document.data());

    _cat.add(c);
  });

  categoryNotifier.productsList = _cat;
}

//Adding users' product to cart
addProductToCart(product, _scaffoldKey) async {
  final uEmail = await AuthService().getCurrentEmail();
  if (uEmail == null) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.id}=================');

      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.model}');
      id = iosInfo.model;
    }

    print(id);
    await db
        .collection("tempUserCart")
        .doc(id)
        .collection("cartItems")
        .doc(product.productID)
        .set(product.toMap())
        .catchError((e) {
      print(e);
    });
    showSimpleSnack(
      "Product added to bag",
      Icons.check_circle_outline,
      Colors.green,
      _scaffoldKey,
    );

//    print('Logged Out');
//    showSimpleSnack(
//      "Please login First",
//      Icons.error_outline,
//      Colors.red,
//      _scaffoldKey,
//    );
    return;
  } else {
    await db
        .collection("userCart")
        .doc(uEmail)
        .collection("cartItems")
        .doc(product.productID)
        .set(product.toMap())
        .catchError((e) {
      print(e);
    });
    showSimpleSnack(
      "Product added to bag",
      Icons.check_circle_outline,
      Colors.green,
      _scaffoldKey,
    );
  }
}

//Adding users' product to wishlist
addProductToWishlist(product, _scaffoldKey) async {
  final uEmail = await AuthService().getCurrentEmail();
  if (uEmail == null) {
    showSimpleSnack(
      "Please login First",
      Icons.error_outline,
      Colors.red,
      _scaffoldKey,
    );
    return;
  }
  await db
      .collection("userWishlist")
      .doc(uEmail)
      .collection("wishlistItems")
      .doc(product.productID)
      .set(product.toMap())
      .catchError((e) {
    print(e);
  });
}

//Getting brands
getBrands(BrandsNotifier brandsNotifier) async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("brands").get();

  List<Brands> _brandsList = [];

  snapshot.docs.forEach((document) {
    Brands brands = Brands.fromMap(document.data());
    _brandsList.add(brands);
  });

  brandsNotifier.brandsList = _brandsList;
  print(_brandsList);
}

//Getting bannersAds
getBannerAds(BannerAdNotifier bannerAdNotifier) async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("bannerAds").get();

  List<BannerAds> _bannerAdsList = [];

  snapshot.docs.forEach((document) {
    BannerAds bannerAds = BannerAds.fromMap(document.data());
    _bannerAdsList.add(bannerAds);
  });

  bannerAdNotifier.bannerAdsList = _bannerAdsList;
  print(_bannerAdsList);
}

//Getting users' cart
getCart(CartNotifier cartNotifier) async {
  final uEmail = await AuthService().getCurrentEmail();
  if (uEmail == null) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.id}');

      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.model}');
      id = iosInfo.model;
    }
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("tempUserCart")
        .doc(id)
        .collection("cartItems")
        .get();

    List<Cart> _cartList = [];

    snapshot.docs.forEach((document) {
      Cart cart = Cart.fromMap(document.data());
      _cartList.add(cart);
    });

    cartNotifier.cartList = _cartList;
  } else {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("userCart")
        .doc(uEmail)
        .collection("cartItems")
        .get();

    List<Cart> _cartList = [];

    snapshot.docs.forEach((document) {
      Cart cart = Cart.fromMap(document.data());
      _cartList.add(cart);
    });

    cartNotifier.cartList = _cartList;
  }
}

//Getting users' wishlist
getWishlist(WishlistNotifier wishlistNotifier) async {
  final uEmail = await AuthService().getCurrentEmail();

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("userWishlist")
      .doc(uEmail)
      .collection("wishlistItems")
      .get();

  List<Wishlist> _wishlistList = [];

  snapshot.docs.forEach((document) {
    Wishlist wishlist = Wishlist.fromMap(document.data());
    _wishlistList.add(wishlist);
  });

  wishlistNotifier.wishlistList = _wishlistList;
}

//Adding item quantity, Price and updating data in cart
addAndApdateData(cartItem) async {
  final uEmail = await AuthService().getCurrentEmail();
  if (uEmail == null) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.id}');

      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.model}');
      id = iosInfo.model;
    }
    if (cartItem.quantity >= 9) {
      cartItem.quantity = cartItem.quantity = 9;
    } else {
      cartItem.quantity = cartItem.quantity + 1;
    }
    cartItem.totalPrice = cartItem.price * cartItem.quantity;

    CollectionReference cartRef =
        db.collection("tempUserCart").doc(id).collection("cartItems");

    await cartRef.doc(cartItem.productID).update(
      {'quantity': cartItem.quantity, 'totalPrice': cartItem.totalPrice},
    );
  } else {
    if (cartItem.quantity >= 9) {
      cartItem.quantity = cartItem.quantity = 9;
    } else {
      cartItem.quantity = cartItem.quantity + 1;
    }
    cartItem.totalPrice = cartItem.price * cartItem.quantity;

    CollectionReference cartRef =
        db.collection("userCart").doc(uEmail).collection("cartItems");

    await cartRef.doc(cartItem.productID).update(
      {'quantity': cartItem.quantity, 'totalPrice': cartItem.totalPrice},
    );
  }
}

//Subtracting item quantity, Price and updating data in cart
subAndApdateData(cartItem) async {
  final uEmail = await AuthService().getCurrentEmail();
  if (uEmail == null) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.id}');

      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.model}');
      id = iosInfo.model;
    }
    if (cartItem.quantity <= 1) {
      cartItem.quantity = cartItem.quantity = 1;
    } else {
      cartItem.quantity = cartItem.quantity - 1;
    }
    cartItem.totalPrice = cartItem.price * cartItem.quantity;

    CollectionReference cartRef =
        db.collection("tempUserCart").doc(id).collection("cartItems");

    await cartRef.doc(cartItem.productID).update(
      {'quantity': cartItem.quantity, 'totalPrice': cartItem.totalPrice},
    );
  } else {
    if (cartItem.quantity <= 1) {
      cartItem.quantity = cartItem.quantity = 1;
    } else {
      cartItem.quantity = cartItem.quantity - 1;
    }
    cartItem.totalPrice = cartItem.price * cartItem.quantity;

    CollectionReference cartRef =
        db.collection("userCart").doc(uEmail).collection("cartItems");

    await cartRef.doc(cartItem.productID).update(
      {'quantity': cartItem.quantity, 'totalPrice': cartItem.totalPrice},
    );
  }
}

//Removing item from cart
removeItemFromCart(cartItem) async {
  final uEmail = await AuthService().getCurrentEmail();
  if (uEmail == null) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.id}');

      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.model}');
      id = iosInfo.model;
    }
    await db
        .collection("userCart")
        .doc(id)
        .collection("cartItems")
        .doc(cartItem.productID)
        .delete();
  } else {
    await db
        .collection("userCart")
        .doc(uEmail)
        .collection("cartItems")
        .doc(cartItem.productID)
        .delete();
  }
}

//Removing item from cart
removeItemFromWishlist(wishlistItem) async {
  final uEmail = await AuthService().getCurrentEmail();

  await db
      .collection("userWishlist")
      .doc(uEmail)
      .collection("wishlistItems")
      .doc(wishlistItem.productID)
      .delete();
}

//Clearing users' cart
clearCartAfterPurchase() async {
  final uEmail = await AuthService().getCurrentEmail();

  await db
      .collection('userCart')
      .doc(uEmail)
      .collection("cartItems")
      .get()
      .then((snapshot) {
    for (DocumentSnapshot doc in snapshot.docs) {
      doc.reference.delete();
    }
  });
}

//Adding users' product to cart
addCartToOrders(cartList, orderID, address, date,orderType,time) async {
  final uEmail = await AuthService().getCurrentEmail();
  var orderDate = FieldValue.serverTimestamp();

  var orderStatus = "processing";
  var shippingAddress = address;

  await db
      .collection("userOrder")
      .doc(uEmail)
      .collection("orders")
      .doc(orderID)
      .set(
    {
      'orderID': orderID,
      'orderDate': orderDate,
      'orderStatus': orderStatus,
      'shippingAddress': shippingAddress,
      'order': cartList.map((i) => i.toMap()).toList(),
      'deliveryDate': date,
      'deliveryTime':time,
      'orderType':orderType
    },
  ).catchError((e) {
    print(e);
  });

  //Sending orders to merchant
  await db
      .collection("merchantOrder")
      .doc(uEmail)
      .collection("orders")
      .doc(orderID)
      .set(
    {
      'orderID': orderID,
      'orderDate': orderDate,
      'shippingAddress': shippingAddress,
      'order': cartList.map((i) => i.toMap()).toList(),
      'deliveryDate': date,
      'deliveryTime':time,
      'orderType':orderType
    },
  ).catchError((e) {
    print(e);
  });
}

//Getting users' orders
getOrders(
  OrderListNotifier orderListNotifier,
) async {
  final uEmail = await AuthService().getCurrentEmail();

  QuerySnapshot ordersSnapshot =
      await db.collection("userOrder").doc(uEmail).collection("orders").get();

  List<OrdersList> _ordersListList = [];

  ordersSnapshot.docs.forEach((document) {
    OrdersList ordersList = OrdersList.fromMap(document.data());
    _ordersListList.add(ordersList);
  });
  orderListNotifier.orderListList = _ordersListList;
}
