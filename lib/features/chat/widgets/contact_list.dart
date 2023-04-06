
import 'package:chat_app/colors.dart';
import 'package:chat_app/common/widgets/loader.dart';
import 'package:chat_app/features/chat/controller/chat_controller.dart';
import 'package:chat_app/info.dart';
import 'package:chat_app/features/chat/screens/chat_screen.dart';
import 'package:chat_app/models/chat_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ContactList extends ConsumerWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Expanded(
        child: StreamBuilder<List<ChatContact>>(
            stream: ref.watch(chatControllerProvider).chatContacts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var chatContactData = snapshot.data![index];

                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, ChatScreen.routeName,
                          arguments: {
                            'name': chatContactData.name,
                            'uid': chatContactData.contactId
                          });
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(
                              chatContactData.name,
                              style: const TextStyle(fontSize: 18),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                chatContactData.lastMessage,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                chatContactData.profilePic,
                              ),
                            ),
                            trailing: Text(
                              DateFormat.Hm().format(chatContactData.timeSent),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ),
                        ),
                        const Divider(
                          color: dividerColor,
                          indent: 85,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}
