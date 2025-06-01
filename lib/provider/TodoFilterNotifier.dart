import 'package:flutter/foundation.dart';
import 'package:todo/utility/CustomList.dart';


class TodoFilterNotifier extends ChangeNotifier{
    FilterCategory _filterCategory = FilterCategory.all;
    void setFilterCategory(FilterCategory category){
      _filterCategory =category;
      notifyListeners();
    }
    FilterCategory get currentFilterCategory=> _filterCategory;
}