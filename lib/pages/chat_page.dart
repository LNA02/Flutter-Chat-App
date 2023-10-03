import 'package:chat_app/pages/group_info.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/message_tile.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../widgets/image_message_tile.dart';



class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  

  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);
      
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  File? imageFile; // Define imageFile variable

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[
          // chat messages here
          chatMessages(),
          
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(                
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),

                GestureDetector(
                  onTap: () {
                    pickAndSendImage();// Call the sendImage function to send an image
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.send,
                      color: Colors.white,
                    )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  String message = snapshot.data.docs[index]['message'];
                  String sender = snapshot.data.docs[index]['sender'];
                  bool sentByMe = widget.userName == sender;
                  // String groupId = snapshot.data.docs[index]['groupId'];
                  // String time = snapshot.data.docs[index]['time'];
                  // Check if the message is an image
                  if (message.startsWith('https://')) {
                    return ImageMessageTile(
                        imageUrl: message, sender: sender, sentByMe: sentByMe);
                  } else {
                    return MessageTile(
                        message: message, sender: sender, sentByMe: sentByMe);
                  }
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }


  pickAndSendImage() async {
    // Open image picker
    final picker = ImagePicker();
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      String imageUrl = await uploadImageToFirebaseStorage(image); // Upload image to Firebase Storage
      if (imageUrl.isNotEmpty) {
        // Create a chat message map with the image URL
        Map<String, dynamic> chatMessageMap = {
          "message": imageUrl,
          "sender": widget.userName,
          "time": DateTime.now().millisecondsSinceEpoch,
        };

        DatabaseService().sendMessage(widget.groupId, chatMessageMap); // Send the chat message to Firebase Firestore
      }
    }
  }

  uploadImageToFirebaseStorage(File image) async {
    String imageName = const Uuid().v4(); // Generate a unique image name
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child("images/$imageName"); // Create a reference to the image in Firebase Storage
    UploadTask uploadTask = reference.putFile(image); // Upload the image file to Firebase Storage
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null); // Wait for the upload to complete
    String imageUrl = await taskSnapshot.ref.getDownloadURL(); // Get the download URL of the uploaded image
    return imageUrl;
  }

}
