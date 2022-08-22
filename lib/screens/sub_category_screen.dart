import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:shop_app_admin/firebase_service.dart';
import 'package:shop_app_admin/widgets/categories_list_widget.dart';

class SubCategoryScreen extends StatefulWidget {
  static const String id = 'sub-category';
  const SubCategoryScreen({Key? key}) : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _subCatName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  QuerySnapshot? snapshot;
  Object? _selectedValue;
  bool _isCategorySelected = false;
  dynamic image;
  String? filename;

  Widget _dropDownButton() {
    return DropdownButton(
        value: _selectedValue,
        hint: const Text('Select main category'),
        items: snapshot!.docs.map((e) {
          return DropdownMenuItem<String>(
            value: e['mainCategory'],
            child: Text(
              e['mainCategory'],
            ),
          );
        }).toList(),
        onChanged: (selectedCat) {
          setState(() {
            _selectedValue = selectedCat;
            _isCategorySelected = false;
          });
        });
  }

  pickImage() async {
    //used file_picker pkg
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        image = result.files.first.bytes;
        filename = result.files.first.name;
      });
    } else {
      // User canceled or operation failed the picker
      print('Canceled or failed');
    }
  }

  saveImageToDb() async {
    //used flutter_easyloading pkg
    EasyLoading.show();
    var ref = firebase_storage.FirebaseStorage.instance
        .ref('subCategoryImage/$filename');

    try {
      String? mimiType = mime(
        basename(filename!),
      );
      var metadata = firebase_storage.SettableMetadata(contentType: mimiType);
      firebase_storage.TaskSnapshot uploadSnapshot =
          await ref.putData(image, metadata);
      String downloadURL =
          await uploadSnapshot.ref.getDownloadURL().then((value) {
        if (value.isNotEmpty) {
          //save data to firestore from storage
          _service.saveCategory(data: {
            'subcatName': _subCatName.text,
            'mainCategory': _selectedValue,
            'image': value,
            'active': true,
          }, docName: _subCatName.text, reference: _service.subCat).then(
              (value) {
            //after saving clear data from screen
            clear();
            EasyLoading.dismiss();
          });
        }
        return value;
      });
    } on FirebaseException catch (e) {
      clear();
      EasyLoading.dismiss();
      print(e.toString());
    }
  }

  clear() {
    setState(() {
      _subCatName.clear();
      image = null;
    });
  }

  @override
  void initState() {
    getMainCatList();
    super.initState();
  }

  getMainCatList() {
    return _service.mainCat.get().then((QuerySnapshot querySnapshot) {
      setState(() {
        snapshot = querySnapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(10),
          child: const Text(
            'Sub Category',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 36,
            ),
          ),
        ),
        const Divider(
          color: Colors.grey,
        ),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Column(
              children: [
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Center(
                    child: image == null
                        ? const Text('Sub Category image')
                        : Image.memory(image),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  child: const Text('Upload Image'),
                  onPressed: pickImage,
                ),
              ],
            ),
            const Divider(
              color: Colors.grey,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                snapshot == null ? const Text('Loading...') : _dropDownButton(),
                const SizedBox(
                  height: 8,
                ),
                if (_isCategorySelected == true)
                  const Text(
                    'No Main Category Selected',
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Sub Category Name';
                      }
                    },
                    controller: _subCatName,
                    decoration: const InputDecoration(
                      label: Text('Enter Sub catgory name:'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: clear,
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        side: MaterialStateProperty.all(
                          BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (image != null)
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedValue == null) {
                            setState(() {
                              _isCategorySelected = true;
                            });
                            return;
                          }
                          if (_formKey.currentState!.validate()) {
                            saveImageToDb();
                          }
                        },
                        child: const Text(
                          'Save',
                        ),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(5.0),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor),
                          side: MaterialStateProperty.all(
                            BorderSide(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
        const Divider(
          color: Colors.grey,
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(10),
          child: const Text(
            'Sub Categories List',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        // const SizedBox(
        //   height: 10,
        // ),
        const Divider(
          color: Colors.grey,
        ),
        CategoryListWidget(
          reference: _service.subCat,
        ),
      ]),
    );
  }
}
