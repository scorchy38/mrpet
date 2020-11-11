import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:mrpet/model/data/Products.dart';

class ProductsNotifier with ChangeNotifier {
  List<ProdProducts> _prodProductsList = [];
  ProdProducts _currentProdProduct;

  UnmodifiableListView<ProdProducts> get productsList =>
      UnmodifiableListView(_prodProductsList);

  ProdProducts get currentProdProduct => _currentProdProduct;

  set productsList(List<ProdProducts> prodProductsList) {
    _prodProductsList = prodProductsList;
    notifyListeners();
  }

  set currentProdProduct(ProdProducts prodProducts) {
    _currentProdProduct = prodProducts;
    notifyListeners();
  }
}

class CategoryNotifier with ChangeNotifier {
  List<Cat> _catList = [];
  Cat _cat;

  UnmodifiableListView<Cat> get catList => UnmodifiableListView(_catList);

  Cat get currentProdProduct => _cat;

  set productsList(List<Cat> catList) {
    _catList = catList;
    notifyListeners();
  }

  set currentProdProduct(Cat cat) {
    _cat = cat;
    notifyListeners();
  }
}
