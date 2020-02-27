import 'package:flutter/material.dart';
import '../views/app.dart';
import 'package:shared_preferences/shared_preferences.dart';


ListView buildContactList(contacts) {
  return ListView.builder(
    itemCount: contacts.length,
    itemBuilder: (BuildContext context, int index) {
      return GestureDetector(
        onTap: () async {
          // Get the value of transferAccount and assign to variable _accountId
          var _accountId = contacts[index].transferAccount;
          
          // Store the value in shared preferences
          // This will be used in sendContact page as destinationAccountId
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('transferAccountId', _accountId);
          
          // Navigate to sendcontact page
          Application.router.navigateTo(context, "/sendcontact");
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.red,
                child: Text(contacts[index].firstName[0],
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  )
                ),
              )
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(8.0, 1.0, 12.0, 4.0),
                  child: Text(
                    "${contacts[index].firstName}" + ' ' + "${contacts[index].lastName}",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                  child: Text(
                    "${contacts[index].mobileNumber}",
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(8.0, 1.0, 12.0, 4.0),
                  child: Icon(
                    Icons.send,
                    size: 25.0,
                    color: Colors.red,
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
  );
}
