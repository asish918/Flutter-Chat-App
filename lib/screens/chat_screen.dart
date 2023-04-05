// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chat_app/common/widgets/loader.dart';
import 'package:chat_app/features/auth/controller/auth_controller.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/colors.dart';
import 'package:chat_app/components/chat_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerWidget {
  static const String routeName = '/chat-screen';
  final String name;
  final String uid;
  const ChatScreen({
    Key? key,
    required this.name,
    required this.uid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: StreamBuilder<UserModel>(
            stream: ref.read(authControllerProvider).userDataById(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name),
                  Text(
                    snapshot.data!.isOnline ? 'Online' : 'Offline',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                ],
              );
            }),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(
            child: ChatList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  filled: true,
                  fillColor: mobileChatBoxColor,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      Icons.emoji_emotions,
                      color: Colors.grey,
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                        ),
                        Icon(
                          Icons.attach_file,
                          color: Colors.grey,
                        ),
                        Icon(
                          Icons.money,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(width: 0, style: BorderStyle.none),
                  ),
                  contentPadding: const EdgeInsets.all(10)),
            ),
          ),
        ],
      ),
    );
  }
}
