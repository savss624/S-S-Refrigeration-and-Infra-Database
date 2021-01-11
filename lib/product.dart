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
import 'appliances.dart';
import 'main.dart';

class Product extends StatefulWidget {
  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  String productImage = '';
  String productName = '';
  String productModel = '';
  String productPrice = '';
  String details = '';

  File _image;
  final picker = ImagePicker();

  // ignore: deprecated_member_use
  CollectionReference userRefrence = FirebaseFirestore.instance
      .collection('Brands')
      .doc(currentBrand.toLowerCase().toLowerCase())
      .collection('Appliances')
      .doc(currentAppliance.toLowerCase().toLowerCase())
      .collection('Products');

  Future<firebase_storage.UploadTask> uploadFile(BuildContext context) async {
    Fluttertoast.showToast(
        msg: "May Take Few Seconds",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 13.0);
    String fileName = path.basename(_image.path);
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Products')
        .child(fileName);
    firebase_storage.UploadTask uploadTask = ref.putFile(_image);
    final url = await (await uploadTask).ref.getDownloadURL();
    setState(() async {
      productImage = url.toString();
      Navigator.pop(context);
      displayBottomSheet();
    });
  }

  Future<void> getImageViaGallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper.cropImage(
        sourcePath: File(pickedFile.path).path,
      );
      setState(() {
        if (croppedFile != null) {
          _image = File(croppedFile.path);
          uploadFile(context);
        } else {
          print('No file selected');
        }
      });
    }
  }

  Future<void> getImageViaCamera() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper.cropImage(
        sourcePath: File(pickedFile.path).path,
      );
      setState(() {
        if (croppedFile != null) {
          _image = File(croppedFile.path);
          uploadFile(context);
        } else {
          print('No file selected');
        }
      });
    } else {
      print('No file selected');
    }
  }

  void EditImage() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))),
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
        });
  }

  void displayBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter seState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                color: Color(0xFF737373),
                height: 300,
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      initialValue: productName,
                                      onChanged: (String value) {
                                        productName = value;
                                      },
                                      decoration: InputDecoration(
                                          labelText: 'Product Title'),
                                    ),
                                    TextFormField(
                                      initialValue: productModel,
                                      onChanged: (String value) {
                                        productModel = value;
                                      },
                                      decoration: InputDecoration(
                                          labelText: 'Model Number'),
                                    ),
                                    TextFormField(
                                      initialValue: productPrice,
                                      onChanged: (String value) {
                                        productPrice = value;
                                      },
                                      decoration:
                                          InputDecoration(labelText: 'MRP'),
                                    ),
                                  ],
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
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Color(0xff010080),
                                          )),
                                      Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            image: DecorationImage(
                                                image:
                                                    NetworkImage(productImage),
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
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
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
                                  userRefrence
                                      .doc(productModel.toLowerCase())
                                      .get()
                                      .then((DocumentSnapshot
                                          documentSnapshot) async {
                                    if (documentSnapshot.exists) {
                                      Fluttertoast.showToast(
                                          msg: "Model Already Exists!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 10,
                                          backgroundColor: Colors.black54,
                                          textColor: Colors.white,
                                          fontSize: 13.0);
                                    } else {
                                      userRefrence
                                          .doc(productModel.toLowerCase())
                                          .set({
                                            'ProductName': productName,
                                            'ProductImage': productImage,
                                            'ProductModel': productModel,
                                            'ProductPrice': productPrice,
                                            'Details': '',
                                          })
                                          .then((value) => print('user added'))
                                          .catchError((error) =>
                                              print('Failed to add User'));
                                      setState(() {
                                        edit = '';
                                        productName = '';
                                        productImage = '';
                                        productModel = '';
                                        productPrice = '';
                                        details = '';
                                      });
                                      Navigator.pop(context);
                                    }
                                  });
                                },
                                child: Center(
                                  child: Text(
                                    'Create',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat'),
                                  )
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  void editAlert(List<String> other, int l) {
    Alert(
      context: context,
      title: "Details",
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter seState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                          height:
                          80,
                          width:
                          80,
                          decoration:
                          BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(40),
                            color:
                            Color(0xff010080),
                          )),
                      Container(
                        height:
                        80,
                        width:
                        80,
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(40),
                            image: DecorationImage(image: NetworkImage(productImage), fit: BoxFit.cover)),
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
                            style: BorderStyle
                                .solid,
                            width:
                            2.0),
                        color: Colors
                            .transparent,
                        borderRadius:
                        BorderRadius.circular(10.0)),
                    child: FlatButton(
                        onPressed: EditImage,
                        child: Center(
                          child: Text(
                              'Edit',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
                        )),
                  ),
                  SizedBox(
                    height: 210,
                    child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: l,
                        itemBuilder: (context, index) {
                          return TextFormField(
                            initialValue: other[index].split('_')[1],
                            decoration: InputDecoration(
                                labelText: other[index].split('_')[0],
                                suffixIcon: index != 0 && index != 1 && index != 2 ?
                                  IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    details = details.replaceAll('|'+other[index],'');
                                    setState(() {
                                      other =
                                          ('Product Title_'+productName+'|Model Number_'+productModel+'|MRP_'+productPrice+details).split('|');
                                      l = other.length;
                                      Navigator.pop(context);
                                      editAlert(other, l);
                                    });
                                  },
                                )
                                    : Icon(Icons.close, color: Colors.white)
                            ),
                            onChanged: (String value) {
                              if(index == 0)
                                productName = value;
                              else if(index == 1)
                                productModel = value;
                              else if(index == 2)
                                productPrice = value;
                              else {
                                details = details.replaceAll(other[index],other[index].split('_')[0]+'_'+value);
                                setState(() {
                                  other =
                                      ('Product Title_'+productName+'|Model Number_'+productModel+'|MRP_'+productPrice+details).split('|');
                                  l = other.length;
                                });
                              }
                            },
                          );
                        }
                    ),
                  )
                ],
              ),
            );
          }
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Add Field",
            style: TextStyle(
                color: Colors
                    .white,
                fontSize:
                18),
          ),
          onPressed:
              () {
            Alert(
                context:
                context,
                title:
                "Add Field",
                content:
                Column(
                  children: <Widget>[
                    TextField(
                      onChanged: (String value) {
                        field = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Field Title',
                      ),
                    ),
                    TextField(
                      onChanged: (String value) {
                        fieldData = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Detail',
                      ),
                    ),
                  ],
                ),
                buttons: [
                  DialogButton(
                    onPressed: () {
                      details = details + '|' + field + '_' + fieldData;
                      userRefrence
                          .doc(productModel.toLowerCase())
                          .update({
                        'Details': details,
                      })
                          .then((value) => print('updated'))
                          .catchError((error) => print('Failed to update'));
                      field = '';
                      fieldData = '';
                      Navigator.pop(context);
                      Navigator.pop(context);
                      other =
                          ('Product Title_'+productName+'|Model Number_'+productModel+'|MRP_'+productPrice+details).split('|');
                      l = other.length;
                      editAlert(other, l);
                    },
                    child:
                    Text(
                      "Add",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]).show();
          },
          color: Color
              .fromRGBO(
              0,
              179,
              134,
              1.0),
        ),
        DialogButton(
          child: Text(
            "Save",
            style: TextStyle(
                color: Colors
                    .white,
                fontSize:
                18),
          ),
          onPressed: () {
            userRefrence
                .doc(edit.toLowerCase())
                .delete();
            userRefrence
                .doc(productModel.toLowerCase())
                .set({
              'ProductName': productName,
              'ProductImage': productImage,
              'ProductModel': productModel,
              'ProductPrice': productPrice,
              'Details': details,
            })
                .then((value) => print('updated'))
                .catchError((error) => print('Failed to update'));
            productName = '';
            productImage = '';
            productModel = '';
            productPrice = '';
            details = '';
            Navigator.pop(
                context);
          },
          color: Color
              .fromRGBO(
              0,
              179,
              134,
              1.0),
        ),
      ],
    ).show();
  }

  void displayAlert(List<String> other, int l) {
    Alert(
      context: context,
      title: "Details",
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter seState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Stack(
                    children: [
                      Container(
                          height:
                          80,
                          width:
                          80,
                          decoration:
                          BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(40),
                            color:
                            Color(0xff010080),
                          )),
                      Container(
                        height:
                        80,
                        width:
                        80,
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(40),
                            image: DecorationImage(image: NetworkImage(productImage), fit: BoxFit.cover)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    height: 210,
                    child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: l,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 250,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                          other[index].split('_')[0]+' : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        other[index].split('_')[1],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  )
                ],
              ),
            );
          }
      ),
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(
                color: Colors
                    .white,
                fontSize:
                18),
          ),
          onPressed: () {
            productName =
            '';
            productImage =
            '';
            productModel =
            '';
            productPrice =
            '';
            details = '';
            Navigator.pop(context);
          },
          color: Color
              .fromRGBO(
              0,
              179,
              134,
              1.0),
        ),
      ],
    ).show();
  }

  String edit = '';
  String search = '';
  String field = '';
  String fieldData = '';

  ScrollController _scrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            edit = '';
            productName = '';
            productImage = '';
            productPrice = '';
            productModel = '';
            details = '';
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
          if (search == '')
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
            if (search != '')
              setState(() {
                search = '';
              });
          },
        ),
        title: search == ''
            ? Center(
                child: Text(
                  currentAppliance,
                  style: TextStyle(
                    letterSpacing: 4,
                  ),
                ),
              )
            : TextField(
                style: TextStyle(color: Colors.white),
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
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
                padding: const EdgeInsets.all(2.0),
                child: StreamBuilder<QuerySnapshot>(
                  // ignore: deprecated_member_use
                  stream: Firestore.instance
                      .collection('Brands')
                      .doc(currentBrand.toLowerCase().toLowerCase())
                      .collection('Appliances')
                      .doc(currentAppliance.toLowerCase().toLowerCase())
                      .collection('Products')
                      .snapshots(),
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
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            String s = document['ProductName']
                                .toString()
                                .toLowerCase();
                            bool permit = true;
                            if (search.toLowerCase() != s &&
                                search.length >= s.length) permit = false;
                            if (search.length <= s.length)
                              for (int i = 0;
                                  i < search.length &&
                                      search != '' &&
                                      search != '-';
                                  i++) {
                                if (s[i] != search[i]) permit = false;
                              }

                            return search == '' ||
                                    search == '-' ||
                                    permit == true
                                ? Card(
                                    elevation: 5.0,
                                    child: Stack(
                                      children: [
                                        Container(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Container(
                                                      height: 160,
                                                      width: 160,
                                                      color: Colors.black12.withOpacity(.2),
                                                    ),
                                                    Image.network(
                                                      document['ProductImage'],
                                                      height: 160,
                                                      width: 160,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    if (edit ==
                                                        document['ProductModel']
                                                            .toString())
                                                      Positioned.fill(
                                                        child: Container(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 12),
                                                              child: Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                    color: Color(0xff010080).withOpacity(0.8),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20)),
                                                                child:
                                                                    IconButton(
                                                                  icon: Icon(Icons
                                                                      .close),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      edit = '';
                                                                      productName =
                                                                          '';
                                                                      productImage =
                                                                          '';
                                                                      productModel =
                                                                          '';
                                                                      productPrice =
                                                                          '';
                                                                      details = '';
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                SizedBox(width: 20),
                                                SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(height: 16),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: SizedBox(
                                                          width: 160,
                                                          child: Text(
                                                            document[
                                                                'ProductName'],
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: SizedBox(
                                                          width: 160,
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Model Number : ',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Flexible(
                                                                child: Text(
                                                                  document[
                                                                      'ProductModel'],
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: SizedBox(
                                                          width: 160,
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'MRP : ',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Flexible(
                                                                child: Text(
                                                                  document[
                                                                      'ProductPrice'],
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 36)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                        if (edit != document['ProductModel'])
                                          Positioned.fill(
                                            child: FlatButton(
                                              minWidth: double.infinity,
                                              onPressed: () {
                                                productName = document[
                                                'ProductName'];
                                                productImage = document[
                                                'ProductImage'];
                                                productModel = document[
                                                'ProductModel'];
                                                productPrice = document[
                                                'ProductPrice'];
                                                details = document['Details'].toString();
                                                List<String> other =
                                                ('Product Title_'+productName+'|Model Number_'+productModel+'|MRP_'+productPrice+details).split('|');
                                                int l = other.length;
                                                displayAlert(other, l);
                                              },
                                              onLongPress: () {
                                                setState(() {
                                                  edit = document['ProductModel']
                                                      .toString();
                                                });
                                              },
                                            ),
                                          ),
                                        if (edit ==
                                            document['ProductModel'].toString())
                                          Positioned.fill(
                                            child: Container(
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 24),
                                                  child: Container(
                                                    width: 100,
                                                    height: 30,
                                                    color: Colors.transparent,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        IconButton(
                                                          icon:
                                                              Icon(Icons.edit),
                                                          color: Color(0xff010080),
                                                          onPressed: () {
                                                            productName = document[
                                                                'ProductName'];
                                                            productImage = document[
                                                                'ProductImage'];
                                                            productModel = document[
                                                                'ProductModel'];
                                                            productPrice = document[
                                                                'ProductPrice'];
                                                            details = document['Details'].toString();
                                                            List<String> other =
                                                              ('Product Title_'+productName+'|Model Number_'+productModel+'|MRP_'+productPrice+details).split('|');
                                                            int l = other.length;
                                                            editAlert(other, l);
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons
                                                              .delete_outline),
                                                          color: Colors.red,
                                                          onPressed: () {
                                                            Alert(
                                                              context: context,
                                                              type: AlertType
                                                                  .warning,
                                                              title:
                                                                  "Are You Sure ?",
                                                              buttons: [
                                                                DialogButton(
                                                                  child: Text(
                                                                    "Cancel",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          0,
                                                                          179,
                                                                          134,
                                                                          1.0),
                                                                ),
                                                                DialogButton(
                                                                  child: Text(
                                                                    "Delete",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    // ignore: deprecated_member_use
                                                                    userRefrence
                                                                        .document(document['ProductModel']
                                                                            .toString()
                                                                            .toLowerCase())
                                                                        .delete();
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  gradient:
                                                                      LinearGradient(
                                                                          colors: [
                                                                        Colors
                                                                            .red,
                                                                        Colors
                                                                            .redAccent,
                                                                      ]),
                                                                )
                                                              ],
                                                            ).show();
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ))
                                : Container(height: 0, width: 0);
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
