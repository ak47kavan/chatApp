import 'package:flutter/material.dart';
import 'package:kri_dhan/api/apis.dart';
import 'package:kri_dhan/main.dart';
import 'package:kri_dhan/models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.messsage});

  final Message messsage;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.messsage.fromId ? _greenMessage() : _blueMessage();
  }

  Widget _blueMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: mq.height * .01),
            // ...existing code...
          decoration: BoxDecoration(color:const Color.fromARGB(255, 98, 212, 216),
          border: Border.all(color: Color.fromARGB(255, 0, 115, 119)),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30)),),
          // ...existing code...
            child: Text(widget.messsage.msg,
            style: const TextStyle(fontSize: 15,color: Colors.black87),),
          ),
        ),

        Padding(
          padding:  EdgeInsets.only(right: mq.width * .04),
          child: Text(widget.messsage.sent,style: const TextStyle(fontSize:13,color: Colors.black54 )),
        ),

        
      ],
    );
  }

  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        

        Row(
          children: [
            SizedBox(width: mq.width * .04),
            const Icon(Icons.done_all,color: Colors.blue,size: 20,),
            SizedBox(width: 2),
            Text('${widget.messsage.read}12:00 AM',style: const TextStyle(fontSize:13,color: Colors.black54 )),
          ],
        ),

        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: mq.height * .01),
            // ...existing code...
          decoration: BoxDecoration(color:const Color.fromARGB(255, 218,255,176),
          border: Border.all(color: Colors.lightGreen),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30)),),
          // ...existing code...
            child: Text(widget.messsage.msg,
            style: const TextStyle(fontSize: 15,color: Colors.black87),),
          ),
        ),

        
      ],
    );
  }
}