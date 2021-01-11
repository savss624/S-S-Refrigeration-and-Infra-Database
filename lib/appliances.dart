import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'main.dart';
import 'product.dart';

String currentAppliance = '';

class Appliances extends StatefulWidget {

  @override
  _AppliancesState createState() => _AppliancesState();
}

class _AppliancesState extends State<Appliances> {

  String appliancesImage = '';
  String appliancesName = '';

  File _image;
  final picker=ImagePicker();

  // ignore: deprecated_member_use
  CollectionReference userRefrence = FirebaseFirestore.instance.collection('Brands')
      .doc(currentBrand.toLowerCase()).collection('Appliances');

  Future<firebase_storage.UploadTask> uploadFile(BuildContext context) async{
    Fluttertoast.showToast(
        msg: "May Take Few Seconds",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 13.0);
    String fileName = path.basename(_image.path);
    firebase_storage.Reference ref= firebase_storage.FirebaseStorage.instance.ref().child('Appliances').child(fileName);
    firebase_storage.UploadTask uploadTask = ref.putFile(_image);
    final url = await (await uploadTask).ref.getDownloadURL();
    setState(() async {
      appliancesImage = url.toString();
      Navigator.pop(context);
      displayBottomSheet();
    });
  }

  Future<void> getImageViaGallery() async{
    Navigator.pop(context);
    final pickedFile =await picker.getImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      final croppedFile=await ImageCropper.cropImage(
        sourcePath: File(pickedFile.path).path,
      );
      setState(() {
        if(croppedFile!=null){
          _image = File(croppedFile.path);
          uploadFile(context);
        }else{
          print('No file selected');
        }
      });
    }
  }

  Future<void> getImageViaCamera() async{
    Navigator.pop(context);
    final pickedFile =await picker.getImage(source: ImageSource.camera);
    if(pickedFile!=null){
      final croppedFile=await ImageCropper.cropImage(
        sourcePath: File(pickedFile.path).path,
      );
      setState(() {
        if(croppedFile!=null){
          _image = File(croppedFile.path);
          uploadFile(context);
        }else{
          print('No file selected');
        }
      });
    }
    else{
      print('No file selected');
    }
  }

  void EditImage(){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return Container(
            color: Color(0xFF737373),
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          iconSize: 60,
                          icon: Icon(Icons.camera),
                          onPressed: getImageViaCamera,
                        ),
                        Text('Camera'),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          iconSize: 60,
                          icon: Icon(Icons.photo),
                          onPressed: getImageViaGallery,
                        ),
                        Text('Gallery'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  void displayBottomSheet(){
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter seState) {
                return Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom),
                  child: Container(
                    color: Color(0xFF737373),
                    height: 180,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme
                              .of(context)
                              .canvasColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)
                          )
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: appliancesName,
                                    onChanged: (String value) {
                                      appliancesName = value;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Appliance Title'
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  30),
                                              color: Color(0xff010080),
                                            )
                                        ),
                                        Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  30),
                                              image: DecorationImage(
                                                  image: NetworkImage(appliancesImage),
                                                  fit: BoxFit.cover)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 20,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xff010080),
                                              style: BorderStyle.solid,
                                              width: 2.0),
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                              10.0)),
                                      child: FlatButton(
                                          onPressed: EditImage,
                                          child: Center(
                                            child: Text('Edit',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Montserrat')),
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Container(
                              height: 30.0,
                              width: 80.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(10.0),
                                shadowColor: Color(0xff010080),
                                color: Color(0xff010080),
                                elevation: 7.0,
                                child: FlatButton(
                                  onPressed: () async {
                                    if(edit != '') {
                                      userRefrence.doc(edit.toLowerCase()).collection('Products').get().then((querySnapshot) => {
                                        querySnapshot.docs.forEach((element) {
                                          userRefrence.doc(appliancesName.toLowerCase()).collection('Products').doc(element.id).set(
                                              {
                                                'ProductName': element.data()['ProductName'],
                                                'ProductImage': element.data()['ProductImage'],
                                                'ProductModel': element.data()['ProductModel'],
                                                'ProductPrice': element.data()['ProductPrice'],
                                                'Details': element.data()['Details'],
                                              }).then((value) => print('user added'))
                                              .catchError((error) =>
                                              print('Failed to add User'));
                                          userRefrence.doc(edit.toLowerCase()).collection('Products').doc(element.id).delete();
                                          print(element.data());
                                        })
                                      });
                                      userRefrence.doc(edit.toLowerCase()).delete();
                                    }
                                    userRefrence
                                        .doc(appliancesName.toLowerCase())
                                        .get()
                                        .then((DocumentSnapshot documentSnapshot) async {
                                      if (documentSnapshot.exists) {
                                        Fluttertoast.showToast(
                                            msg: "Appliance Name Already Exists!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 10,
                                            backgroundColor: Colors.black54,
                                            textColor: Colors.white,
                                            fontSize: 13.0);
                                      }
                                      else {
                                        userRefrence.doc(appliancesName.toLowerCase()).set(
                                            {
                                              'AppliancesName': appliancesName,
                                              'AppliancesImage': appliancesImage,
                                            }).then((value) => print('user added'))
                                            .catchError((error) =>
                                            print('Failed to add User'));
                                        setState(() {
                                          edit = '';
                                          appliancesName = '';
                                          appliancesImage = '';
                                        });
                                        Navigator.pop(context);
                                      }
                                    });
                                  },
                                  child: Center(
                                    child: edit == ''
                                        ? Text(
                                      'Create',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat'),
                                    )
                                        : Text(
                                      'Save',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        }
    );
  }

  String edit = '';
  String search = '';

  ScrollController _scrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            edit = '';
            appliancesName = '';
            appliancesImage = '';
          });
          displayBottomSheet();
        },
        icon: Icon(Icons.add),
        backgroundColor: Color(0xff010080),
        label: Text('Add'),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xff010080),
        shadowColor: Color(0xff010080),
        actions: [
          if(search == '')
            IconButton(
              icon: Icon(Icons.search_sharp),
              onPressed: () {
                print(currentBrand.toLowerCase().toLowerCase());
                setState(() {
                  search = '-';
                });
              },
            )
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp, color: search != '' ? Colors.white : Color(0xff010080)),
          onPressed: () {
            if(search != '')
              setState(() {
                search = '';
              });
          },
        ),
        title: search == ''
            ? Center(
          child: Text(
            currentBrand,
            style: TextStyle(
              letterSpacing: 4,
            ),
          ),
        )
            : TextField(
          style: TextStyle(
              color: Colors.white
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search',
          ),
          onChanged: (String value) {
            setState(() {
              search = value.toLowerCase();
            });
          },
        ),
      ),
      body:  Column(
        children: <Widget>[
          Expanded(
            child: Container(
                padding: const EdgeInsets.all(2.0),
                child: StreamBuilder<QuerySnapshot>(
                  // ignore: deprecated_member_use
                  stream: Firestore.instance.collection('Brands').doc(currentBrand.toLowerCase()).collection('Appliances').snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return Center(child: CircularProgressIndicator());
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        return ListView(
                          controller: _scrollController,
                          reverse: false,
                          shrinkWrap: true,
                          // ignore: deprecated_member_use
                          children: snapshot.data.documents.map((DocumentSnapshot document) {

                            String s = document['AppliancesName'].toString().toLowerCase();
                            bool permit = true;
                            if(search.toLowerCase() != s && search.length >= s.length)
                              permit = false;
                            if(search.length <= s.length)
                              for(int i = 0; i < search.length && search != '' && search != '-'; i++) {
                                if(s[i] != search[i])
                                  permit = false;
                              }

                            return search == '' || search == '-' || permit == true ? Card(
                                elevation: 5.0,
                                child: Stack(
                                  children: [
                                    Container(
                                        height: 80,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 2,
                                                  color: Color(0xff010080),
                                                  height: 80,
                                                ),
                                                Stack(
                                                  children: [
                                                    Container(
                                                      height: 80,
                                                      width: 80,
                                                      color: Colors.black12.withOpacity(0.2),
                                                    ),
                                                    Image.network(
                                                      document['AppliancesImage'],
                                                      height: 80,
                                                      width: 80,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    if(edit == document['AppliancesName'].toString())
                                                      Center(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 4),
                                                          child: Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                                color: Color(0xff010080).withOpacity(0.8),
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                    20)),
                                                            child: IconButton(
                                                              icon: Icon(Icons.close),
                                                              onPressed: () {
                                                                setState(() {
                                                                  edit = '';
                                                                  appliancesName = '';
                                                                  appliancesImage = '';
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                SizedBox(width: 20),
                                                SingleChildScrollView(
                                                  child: SizedBox(
                                                    width: 120,
                                                    child: Flexible(
                                                      child: Text(
                                                        document['AppliancesName'],
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if(edit == document['AppliancesName'].toString())
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.edit),
                                                    color: Color(0xff010080),
                                                    onPressed: () {
                                                      appliancesName = document['AppliancesName'];
                                                      appliancesImage = document['AppliancesImage'];
                                                      displayBottomSheet();
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.delete_outline),
                                                    color: Colors.red,
                                                    onPressed: () {
                                                      Alert(
                                                        context: context,
                                                        type: AlertType.warning,
                                                        title: "Are You Sure ?",
                                                        buttons: [
                                                          DialogButton(
                                                            child: Text(
                                                              "Cancel",
                                                              style: TextStyle(color: Colors.white, fontSize: 20),
                                                            ),
                                                            onPressed: () => Navigator.pop(context),
                                                            color: Color.fromRGBO(0, 179, 134, 1.0),
                                                          ),
                                                          DialogButton(
                                                            child: Text(
                                                              "Delete",
                                                              style: TextStyle(color: Colors.white, fontSize: 20),
                                                            ),
                                                            onPressed: () {
                                                              // ignore: deprecated_member_use
                                                              userRefrence.document(document['AppliancesName'].toString().toLowerCase()).delete();
                                                              Navigator.pop(context);
                                                            },
                                                            gradient: LinearGradient(colors: [
                                                              Colors.red,
                                                              Colors.redAccent,
                                                            ]),
                                                          )
                                                        ],
                                                      ).show();
                                                    },
                                                  )
                                                ],
                                              )
                                          ],
                                        )
                                    ),
                                    if(edit != document['AppliancesName'])
                                      FlatButton(
                                        height: 80,
                                        minWidth: double.infinity,
                                        onPressed: () {
                                          currentAppliance = document['AppliancesName'].toString();
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Product()));
                                        },
                                        onLongPress: () {
                                          setState(() {
                                            edit = document['AppliancesName'].toString();
                                          });
                                        },
                                      )
                                  ],
                                )
                            ) : Container(height: 0, width: 0);
                          }).toList(),
                        );
                    }
                  },
                )),
          ),
        ],
      ),
    );
  }
}
