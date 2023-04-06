// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/common/enums/message_enum.dart';

class DisplayMessageContent extends StatelessWidget {
  final String message;
  final MessageEnum type;
  const DisplayMessageContent({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return type == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(fontSize: 16),
          )
        : type == MessageEnum.gif
            ? CachedNetworkImage(imageUrl: message)
            : CachedNetworkImage(imageUrl: message);
  }
}
