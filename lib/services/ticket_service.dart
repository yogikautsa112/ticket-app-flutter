import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String title;
  final String type;
  final double price;

  Ticket({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'type': type, 'price': price};
  }

  factory Ticket.fromMap(Map<String, dynamic> map, String id) {
    return Ticket(
      id: id,
      title: map['title']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Ticket>> getTickets() async {
    try {
      final querySnapshot = await _firestore.collection('tickets').get();
      return querySnapshot.docs
          .map((doc) => Ticket.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting tickets: $e');
      return [];
    }
  }
}
