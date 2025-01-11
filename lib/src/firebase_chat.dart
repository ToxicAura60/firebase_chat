import 'models/room.dart';
import 'models/message.dart';
import 'models/partial_message.dart';
import 'models/partial_room.dart';
import 'config/chat_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firebase_firestore;

class Chat {
  Chat._internal()
      : _firebaseFirestore = firebase_firestore.FirebaseFirestore.instance,
        _chatConfig = ChatConfig();

  static final Chat instance = Chat._internal();

  ChatConfig _chatConfig;

  static void config({required ChatConfig chatConfig}) {
    instance._chatConfig = chatConfig;
  }

  final firebase_firestore.FirebaseFirestore _firebaseFirestore;

  Future<void> createRoom(PartialRoom partialRoom) async {
    Map<String, dynamic> map = Room.fromPartial(partialRoom).toMap();
    map.remove('id');
    map['createdAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());
    map['updatedAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());
    _firebaseFirestore.collection(_chatConfig.roomCollectionName).add(map);
  }

  Future<void> updateRoom({
    required PartialRoom partialRoom,
    required String roomId,
  }) async {
    Map<String, dynamic> map = Room.fromPartial(partialRoom).toMap();
    map.remove('id');
    map.remove('createdAt');
    map['updatedAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());
    _firebaseFirestore
        .collection(_chatConfig.roomCollectionName)
        .doc(roomId)
        .update(map);
  }

  Future<void> deleteRoom(String roomId) async {
    _firebaseFirestore
        .collection(_chatConfig.roomCollectionName)
        .doc(roomId)
        .delete();
  }

  Stream<List<Message>> fetchMessages(String roomId) {
    return _firebaseFirestore
        .collection(_chatConfig.roomCollectionName)
        .doc(roomId)
        .collection(_chatConfig.messageCollectionName)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var map = doc.data();
        map['id'] = doc.id;
        map['createdAt'] = map['createdAt'].millisecondsSinceEpoch;
        map['updatedAt'] = map['updatedAt'].millisecondsSinceEpoch;
        return Message.fromMap(map);
      }).toList();
    });
  }

  Future<String> sendMessage({
    required PartialMessage partialMessage,
    required String roomId,
  }) async {
    final map = Message.fromPartial(partialMessage).toMap();
    map.remove('id');
    map['createdAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());
    map['updatedAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());
    final docRef = await _firebaseFirestore
        .collection(_chatConfig.roomCollectionName)
        .doc(roomId)
        .collection(_chatConfig.messageCollectionName)
        .add(map);
    return docRef.id;
  }

  Future<void> editMessage({
    required PartialMessage partialMessage,
    required String roomId,
    required String messageId,
  }) async {
    final map = Message.fromPartial(partialMessage).toMap();
    map.remove('id');
    map.remove('createdAt');
    map['updatedAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());
    await _firebaseFirestore
        .collection(_chatConfig.roomCollectionName)
        .doc(roomId)
        .collection(_chatConfig.messageCollectionName)
        .doc(messageId)
        .update(map);
  }

  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {
    await _firebaseFirestore
        .collection(_chatConfig.roomCollectionName)
        .doc(roomId)
        .collection(_chatConfig.messageCollectionName)
        .doc(messageId)
        .delete();
  }
}
