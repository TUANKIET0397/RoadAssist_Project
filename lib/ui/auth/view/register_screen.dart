// // import 'package:flutter/material.dart';

// // class RegisterScreen extends StatefulWidget {
// //   const RegisterScreen({super.key});

// //   @override
// //   State<RegisterScreen> createState() => _RegisterScreenState();
// // }

// import 'package:flutter/material.dart';
// import 'package:form_field_validator/form_field_validator.dart';
// import 'package:flutter/foundation.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({Key? key}) : super(key: key);

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   Map userData = {};
//   final _formkey = GlobalKey<FormState>();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('RegisterScreen')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Form(
//             key: _formkey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.only(top: 20.0),
//                   child: Center(
//                     child: Container(
//                       width: 200,
//                       height: 150,
//                       //decoration: BoxDecoration(
//                       //borderRadius: BorderRadius.circular(40),
//                       //border: Border.all(color: Colors.blueGrey)),
//                       child: Image.asset('assets/logo.png'),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: TextFormField(
//                     // validator: ((value) {
//                     //   if (value == null || value.isEmpty) {
//                     //     return 'please enter some text';
//                     //   } else if (value.length < 5) {
//                     //     return 'Enter atleast 5 Charecter';
//                     //   }

//                     //   return null;
//                     // }),
//                     validator: MultiValidator([
//                       RequiredValidator(errorText: 'Enter first named'),
//                       MinLengthValidator(
//                         3,
//                         errorText: 'Minimum 3 charecter filled name',
//                       ),
//                     ]),

//                     decoration: InputDecoration(
//                       hintText: 'Enter first Name',
//                       labelText: 'first named',
//                       prefixIcon: Icon(Icons.person, color: Colors.green),
//                       errorStyle: TextStyle(fontSize: 18.0),
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red),
//                         borderRadius: BorderRadius.all(Radius.circular(9.0)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextFormField(
//                     validator: MultiValidator([
//                       RequiredValidator(errorText: 'Enter last named'),
//                       MinLengthValidator(
//                         3,
//                         errorText: 'Last name should be atleast 3 charater',
//                       ),
//                     ]),
//                     decoration: InputDecoration(
//                       hintText: 'Enter last Name',
//                       labelText: 'Last named',
//                       prefixIcon: Icon(Icons.person, color: Colors.grey),
//                       errorStyle: TextStyle(fontSize: 18.0),
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red),
//                         borderRadius: BorderRadius.all(Radius.circular(9.0)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextFormField(
//                     validator: MultiValidator([
//                       RequiredValidator(errorText: 'Enter email address'),
//                       EmailValidator(errorText: 'Please correct email filled'),
//                     ]),
//                     decoration: InputDecoration(
//                       hintText: 'Email',
//                       labelText: 'Email',
//                       prefixIcon: Icon(Icons.email, color: Colors.lightBlue),
//                       errorStyle: TextStyle(fontSize: 18.0),
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red),
//                         borderRadius: BorderRadius.all(Radius.circular(9.0)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextFormField(
//                     validator: MultiValidator([
//                       RequiredValidator(errorText: 'Enter mobile number'),
//                       PatternValidator(
//                         r'(^[0,9]{10}$)',
//                         errorText: 'enter vaid mobile number',
//                       ),
//                     ]),
//                     decoration: InputDecoration(
//                       hintText: 'Mobile',
//                       labelText: 'Mobile',
//                       prefixIcon: Icon(Icons.phone, color: Colors.grey),
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.red),
//                         borderRadius: BorderRadius.all(Radius.circular(9)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(18.0),
//                     child: Container(
//                       // margin: EdgeInsets.fromLTRB(200, 20, 50, 0),
//                       child: RaisedButton(
//                         child: Text(
//                           'RegisterScreen',
//                           style: TextStyle(color: Colors.white, fontSize: 22),
//                         ),
//                         onPressed: () {
//                           if (_formkey.currentState!.validate()) {
//                             print('form submiitted');
//                           }
//                         },
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         color: Colors.blue,
//                       ),

//                       width: MediaQuery.of(context).size.width,

//                       height: 50,
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 20),
//                     child: Center(
//                       child: Text(
//                         'Or Sign Up Using',
//                         style: TextStyle(fontSize: 18, color: Colors.black),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 20, left: 90),
//                     child: Row(
//                       children: [
//                         Container(
//                           height: 40,
//                           width: 40,
//                           child: Image.asset(
//                             'assets/google.png',
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         Container(
//                           height: 70,
//                           width: 70,
//                           child: Image.asset(
//                             'assets/vishal.png',
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         Container(
//                           height: 40,
//                           width: 40,
//                           child: Image.asset(
//                             'assets/google.png',
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: Container(
//                     padding: EdgeInsets.only(top: 60),
//                     child: Text(
//                       'SIGN IN',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
