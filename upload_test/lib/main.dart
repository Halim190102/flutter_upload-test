import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upload_test/model.dart';
import 'package:image_cropper/image_cropper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  final dio = Dio();

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
      source: source,
    );

    if (file != null) {
      return file;
    }
  }

  void request() async {
    try {
      Response response = await dio.get(
        '$url/api/gambar',
      );
      Future.delayed(Duration.zero, () {
        if (response.statusCode == 200 && response.data != null) {
          setState(() {
            data = ImageUpload.fromJson(response.data);
          });
        } else {
          throw Exception('Failed to load image');
        }
      });
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Failed to load image. Please check your internet connection.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      request();
    });
  }

  ImageUpload? data;

  String massage = '';

  String url = 'http://192.168.1.19:8000';

  Future _cropImage(XFile? xfile) async {
    if (xfile != null) {
      CroppedFile? cropped = await ImageCropper().cropImage(
          sourcePath: xfile.path,
          aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop',
                cropGridColor: Colors.black,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(title: 'Crop')
          ]);

      if (cropped != null) {
        return File(cropped.path);
      } else {
        return null;
      }
    }
  }

  Future convertXFileToFile() async {
    XFile? im = await pickImage(ImageSource.gallery);

    File? file = await _cropImage(im);
    if (file != null) {
      String fileName = file.path.split('/').last;

      FormData form = FormData.fromMap({
        'gambar': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });
      await Dio()
          .post(
        '$url/api/gambar',
        data: form,
      )
          .then((value) {
        request();
      }).catchError((error) => print(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Future.delayed(Duration.zero, () async {
                  await convertXFileToFile();
                });
              },
              child: const Text(
                'halo',
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            if (data != null)
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final gambaran = data!.data![index].gambar!;
                    return CachedNetworkImage(
                      imageUrl: "$url/uploads/$gambaran",
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      height: 560,
                      width: 315,
                    );
                  },
                  itemCount: data!.data!.length,
                ),
              )
            else
              const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
