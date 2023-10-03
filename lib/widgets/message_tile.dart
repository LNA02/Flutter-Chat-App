import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;

  // final String groupId;
  // final String time;

  const MessageTile({
    Key? key,
    required this.message,
    required this.sender,
    required this.sentByMe,

    // required this.groupId,
    // required  this.time,
  }) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _isHolding = false;

  // void _deleteMessage() async {
  //   // Get the groupId and messageId of the message to be deleted
  //   String groupId = widget.groupId;
  //   String time = widget.time;

  //   try {
  //     // Get the reference to the group chat collection
  //     CollectionReference groupChatCollection =
  //         FirebaseFirestore.instance.collection('groups');

  //     // Get the reference to the specific group document
  //     DocumentReference groupDocument = groupChatCollection.doc(groupId);

  //     // Get the current messages map from the document
  //     DocumentSnapshot groupSnapshot = await groupDocument.get();
  //     Map<String, dynamic> messages = groupSnapshot.data()!;

  //     // Remove the message by time from the messages map
  //     messages.remove(time);

  //     // Update the document with the updated messages map
  //     await groupDocument.update({'messages': messages});

  //     print('Message deleted successfully');
  //   } catch (e) {
  //     print('Error deleting message: $e');
  //   }
  // }

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text('Want to delete?'),
          actions: <Widget>[
            FlatButton(
              child: Text('DELETE'),
              onPressed: (){
                setState(() {
                  // _deleteMessage();
                });
                Navigator.of(context).pop();
              }
              ),
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isHolding = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isHolding = false;
        });
        _showPopup();
      },
      child: Container(
        padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0,
        ),
        alignment: widget.sentByMe
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          margin: widget.sentByMe
              ? const EdgeInsets.only(left: 30)
              : const EdgeInsets.only(right: 30),
          padding: const EdgeInsets.only(
            top: 17,
            bottom: 17,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            borderRadius: widget.sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
            color: widget.sentByMe
                ? Theme.of(context).primaryColor
                : Colors.grey[700],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.sender.toUpperCase(),
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                widget.message,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
