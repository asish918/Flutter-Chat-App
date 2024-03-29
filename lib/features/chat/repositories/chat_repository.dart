// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chat_app/common/enums/message_enum.dart';
import 'package:chat_app/common/providers/message_reply_provider.dart';
import 'package:chat_app/common/repositories/common_firebase_storage_repository.dart';
import 'package:chat_app/common/utils/utils.dart';
import 'package:chat_app/info.dart';
import 'package:chat_app/models/chat_contact.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository(
    firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];

      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData =
            await firestore.collection('user').doc(chatContact.contactId).get();
        var user = UserModel.fromMap(userData.data()!);
        contacts.add(ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage));
      }

      return contacts;
    });
  }

  Stream<List<Message>> getChatStream(String receiverUserId) {
    return firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }

      return messages;
    });
  }

  void _saveDataToContactSubcollection(
      UserModel senderUserData,
      UserModel receiverUserData,
      String text,
      DateTime timeSent,
      String receiverUserId) async {
    var receiverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text);

    var senderChatContact = ChatContact(
        name: receiverUserData.name,
        profilePic: receiverUserData.profilePic,
        contactId: receiverUserData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await firestore
        .collection('user')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(receiverChatContact.toMap());

    await firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .set(senderChatContact.toMap());
  }

  void _saveMessageToMessageSubcollection(
      {required String receiverUserId,
      required String text,
      required DateTime timeSent,
      required String messageId,
      required String username,
      required String receiverUsername,
      required MessageEnum messageType,
      required MessageReply? messageReply,
      required String senderUsername,
      required MessageEnum repliedMessageType}) async {
    final message = Message(
        senderId: auth.currentUser!.uid,
        receiverId: receiverUserId,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        isSeen: false,
        repliedTo: messageReply == null
            ? ''
            : messageReply.isMe
                ? senderUsername
                : receiverUsername,
        repliedMessage: messageReply == null ? '' : messageReply.message,
        repliedMessageType: repliedMessageType);

    await firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await firestore
        .collection('user')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;

      var userDataMap =
          await firestore.collection('user').doc(receiverUserId).get();

      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();

      _saveDataToContactSubcollection(
          senderUser, receiverUserData, text, timeSent, receiverUserId);

      _saveMessageToMessageSubcollection(
          receiverUserId: receiverUserId,
          text: text,
          timeSent: timeSent,
          messageType: MessageEnum.text,
          messageId: messageId,
          receiverUsername: receiverUserData.name,
          username: senderUser.name,
          messageReply: messageReply,
          senderUsername: senderUser.name,
          repliedMessageType: messageReply == null
              ? MessageEnum.text
              : messageReply.messageEnum);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage(
      {required BuildContext context,
      required File file,
      required String receiverUserId,
      required UserModel senderUserData,
      required ProviderRef ref,
      required MessageEnum messageEnum,
      required MessageReply? messageReply}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId',
              file);

      UserModel receiverUserData;
      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📸 Photo';
          break;

        case MessageEnum.video:
          contactMsg = '🎥 Video';
          break;

        case MessageEnum.audio:
          contactMsg = '🎶 Audio';
          break;

        case MessageEnum.gif:
          contactMsg = '📹 GIF';
          break;

        default:
          contactMsg = 'Invalid Data Type';
      }

      _saveDataToContactSubcollection(senderUserData, receiverUserData,
          contactMsg, timeSent, receiverUserId);

      _saveMessageToMessageSubcollection(
          receiverUserId: receiverUserId,
          text: imageUrl,
          timeSent: timeSent,
          messageId: messageId,
          username: senderUserData.name,
          receiverUsername: receiverUserData.name,
          messageType: messageEnum,
          messageReply: messageReply,
          senderUsername: senderUserData.name,
          repliedMessageType: messageReply == null
              ? MessageEnum.text
              : messageReply.messageEnum);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage(
      {required BuildContext context,
      required String gifUrl,
      required String receiverUserId,
      required UserModel senderUser,
      required MessageReply? messageReply}) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;

      var userDataMap =
          await firestore.collection('user').doc(receiverUserId).get();

      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();

      _saveDataToContactSubcollection(
          senderUser, receiverUserData, 'GIF', timeSent, receiverUserId);

      _saveMessageToMessageSubcollection(
          receiverUserId: receiverUserId,
          text: gifUrl,
          timeSent: timeSent,
          messageType: MessageEnum.gif,
          messageId: messageId,
          receiverUsername: receiverUserData.name,
          username: senderUser.name,
          messageReply: messageReply,
          senderUsername: senderUser.name,
          repliedMessageType: messageReply == null
              ? MessageEnum.text
              : messageReply.messageEnum);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
      BuildContext context, String receiverUserId, String messageId) async {
    try {
      await firestore
          .collection('user')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firestore
          .collection('user')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
