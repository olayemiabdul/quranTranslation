import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController messageController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  Future sendMessage(String text, String textMessage, String textEmail) async {
    if (formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('contact_messages').add({
          'message': messageController.text,
          'email':emailController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks! Message sent successfully!')),
        );
        messageController.clear();
        nameController.clear();
        emailController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: Center(
        child: Container(
          height: 450,
          width: 400,
          margin: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 20,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 20,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 5),
                    blurRadius: 10,
                    spreadRadius: 1,
                    color: Colors.grey[300]!)
              ]),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Contact Us',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins ExtraBold')),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Name',
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.purple,
                      )),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '*Required';
                    }
                    return null;
                  },
                ),
                TextFormField(


                  controller: emailController,

                  decoration: const InputDecoration(hintText: 'Email',
                      prefixIcon: const Icon(
                        Icons.mail,
                        color: Colors.purple,
                      )
                  ),
                  validator: (email) {
                    if (email == null || email.isEmpty) {
                      return 'Required*';
                    } else if (!EmailValidator.validate(email)) {
                      return 'Please enter a valid Email';
                    }
                    return null;
                  },

                ),
                TextFormField(
                  controller: messageController,
                  decoration:  InputDecoration(hintText: 'Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFF000000),
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      fillColor: Colors.purple.withOpacity(0.2),
                      filled: false,
                      prefixIcon: const Icon(
                        Icons.message,
                        color: Colors.purple,
                      )),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '*Required';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 45,
                  width: 110,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: const Color(0xff151534),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40))),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final response = await sendMessage(
                            nameController.value.text,
                            emailController.value.text,
                            messageController.value.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          response == 200
                              ? const SnackBar(
                              content: Text('Message Sent!'),
                              backgroundColor: Colors.green)
                              : const SnackBar(
                              content: Text('Failed to send message!'),
                              backgroundColor: Colors.red),
                        );
                        nameController.clear();
                        emailController.clear();
                        messageController.clear();
                      }
                    },
                    child: const Text('Send', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}