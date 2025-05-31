import 'package:flutter/foundation.dart';
import 'package:todo/utility/CustomList.dart';

class StatusNotifier extends ChangeNotifier{
  Status _status= Status.pending;
  Status get status => _status;
  void setStatus(Status currentStatus){
    _status = currentStatus;
    notifyListeners();
  }
}