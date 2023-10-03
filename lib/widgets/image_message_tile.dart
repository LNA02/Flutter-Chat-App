import 'package:flutter/material.dart';

class ImageMessageTile extends StatefulWidget {
  final String sender;
  final bool sentByMe;
  final String imageUrl; // new parameter for image URL

  const ImageMessageTile(
      {Key? key,
      required this.sender,
      required this.sentByMe,
      required this.imageUrl}) // updated constructor
      : super(key: key);

  @override
  State<ImageMessageTile> createState() => _ImageMessageTileState();
}

class _ImageMessageTileState extends State<ImageMessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
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
                : Colors.grey[700]),
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
                  letterSpacing: -0.5),
            ),
            const SizedBox(
              height: 8,
            ),
            // Updated: Include Image widget for displaying image
            Image.network(
              widget.imageUrl,
              width: 200, // customize the width of the image
              height: 150, // customize the height of the image
            ),
            
          ],
        ),
      ),
    );
  }
}
