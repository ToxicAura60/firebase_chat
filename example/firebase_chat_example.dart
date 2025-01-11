import 'package:firebase_chat/firebase_chat.dart';

void main() async {
  // create room
  await Chat.instance
      .createRoom(PartialRoom(name: 'user', userIds: ['user_01', 'user_02']));

  // update room
  await Chat.instance.updateRoom(
      partialRoom: PartialRoom(name: 'user', userIds: ['user_01', 'user_02']),
      roomId: 'room_01');

  // delete room
  await Chat.instance.deleteRoom('room_01');

  // send message
  await Chat.instance.sendMessage(
    partialMessage: PartialText(authorId: 'user_01', text: 'Hello World!'),
    roomId: 'room_01',
  );

  // edit message
  await Chat.instance.editMessage(
      partialMessage: PartialText(authorId: 'user_01', text: 'Hello World!'),
      roomId: 'room_01',
      messageId: 'message_01');

  // delete message
  await Chat.instance.deleteMessage(roomId: 'room_01', messageId: 'message_01');
}
