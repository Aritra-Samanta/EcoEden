import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoeden/main.dart';
import 'package:http_parser/http_parser.dart';
import 'package:toast/toast.dart';
import 'package:path_drawing/path_drawing.dart';

class ImageInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImageInput();
  }
}

class _ImageInput extends State<ImageInput> {
  // To store the file provided by the image_picker
  File _imageFile;

  // To track the file uploading state
  bool _isUploading = false;

  String baseUrl = 'https://api.ecoeden.xyz/photos/';

  final _descriptionController = TextEditingController();

  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = image;
    });

    // Closes the bottom sheet
    Navigator.pop(context);
  }

  Future<Map<String, dynamic>> _uploadImage(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('user');

    setState(() {
      _isUploading = true;
    });

    // Find the mime type of the selected file by looking at the header bytes of the file
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    // Intilize the multipart request
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUrl));

    // Attach the file in the request
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    // Explicitly pass the extension of the image with request body
    // Since image_picker has some bugs due which it mixes up
    // image extension with file name like this filenamejpge
    // Which creates some problem at the server side to manage
    // or verify the file extension
//    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.headers['Authorization'] = 'Token ' + jwt;
    imageUploadRequest.fields['user'] = 'http://api.ecoeden.xyz/users/' +
        global_store.state.user.id.toString() +
        '/';
    imageUploadRequest.fields['lat'] = '${res.latitude}';
    imageUploadRequest.fields['lng'] = '${res.longitude}';
    imageUploadRequest.fields['description'] =
        _descriptionController.text; //"Anonymous post";
    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        return null;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      _resetState();

      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _startUploading() async {
    final Map<String, dynamic> response = await _uploadImage(_imageFile);
    print(response);
    // Check if any error occured
    if (response == null || response.containsKey("error")) {
      Toast.show("Image Upload Failed!!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      Toast.show("Image Uploaded Successfully!!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _resetState() {
    setState(() {
      _isUploading = false;
      _imageFile = null;
      //_descriptionController.clear();
    });
  }

  void _openImagePickerModal(BuildContext context) {
    final flatButtonColor = Theme.of(context).primaryColor;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Camera'),
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Gallery'),
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget _buildUploadBtn() {
    Widget btnWidget = Container();

    if (_isUploading) {
      // File is being uploaded then show a progress indicator
      btnWidget = CircularProgressIndicator();
    } else if (!_isUploading && _imageFile != null) {
      // If image is picked by the user then show a upload btn

      btnWidget = FlatButton(
        onPressed: () =>
        {_startUploading},
        child: Text(
          '+ UPLOAD',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20),
        ),
      );
    }

    return btnWidget;
  }

  Widget descriptionField() {
    Widget btnWidget = Container();

    if (_isUploading) {
      // File is being uploaded then show a progress indicator
      btnWidget = Container();
    } else if (!_isUploading && _imageFile != null) {
      btnWidget = Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        child: TextFormField(
          controller: _descriptionController,
          maxLines: 1,
          //keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            hintText: 'Add a description to your image',
//          icon: Icon(
//            Icons.account_circle,
//            color: Colors.grey,
//          ),
          ),
//          validator: (value) =>
//          value.isEmpty
//              ? 'Email cant\'t be empty.'
//              : null,
          //onSaved: (value) => _email = value.trim(),
        ),
      );
    }
    return btnWidget;
  }

  Widget showUploadButton(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back, size: 30),
              onPressed: () => {},
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Photos',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 54.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0.0, 30.0, 4.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 50,
              height: 50,
              child: Image.asset('assets/EcoEden-Logo-withoutText.png'),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(0.0),
          child: Align(
            alignment: Alignment.center,
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 420,
                    width: 350,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blueGrey[200]),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        color: Colors.transparent,
                        child: CustomPaint(
                          painter: RectPainter(),
                          child: Column(
                            children: <Widget>[
                              descriptionField(),
                              _imageFile == null
                                  ? Align(
                                      heightFactor: 2.3,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        child: Image.asset(
                                            'assets/add-image-symbol.jpg'),
                                      ),
                                    )
                                  : Image.file(
                                      _imageFile,
                                      fit: BoxFit.cover,
                                      height: 300.0,
                                      alignment: Alignment.topCenter,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.white),
                                      child: _imageFile == null ? FlatButton(
                                        onPressed: () =>
                                            {_openImagePickerModal(context)},
                                        child: Text(
                                          '+ IMAGE',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                        ),
                                      )
                                      : _buildUploadBtn(),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Positioned(
            child: Image.asset(
          'assets/wave.png',
          fit: BoxFit.fitWidth,
        )),
        showUploadButton(context),
      ]),
    );
  }
}

class RectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(0)));

    // canvas.drawPath(path, paint);
    canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(<double>[15, 10.5]),
        ),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    return false;
  }
}
