import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart';
import 'package:rsa_cipher/rsa_cipher.dart';
import 'models/room.dart';
import 'models/message.dart';
import 'models/partial_message.dart';
import 'models/partial_room.dart';
import 'config/chat_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firebase_firestore;

class SecureMessaging {
  static SecureMessaging? _instance;

  SecureMessaging._internal()
      : _firebaseFirestore = firebase_firestore.FirebaseFirestore.instance;

  static SecureMessaging get instance {
    if (_instance == null) {
      throw Exception('SecureMessaging is not initialized');
    }
    return _instance!;
  }

  final firebase_firestore.FirebaseFirestore _firebaseFirestore;
  late final ChatConfig _chatConfig;
  late final Directory _directory;

  static Future<void> initialize({ChatConfig? chatConfig}) async {
    if (_instance != null) {
      throw Exception('SecureMessaging is already initialized');
    }

    _instance = SecureMessaging._internal();
    _instance!._directory = await getApplicationDocumentsDirectory();

    _instance!._chatConfig = chatConfig ?? ChatConfig();
  }

  Future<String> createRoom(PartialRoom partialRoom) async {
    Map<String, dynamic> map = Room.fromPartial(partialRoom).toMap();
    map.remove('id');
    map['createdAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());
    map['updatedAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());

    final keyPair = RsaCipher().generateKeyPair();

    map['publicKey'] = RsaCipher().keyToPem(keyPair.publicKey);
    firebase_firestore.DocumentReference docRef = await _firebaseFirestore
        .collection(_chatConfig.roomCollectionName)
        .add(map);
    RsaCipher().storeKeyToFile<RSAPrivateKey>(
      filePath: "${_directory.path}/${docRef.id}_private.pem",
      key: keyPair.privateKey,
    );
    return docRef.id;
  }

  Stream<List<Room>> rooms(String roomId) {
    return _firebaseFirestore
        .collection(_chatConfig.roomCollectionName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var map = doc.data();
        map['id'] = doc.id;
        map['createdAt'] = map['createdAt'].millisecondsSinceEpoch;
        map['updatedAt'] = map['updatedAt'].millisecondsSinceEpoch;
        return Room.fromMap(map);
      }).toList();
    });
  }

  Stream<Room> room(String roomId) {
    return _firebaseFirestore
        .collection(_chatConfig.roomCollectionName)
        .doc(roomId)
        .snapshots()
        .map((snapshot) {
      var data = snapshot.data()!;
      return Room.fromMap(data);
    });
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

  Stream<List<Message>> messages({
    required String roomId,
  }) {
    final privateKey = RsaCipher().retrieveKeyFromFile<RSAPrivateKey>(
        "${_directory.path}/${roomId}_private.pem");
    if (privateKey == null) {
      throw Exception("error");
    }
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
        final type = MessageType.values.firstWhere(
          (e) => e.name == map['type'],
        );
        switch (type) {
          case MessageType.text:
            map['text'] = RsaCipher().decrypt(map['text'], privateKey);
        }
        return Message.fromMap(map);
      }).toList();
    });
  }

  Future<String> sendMessage({
    required PartialMessage partialMessage,
    required String roomId,
    required String publicKey,
  }) async {
    final map = Message.fromPartial(partialMessage).toMap();
    map.remove('id');
    map['createdAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());
    map['updatedAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());
    switch (partialMessage.type) {
      case MessageType.text:
        map['text'] = RsaCipher().encrypt(
          plaintext: map['text'],
          publicKey: RsaCipher().keyFromPem<RSAPublicKey>(publicKey),
        );
    }
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
    required String publicKey,
  }) async {
    final map = Message.fromPartial(partialMessage).toMap();
    map.remove('id');
    map.remove('createdAt');
    map['updatedAt'] = firebase_firestore.Timestamp.fromDate(DateTime.now());

    switch (partialMessage.type) {
      case MessageType.text:
        map['text'] = RsaCipher().encrypt(
          plaintext: map['text'],
          publicKey: RsaCipher().keyFromPem<RSAPublicKey>(publicKey),
        );
    }
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
