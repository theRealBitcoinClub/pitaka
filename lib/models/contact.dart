class Contact {
    int _id;
    String _firstname;
    String _lastname;
    String _mobilenumber;
    String _transferaccount;

    Contact(
        this._firstname,
        this._lastname,
        this._mobilenumber,
        this._transferaccount
    );

    Contact.withId(
        this._id,
        this._firstname,
        this._lastname,
        this._mobilenumber,
        this._transferaccount
    );


    // (Getters) This can be customized depending on your needs
    int get id => _id;
    String get firstName => _firstname;
    String get lastName => _lastname;
    String get mobileNumber => _mobilenumber;
    String get transferAccount => _transferaccount; 

    // (Setters) This can be customized depending on your needs
    set firstName(String value) => this._firstname = value;
    set lastName(String value) => this._lastname = value;
    set mobileNumber(String value) => this._mobilenumber = value;
    set transferAccount(String value) => this._transferaccount = value;
}