import 'package:secure_messaging/secure_messaging.dart';

void main() async {
  // create room
  await SecureMessaging.instance
      .createRoom(PartialRoom(name: 'user', userIds: ['user_01', 'user_02']));

  // update room
  await SecureMessaging.instance.updateRoom(
      partialRoom: PartialRoom(name: 'user', userIds: ['user_01', 'user_02']),
      roomId: 'room_01');

  // delete room
  await SecureMessaging.instance.deleteRoom('room_01');

  // send message
  await SecureMessaging.instance.sendMessage(
    publicKey: "-----BEGIN...",
    partialMessage: PartialText(authorId: 'user_01', text: 'Hello World!'),
    roomId: 'room_01',
  );

  // edit message
  await SecureMessaging.instance.editMessage(
      publicKey: "-----BEGIN...",
      partialMessage: PartialText(authorId: 'user_01', text: 'Hello World!'),
      roomId: 'room_01',
      messageId: 'message_01');

  // delete message
  await SecureMessaging.instance
      .deleteMessage(roomId: 'room_01', messageId: 'message_01');
}
