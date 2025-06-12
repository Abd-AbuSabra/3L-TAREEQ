import 'package:flutter/material.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_33/service_provider/dashboard_SP.dart';

// Add the missing Firestore instance
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<bool> moveToHistory(String userId) async {
  try {
    // Start a batch write to ensure atomicity
    WriteBatch batch = _firestore.batch();

    // Query the acceptedProviders collection for the document with matching userId
    QuerySnapshot acceptedProvidersQuery = await _firestore
        .collection('acceptedProviders')
        .where('providerId', isEqualTo: userId)
        .get();

    if (acceptedProvidersQuery.docs.isEmpty) {
      print('No document found with userId: $userId');
      return false;
    }

    // Get the first matching document
    QueryDocumentSnapshot docToMove = acceptedProvidersQuery.docs.first;
    Map<String, dynamic> docData = docToMove.data() as Map<String, dynamic>;

    // Add timestamp for when it was moved to history
    docData['movedToHistoryAt'] = FieldValue.serverTimestamp();
    docData['status'] = 'canceled'; // Optional: add status field

    // Add the document to history collection
    DocumentReference historyRef = _firestore.collection('history').doc();
    batch.set(historyRef, docData);

    // Delete the document from acceptedProviders collection
    batch.delete(docToMove.reference);

    // Commit the batch
    await batch.commit();

    print('Successfully moved document to history for userId: $userId');
    return true;
  } catch (e) {
    print('Error moving document to history: $e');
    return false;
  }
}

// Updated dialog function that calls moveToHistory
void showCancelDialog_SP(BuildContext context, String userId) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 300,
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Are you sure you want to\ncancel this service ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 73, 73, 73),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(
                        color: Color.fromARGB(255, 73, 73, 73),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      bool success = await moveToHistory(userId);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dashboard_SP(),
                        ),
                      );

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Service canceled successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
