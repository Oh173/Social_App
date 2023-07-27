import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp){
  // timeStamp is the object that i retrieve from firebase
  // so to display it (must convert it to string )

  DateTime dateTime = timestamp.toDate();

  //get year
  String year = dateTime.year.toString();

  //get day
  String day = dateTime.day.toString();

  //get month
  String month = dateTime.month.toString();

  String formattedData = '$day/$month/$year';

  return formattedData;

}