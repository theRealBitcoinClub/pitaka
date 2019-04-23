class Balance {
    int _id;
    String _account;
    String _balance;
    String _timestamp;
    String _signature;
    String _datecreated;

    Balance(
      this._account,
      this._balance,
      this._timestamp,
      this._signature,
      this._datecreated
    );

	  Balance.withId(
      this._id,
      this._account,
      this._balance,
      this._timestamp,
      this._signature,
      this._datecreated
    );

    // (Getters) This can be customized depending on your needs
    int get id => _id;
    String get account => _account;
    String get balance => _balance;
    String get timestamp => _timestamp;
    String get signature => _signature;
    String get datecreated => _datecreated;

    // (Setters) This can be customized depending on your needs
    set account(String value) => this._account = value;
    set balance(String value) => this._balance = value;
    set timestamp(String value) => this._timestamp = value;
    set signature(String value) => this._signature = value;
    set datecreated(String value) => this._datecreated = value;

    // Convert a Balance object into a Map object
    Map<String, dynamic> toMap() {
      var map = Map<String, dynamic>();
      if (id != null) {
        map['id'] = _id;
      }
      map['account'] = _account;
      map['balance'] = _balance;
      map['timestamp'] = _timestamp;
      map['signature'] = _signature;
      map['datecreated'] = _datecreated;
      return map;
    }

    // Extract a Balance object from a Map object
    Balance.fromMapObject(Map<String, dynamic> map) {
      this._id = map['id'];
      this._account = map['account'];
      this._balance = map['title'];
      this._timestamp = map['description'];
      this._signature = map['priority'];
      this._datecreated = map['datecreated'];
    }
}