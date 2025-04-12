import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kri_dhan/main.dart';
import 'package:kri_dhan/models/chat_user.dart';
import 'package:kri_dhan/screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      //color: Colors.blue.shade100,
      elevation: 0.4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user,)));
        },
        child:  ListTile(
          
          //leading: const CircleAvatar(child: Icon(CupertinoIcons.person),),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .3),
            child: CachedNetworkImage(
              width: mq.height * .055,
              height: mq.height * .055,
                    imageUrl: widget.user.image ?? 'https://example.com/default-image.png',
                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person),),
                 ),
          ),
          title: Text(widget.user.name ?? 'Unknown Name'),
subtitle: Text(widget.user.about ?? 'No details available', maxLines: 1),

          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(color: Colors.greenAccent.shade400,borderRadius: BorderRadius.circular(10)),
          ),

          //trailing: Text("12:00 PM",
          //style: TextStyle(color: Colors.black54),),
        ),
      ),
    );
  }
}