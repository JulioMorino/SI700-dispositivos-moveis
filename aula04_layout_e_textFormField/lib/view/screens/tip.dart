class Tip {
  double? _totalAmount;
  final double _defaultTip = 10.0;
  double? _customTip;

  Tip() {
    _customTip = 10.0;
  }

  Tip.withData({customTip = 10.0, totalAmount = 30.0})
      : _customTip = customTip,
        _totalAmount = totalAmount;

  String get customTip {
    return (_customTip ?? 0).toStringAsFixed(2);
  }

  String get defaultTip {
    return _defaultTip.toStringAsFixed(2);
  }

  String get amount {
    return (_totalAmount ?? 0).toStringAsFixed(2);
  }

  String get defaultTippedAmount {
    return ((_totalAmount ?? 0) * (_defaultTip / 100)).toStringAsFixed(2);
  }

  String get amountPlusDefaultTippedAmount {
    return ((_totalAmount ?? 0) * (1 + _defaultTip / 100)).toStringAsFixed(2);
  }

  String get customTippedAmount {
    return ((_totalAmount ?? 0) * (_customTip ?? 0) / 100).toStringAsFixed(2);
  }

  String get amountPlusCustomTippedAmount {
    return ((_totalAmount ?? 0) * (1 + (_customTip ?? 0) / 100))
        .toStringAsFixed(2);
  }

  set amount(String value) {
    try {
      _totalAmount = double.parse(value);
    } catch (e) {
      _totalAmount = 0;
    }
  }

  set customTip(String value) {
    try {
      _customTip = double.parse(value);
    } catch (e) {
      _customTip = 0;
    }
  }
}
