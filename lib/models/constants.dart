import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

final CollectionReference userCollections = db.collection('stalls');
