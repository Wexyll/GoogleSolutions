import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

String userCol = "";

//Changes the item quantity
void updateItemAmount(String id, bool remove, int quantity, int increment) {
  //References the users database collection
  DocumentReference document = firestore.collection(userCol).doc(id);
  print(document);
  //Removes the item if the quantity is <= 1
  //Or if boolean = true
  if(remove || quantity <= 1) {
    document.delete();
  }else {
    //Checks if document exists and then increments the Quantity value
    document.get().then((doc) => {
      if(doc.exists) {
        document.update({"Quantity": FieldValue.increment(increment)})
        .catchError((error) {
          print(error);
        })
      }
    });
  }
}

//Adds an item to the databse
void addItemToDB(String itemName, String category, int amount, String expiryDate) {
  firestore.collection(userCol).add({
    'Category':  category,
    'ProductName': itemName,
    'Quantity': amount,
    "ExpiryDate": expiryDate
  });
}

//Removes all expired items
void removeExpired() async {
  //References the users database collection
  await firestore.collection(userCol).get().then((snapshot) {
    //Gets a list of all the documents
    List<DocumentSnapshot> allDocs = snapshot.docs;
    //Loops through the documents and deletes them if the expiry date is before today's date
    allDocs.forEach((DocumentSnapshot document) {
      DateTime date = DateTime.parse(document.get("ExpiryDate"));
      if(date.isBefore(DateTime.now())) {
        document.reference.delete();
      }
    });
  });
}