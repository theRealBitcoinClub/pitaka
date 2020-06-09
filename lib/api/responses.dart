import 'package:dio/dio.dart';
import 'package:intl/intl.dart';


class GenericCreateResponse {
  final bool success;
  final String id;
  final String error; // Added to catch error in duplicate email address

  GenericCreateResponse({this.success, this.id, this.error});

  factory GenericCreateResponse.fromResponse(Response response) {
    return GenericCreateResponse(
      success: response.data['success'],
      id: response.data['id'],
      error: response.data['error'], // Added to catch error in duplicate email address
    );
  }
}


class PlainSuccessResponse {
  final bool success;
  final String error;

  PlainSuccessResponse({this.success, this.error});

  factory PlainSuccessResponse.fromResponse(Response response) {
    return PlainSuccessResponse(success: response.data['success'], error: response.data['error']);
  }

  factory PlainSuccessResponse.invalidDeviceIdError(Response response) {
    return PlainSuccessResponse(success: response.data['success'], error: response.data['error']);
  }

  factory PlainSuccessResponse.toDatabase(){
    return PlainSuccessResponse(success: true, error: '');
  }

  // Added this response for connect timeout error in transferAsset() in endpoints.dart
  factory PlainSuccessResponse.connectTimeoutError(){
    return PlainSuccessResponse(success: false, error: 'DioErrorType.CONNECT_TIMEOUT');
  }
}


class User {
  String id;
  String firstName;
  String lastName;
  String mobileNumber;
  String email;
  String birthday;
  String deviceID;
  String firebaseToken;
  int level;
}

class RestoreAccountResponse {
  final bool success;
  final String error;
  var user = Map();
 
  RestoreAccountResponse({
    this.success, 
    this.error, 
    this.user,
  });

  factory RestoreAccountResponse.fromResponse(Response response) {
    var _user = Map();
    if (response.data['user_info'] != null) {
      var user = response.data['user_info'];
      _user['id'] = user['ID'];
      _user['firstName'] = user['Firstname'];
      _user['lastName'] = user['Lastname'];
      _user['mobileNumber'] = user['MobileNumber'];
      _user['email'] = user['Email'];
      _user['birthday'] = user['Birthday'];
      _user['deviceID'] = user['DeviceID'];
      _user['firebaseToken'] = user['FirebaseToken'];
      _user['level'] = user['Level'];
    }
    return RestoreAccountResponse(
      success: response.data['success'], 
      error: response.data['error'], 
      user: _user,
    );
  }
}


class RequestOTPAccountRestoreResponse {
  final bool success;
  final String error;
  final String mobileNumber;
 
  RequestOTPAccountRestoreResponse({
    this.success, 
    this.error, 
    this.mobileNumber,
  });

  factory RequestOTPAccountRestoreResponse.fromResponse(Response response) {
    return RequestOTPAccountRestoreResponse(
      success: response.data['success'], 
      error: response.data['error'], 
      mobileNumber: response.data['mobile_number'],
    );
  }
}


class OtpVerificationResponse {
  final bool success;
  final bool verified;
  final String error;

  OtpVerificationResponse({this.success, this.verified, this.error});

  factory OtpVerificationResponse.fromResponse(Response response) {
    return OtpVerificationResponse(
      success: response.data['success'], 
      verified: response.data['verified'], 
      error: ''
    );
  }
}


class Balance {
  String accountName;
  String accountId;
  String timestamp;
  String signature;
  double balance;
  String date;
}

class BalancesResponse {
  final bool success;
  final List<Balance> balances;
  final String error;

  BalancesResponse({this.success, this.balances, this.error});

  factory BalancesResponse.fromResponse(Response response) {
    List<Balance> _balances = [];
    if (response.data['balances'] != null) {
      for (final bal in response.data['balances']) {
        var balanceObj = new Balance();
        balanceObj.accountName = bal['AccountName'];
        double balance = bal['Balance'].toDouble();
        balanceObj.balance = balance;
        balanceObj.accountId = bal['AccountID'];
        balanceObj.timestamp = response.data['timestamp'].toString();
        balanceObj.signature = bal['Signature'];
        _balances.add(balanceObj);
      }
    }
    return BalancesResponse(
      success: response.data['success'], balances: _balances, error: ''
    );
  }

  factory BalancesResponse.fromDatabase(List accounts) {
    List<Balance> _balances = [];
    for (final account in accounts) {
      var balanceObj = new Balance();
      balanceObj.accountName = account['accountName'];
      var balance = double.tryParse(account['balance']);
      balanceObj.balance = balance;
      balanceObj.accountId = account['accountId'];
      balanceObj.timestamp = account['timestamp'];
      balanceObj.signature = account['signature'];
      balanceObj.date = account['datetime'];
      _balances.add(balanceObj);
    }
    return BalancesResponse(
      success: true, balances: _balances, error: ''
    );
  }

  // Added this response for connect timeout error
  factory BalancesResponse.connectTimeoutError(List accounts) {
    List<Balance> _balances = [];
    for (final account in accounts) {
      var balanceObj = new Balance();
      balanceObj.accountName = account['accountName'];
      var balance = double.tryParse(account['balance']);
      balanceObj.balance = balance;
      balanceObj.accountId = account['accountId'];
      balanceObj.timestamp = account['timestamp'];
      balanceObj.signature = account['signature'];
      balanceObj.date = account['datetime'];
      _balances.add(balanceObj);
    }
    return BalancesResponse(
      success: false, balances: _balances, error: 'connect_timeout'
    );
  }

  // Added this response for unauthorized error
  factory BalancesResponse.unauthorizedError(List accounts) {
    List<Balance> _balances = [];
    for (final account in accounts) {
      var balanceObj = new Balance();
      balanceObj.accountName = account['accountName'];
      var balance = double.tryParse(account['balance']);
      balanceObj.balance = balance;
      balanceObj.accountId = account['accountId'];
      balanceObj.timestamp = account['timestamp'];
      balanceObj.signature = account['signature'];
      balanceObj.date = account['datetime'];
      _balances.add(balanceObj);
    }
    return BalancesResponse(
      success: false, balances: _balances, error: 'unauthorized'
    );
  }

  factory BalancesResponse.invalidDeviceIdError(Response response) {
    List<Balance> _balances = [];
    if (response.data['balances'] != null) {
      for (final bal in response.data['balances']) {
        var balanceObj = new Balance();
        balanceObj.accountName = bal['AccountName'];
        double balance = bal['Balance'].toDouble();
        balanceObj.balance = balance;
        balanceObj.accountId = bal['AccountID'];
        balanceObj.timestamp = response.data['timestamp'].toString();
        balanceObj.signature = bal['Signature'];
        _balances.add(balanceObj);
      }
    }
    return BalancesResponse(
      success: response.data['success'], balances: _balances, error: 'invalid_device_id'
    );
  }
}


class Contact {
  String firstName;
  String lastName;
  String mobileNumber;
  String email;
  String transferAccount; 
}

class ContactResponse {
  final bool success;
  final String error;
  var contact = Map();

  ContactResponse({
    this.success, 
    this.error, 
    this.contact
  });

  factory ContactResponse.fromResponse(Response response) {
    var _contact = Map();
    if (response.data['user_info'] != null) {
      var cont = response.data['user_info'];
      _contact['firstName'] = cont['Firstname'];
      _contact['lastName'] = cont['Lastname'];
      _contact['mobileNumber'] = cont['MobileNumber'];
      _contact['email'] = cont['Email'];
      _contact['transferAccount'] = cont['TransferAccount']['ID'];
    }
    return ContactResponse(
      success: response.data['success'], 
      error: '',
      contact: _contact
    );
  }

  factory ContactResponse.duplicateContact(Response response) {
    var _contact = Map();
    if (response.data['user_info'] != null) {
      var cont = response.data['user_info'];
      _contact['firstName'] = cont['Firstname'];
      _contact['lastName'] = cont['Lastname'];
      _contact['mobileNumber'] = cont['MobileNumber'];
      _contact['email'] = cont['Email'];
      _contact['transferAccount'] = cont['TransferAccounts'][0]['ID'];
    }
    return ContactResponse(
      success: false, 
      contact: _contact, 
      error: 'This contact is already in your list.'
    );
  }

  factory ContactResponse.unregisteredMobileNumber(Response response) {
    var _contact = Map();
    if (response.data['user_info'] != null) {
      var cont = response.data['user_info'];
      _contact['firstName'] = cont['Firstname'];
      _contact['lastName'] = cont['Lastname'];
      _contact['mobileNumber'] = cont['MobileNumber'];
      _contact['email'] = cont['Email'];
      _contact['transferAccount'] = cont['TransferAccounts'][0]['ID'];
    }
    return ContactResponse(
      success: false, 
      contact: _contact, 
      error: 'Unregistered mobile number!'
    );
  }

  factory ContactResponse.connectTimeoutError(){
    return ContactResponse(
      success: false, 
      error: "You don't seem to have internet connection, or it's too slow. " 
    );
  }
}


class CreateContact {
  String id;
  String firstName;
  String lastName;
  String mobileNumber;
  String email;
  String transferAccount; 
}

class CreateContactResponse {
  final bool success;
  final String error;
  var contact = Map();

  CreateContactResponse({
    this.success, 
    this.error, 
    this.contact
  });

  factory CreateContactResponse.fromResponse(Response response) {
    var _contact = Map();
    if (response.data['contact_info'] != null) {
      var cont = response.data['contact_info'];
      _contact['id'] = cont['ID'];
      _contact['firstName'] = cont['Firstname'];
      _contact['lastName'] = cont['Lastname'];
      _contact['mobileNumber'] = cont['MobileNumber'];
      _contact['email'] = cont['Email'];
      _contact['transferAccount'] = cont['TransferAccount']['ID'];
    }
    return CreateContactResponse(
      success: response.data['success'], 
      error: '',
      contact: _contact
    );
  }

  factory CreateContactResponse.duplicateContact(Response response) {
    var _contact = Map();
    if (response.data['contact_info'] != null) {
      var cont = response.data['contact_info'];
      _contact['id'] = cont['ID'];
      _contact['firstName'] = cont['Firstname'];
      _contact['lastName'] = cont['Lastname'];
      _contact['mobileNumber'] = cont['MobileNumber'];
      _contact['email'] = cont['Email'];
      _contact['transferAccount'] = cont['TransferAccounts'][0]['ID'];
    }
    return CreateContactResponse(
      success: false, 
      contact: _contact, 
      error: 'This contact is already in your list.'
    );
  }

  factory CreateContactResponse.unregisteredMobileNumber(Response response) {
    var _contact = Map();
    if (response.data['contact_info'] != null) {
      var cont = response.data['contact_info'];
      _contact['id'] = cont['ID'];
      _contact['firstName'] = cont['Firstname'];
      _contact['lastName'] = cont['Lastname'];
      _contact['mobileNumber'] = cont['MobileNumber'];
      _contact['email'] = cont['Email'];
      _contact['transferAccount'] = cont['TransferAccounts'][0]['ID'];
    }
    return CreateContactResponse(
      success: false, 
      contact: _contact, 
      error: 'Unregistered mobile number!'
    );
  }

  factory CreateContactResponse.connectTimeoutError(){
    return CreateContactResponse(
      success: false, 
      error: "You don't seem to have internet connection, or it's too slow. " 
    );
  }
}


class ContactList {
  String firstName;
  String lastName;
  String mobileNumber;
  String transferAccount; 
}

class ContactListResponse {
  final bool success;
  final List<Contact> contacts;
  final String error;

  ContactListResponse({this.success, this.contacts, this.error});

  factory ContactListResponse.fromDatabase(List contactsList) {
    List<Contact> _contacts = [];
    for (final contact in contactsList) {
      var contactObj = new Contact();
      contactObj.firstName = contact['firstName'];
      contactObj.lastName = contact['lastName'];
      contactObj.mobileNumber = contact['mobileNumber'];
      contactObj.transferAccount = contact['transferAccount'];
      _contacts.add(contactObj);
    }

    return ContactListResponse(
      success: true, contacts: _contacts, error: ''
    );
  }
}


class Transaction {
  String mode; // send or receive
  double amount;
  String accountID;
  String timestamp;
  DateTime timeslot;
  String time;
  String txnID;
  String paymentProof;
}

class TransactionsResponse {
  final bool success;
  final List<Transaction> transactions;
  final String error;

  TransactionsResponse({this.success, this.transactions, this.error});

   factory TransactionsResponse.fromResponse(Response response) {
    List<Transaction> _transactions = [];
    if (response.data['transactions'] != null) {
        for (final txn in response.data['transactions']) {
          var transObj = new Transaction();
          transObj.mode = txn['Mode'];
          transObj.amount = txn['Amount'].toDouble();
          transObj.accountID = txn['AccountID'];
          transObj.timestamp = txn['Timestamp'].toString();
          transObj.timeslot = DateTime.tryParse(transObj.timestamp).toLocal();
          transObj.time = DateFormat('y/M/d hh:mm a').format(transObj.timeslot).toString();
          transObj.txnID = txn['TransactionID'];
          transObj.paymentProof = txn['ProofOfPayment'];
          _transactions.add(transObj);
        }
      }
    return TransactionsResponse(
      success: response.data['success'], transactions: _transactions);
  }

   factory TransactionsResponse.invalidDeviceIdError(Response response) {
    List<Transaction> _transactions = [];
    if (response.data['transactions'] != null) {
        for (final txn in response.data['transactions']) {
          var transObj = new Transaction();
          transObj.mode = txn['Mode'];
          transObj.amount = txn['Amount'].toDouble();
          transObj.accountID = txn['AccountID'];
          transObj.timestamp = txn['Timestamp'].toString();
          transObj.timeslot = DateTime.tryParse(transObj.timestamp).toLocal();
          transObj.time = DateFormat('y/M/d hh:mm a').format(transObj.timeslot).toString();
          transObj.txnID = txn['TransactionID'];
          transObj.paymentProof = txn['ProofOfPayment'];
          _transactions.add(transObj);
        }
      }
    return TransactionsResponse(
      success: response.data['success'], transactions: _transactions, error: 'invalid_device_id'
    );
  }

  factory TransactionsResponse.fromDatabase(List transactions) {
    List<Transaction> _trans = [];
    for (final txn in transactions) {
      var transObj = new Transaction();
      transObj.mode = txn['mode'];
      transObj.amount = txn['amount'].toDouble();
      transObj.timestamp = txn['timestamp'].toString();
     //transObj.timeslot = DateTime.tryParse(transObj.timestamp).toLocal();
      transObj.txnID = txn['txnID'];
      transObj.time = txn['time'];
      transObj.paymentProof = txn['paymentProof'];
      _trans.add(transObj);
    }
    return TransactionsResponse(
      success: true, transactions: _trans);
  }

  // Added this response for connect timeout error
  factory TransactionsResponse.connectTimeoutError(List transactions) {
    List<Transaction> _trans = [];
    for (final txn in transactions) {
      var transObj = new Transaction();
      transObj.mode = txn['mode'];
      transObj.amount = txn['amount'].toDouble();
      transObj.timestamp = txn['timestamp'].toString();
     transObj.timeslot = DateTime.tryParse(transObj.timestamp).toLocal();
      transObj.txnID = txn['txnID'];
      transObj.time = txn['time'];
      transObj.paymentProof = txn['paymentProof'];
      _trans.add(transObj);
    }
    return TransactionsResponse(
      success: false, transactions: _trans, error: 'connect_timeout'
    );
  }

  // Added this response for unauthorized error
  factory TransactionsResponse.unauthorizedError(List transactions) {
    List<Transaction> _trans = [];
    for (final txn in transactions) {
      var transObj = new Transaction();
      transObj.mode = txn['mode'];
      transObj.amount = txn['amount'].toDouble();
      transObj.timestamp = txn['timestamp'].toString();
     transObj.timeslot = DateTime.tryParse(transObj.timestamp).toLocal();
      transObj.txnID = txn['txnID'];
      transObj.time = txn['time'];
      transObj.paymentProof = txn['paymentProof'];
      _trans.add(transObj);
    }
    return TransactionsResponse(
      success: false, transactions: _trans, error: 'unauthorized'
    );
  }
}


class Account {
  String accountName;
  String accountId;
  String balance;
}

class AccountsResponse {
  final bool success;
  final List<Account> accounts;

  AccountsResponse({this.success, this.accounts});

  factory AccountsResponse.fromResponse(Response response) {
    List<Account> _accounts = [];
    if (response.data['accounts'] != null) {
      for (final bal in response.data['accounts']) {
        var accountObj = new Account();
        accountObj.accountName = bal['Name'];
        accountObj.accountId = bal['ID'];
        _accounts.add(accountObj);
      }
    }
    return AccountsResponse(
        success: response.data['success'], accounts: _accounts);
  }
}


String test() {
  var now = new DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd hh:mm a ');
  String formatted = formatter.format(now);
  print(formatted);
  return formatted;
}
